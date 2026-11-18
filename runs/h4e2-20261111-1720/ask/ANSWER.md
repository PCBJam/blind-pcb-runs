# Retrospective: H4E2 routing run (52 min, $16.42)

Basis: the session itself was not kept, so this is reconstructed from `timeline.txt`, `NOTES.md` and
the scripts in `/work/routing`. Step numbers `[n]` refer to the timeline. The savings figures are my
estimates from step counts, not measurements; the timeline has no per-step cost.

## 1. Tools I built

| Tool | What it does | Want ready-made? |
|---|---|---|
| Inline `pcbnew` dumps `[3,5,11,15]` | footprints, pads per net with coordinates, outline/cut-outs, pad polygons | **Yes**: one call, compact output |
| `render.sh` (22 lines) | `kicad-cli` SVG → cairosvg → cropped PNG of an x/y/w/h window | **Yes**; mine hard-codes this board's origin and width |
| `core.py` (92 lines) | numba A* on a 0.1 mm grid, 8 directions, 2 layers, via and turn costs | **Yes**, but as a real router (see 2) |
| `engine.py` (339 lines) | pads/holes/edges → shapely obstacle maps per net and width, waypoint routing, `manual` polylines, `mvia`, GND stub+via, failure diagnosis | **Yes**: this was the bulk of the build |
| `plan.py` (144 lines) | the actual routing: net order, widths, waypoints, hand coordinates | No, board-specific |
| `finalize.py` / `project.py` / `run.sh` | zones + fill + stitching vias, net classes and minimums, route → pour → DRC in one go | **Yes** (pour/stitch, DRC summary) |
| Ad-hoc "which tracks are in this box" queries `[61,68,70,78,83]` | find what blocks a failed net | **Yes** |
| Placement/pad-net diff against the original `[120]` | proves nothing was moved | **Yes**, trivial but mandatory |

## 2. Tools that would have saved the most (ranked)

1. **Push-and-shove / rip-up-and-retry router as a call** — maybe 40–50% of the run.
   In: board, net or net list, width, layer permissions, via allowed, optional waypoints or keep-in
   corridor. Out: routed/failed per connection, length, via count, and for failures the blocking
   items. Must snap to true pad centres and emit clean 45° segments. Under about 10 s per net and
   under 1 min for the whole board. My A* never shoves, so every blocked net meant me re-deriving
   waypoints by hand (`[29]`–`[86]`, about 60 steps, the largest share of the thinking). A working
   Freerouting (no Java here, I checked at `[7]`) with DSN/SES round trip would cover much of it.
2. **Bus / escape helper** — about 10–15%. In: ordered list of nets, pitch, layer, a centreline
   polyline, target pins. Out: parallel tracks with correctly staggered corners, plus pin-order
   fan-out from an IC. I computed the six-wire display bus and the hall channel coordinates by hand
   and got the diagonal spacing wrong once (`[35]`–`[42]`).
3. **Congestion / channel-capacity report before routing** — about 10%. In: board, clearance,
   width. Out: ratsnest crossings per region, how many tracks fit between named pads or pad rows,
   pins that can only escape one way. The floorplan (what goes on F.Cu, which bus goes where) was
   decided by mental arithmetic on pad coordinates from a 2000 px image.
4. **Region query** — about 5–8%. In: box, layers. Out: tracks, vias, pads with net, width and
   end points, plus free gaps. Under 1 s. Replaces five hand-written scripts and several renders.
5. **Fast crop render with net labels and a mm grid** — about 5%. I read 17 images; unlabelled
   tracks forced a follow-up coordinate query each time. Under 2 s, origin handled automatically.
6. **DRC as structured JSON, diffed against the unrouted baseline** — about 3%. Only new
   violations, grouped by type with coordinates and both items. I grepped the `.rpt` and separated
   the pre-existing library warnings by eye.
7. **Pour + GND via helper** — about 3%. Zones on both layers, a via beside every SMD GND pad,
   stitching on a grid that avoids tracks, island report. Mine took `[90]`–`[97]` and one DRC loop.
8. **Cleanup pass** — small time saving, real quality gain: merge collinear segments, remove
   sub-0.15 mm stubs, snap ends to pad centres, teardrops. I shipped about 200 tiny segments and
   listed them as a known weakness because I had no time-efficient way to fix them.

A pre-installed stack (shapely, numba, cairosvg, a C compiler or Java) is worth a few minutes on its own.

## 3. Hardest parts and back-and-forth

- **Floorplanning without a congestion view.** The XIAO pin-out interleaves display and ADC SPI
  pins; deciding which bus leaves B.Cu, and where the hall channel and +3.3VA comb run, was all
  done in my head. A capacity report (tool 3) would have turned this into a lookup.
- **Auto-route, then give up, then hand-place.** First plan `[25]`, rewritten at `[33]`, then the
  display bus and analog trunk replaced by exact polylines at `[39]`–`[42]` because the A* result
  was "too chaotic". I should have hand-placed the buses first and auto-routed only the rest.
- **Cascading failures on the east side (U3001, encoders, LED chain)** `[47]`–`[86]`. One net's
  escape boxed in its neighbour, fixing it moved the failure on. Causes found late: my clearance
  margin (0.02 mm) was too conservative for a 0.5 mm pitch, the router started from any point of
  the net instead of the last waypoint, and the cut-out clearance was larger than needed. A router
  with rip-up, or failure output naming the blocker from the start, would have prevented most of it.
- **Grid vs. real pad centres.** A 0.1 mm grid with off-grid pads produced stubs, one clearance
  error and dangling ends at `[94]`–`[97]`. Gridless end-snapping would have avoided both the
  debugging and the leftover artefacts.
- **Late quality review.** I looked at pours and plane cuts only after everything routed `[100]`,
  when changing the F.Cu slots was expensive, so they stayed and went into the notes.

## 4. Brief and environment

- **No autorouter and no compiler.** No Java, no gcc; I had to check, then `pip install` numba,
  shapely and cairosvg through the proxy before I could write anything fast.
- **No GUI and no interactive router**, so every look at the board was export → rasterise → crop →
  read an image, about two tool calls and a large image each.
- **Pre-existing DRC noise** (missing `HALE-git` library, duplicate logo footprints, excluded
  NPTH-in-courtyard) had to be identified and filtered at every DRC run. A baseline report would help.
- **"Route it like an experienced designer" has no measurable target.** I spent thinking on width
  and plane choices without knowing what would be judged. Stated currents (LED chain, display
  backlight), SPI clock rate and whether the hall signals are the critical nets would have settled
  several decisions quickly.
- **Hierarchical schematics as raw s-expressions** are slow to read; I worked mostly from pad net
  names and pin functions. A netlist with per-net roles (power / analog / bus / slow) would be faster.
- The brief did not ask for Gerbers, so I did not produce them; "ready to order" left that unclear.
