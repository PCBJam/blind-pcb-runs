# bt review

Honest summary: `bt` was the reason this board could be done without a GUI at all, and its checking
side (`probe`, `apply --checked`, `drc --baseline`, `render`) is excellent. Its routing side was a
mixed bag: very good for short local nets and for single guided connections, slow and unreliable
for ~50 long nets across a 147 x 91 mm board, where it cost me well over an hour of wall-clock time.

## What I used, roughly how often

| command | uses | verdict |
|---|---|---|
| `bt apply --checked` | ~90 | The workhorse. Every hand-generated copper file went through it; "writes nothing if anything is wrong" let me iterate on generated geometry with no fear. |
| `bt probe` | ~20 | Same engine, used while iterating. Messages are precise (net, layer, gap, the other item). |
| `bt route --nets …` | ~12 runs | 63–64 of 64 short nets in ~50 s: great. Long nets: see below. |
| `bt route --net X --all` | ~30 | Good once the search was made cheaper (`--grid 0.1`) and pins had escapes. |
| `bt escape` | 3 | Very useful: 34 fine-pitch pins got a stub + via that keeps neighbours' exits open. Should have used it before any autorouting. |
| `bt ratsnest` | ~30 | Used constantly as the "what is left" list. |
| `bt render` | ~25 | The only eyes I had. Pad-net labels when zoomed in are very good. |
| `bt length` | 6 | Used for PCIe skew tuning (with a small script on top). |
| `bt query` / `bt part` | ~8 | Fine. |
| `bt drc` / `--baseline` | ~10 | Good; grouped output is far easier to read than KiCad's report. |
| `bt board` | 2 | Good first overview, but 56 kB of text for this board - I wrote a 15-line pcbnew dump for a compact netlist instead. |
| `bt bus` | 1 | Failed (2 of 6 SD nets "no path"); the bus really is non-planar, so not bt's fault, but it could not tell me that. |
| `bt pair` | 1 | Tried once, then not used (see below). |
| `bt fan` | 1 (dry) | Tried on the RP2040 with passives around it: 6 of 37 pins. Not used. |
| `bt plane`, `bt stitch`, `bt fill`, `bt zone`, `bt unroute`, `bt same` | a few each | Worked as described (zones themselves I added with a pcbnew script, 16 zones in one go). |
| `bt place`, `bt near`, `bt congestion`, `bt islands`, `bt cleanup`, `bt outline`, `bt undo`, `bt gap`, `bt free` | 0 | Placement was scripted from a floorplan (pcbnew), with a rebuild-from-original pipeline, so undo/place were not needed. |

## What helped most
- **`apply --checked` / `probe`.** I generated about 2 000 segments and 250 vias of hand-planned copper
  from Python (PCIe fanout, socket breakouts, nine bucks, Ethernet). Every mistake in my geometry
  (45° pair jogs with the wrong offset, a via 2 µm too close, tracks through a test point) was caught
  immediately with coordinates and the offending item. Without this I would have needed a full KiCad DRC
  round trip (≈15 s and a long report) per try. Biggest saving in mistakes and in tokens.
- **Plain-text writes that leave the .kicad_pro alone**, and JSON items that can be re-applied: the whole board
  is rebuilt from the original by `scripts/build.sh` in seconds, which made late placement changes cheap.
- **`removeAt` by position** in router output: files stay valid after a rebuild.
- **`bt escape`** and **`--grid 0.1`**: together they turned the long-net routing from "fails after
  minutes" into "works in seconds".
- **`bt drc --baseline`**: the original project has ~230 text-height warnings; seeing only what is new is essential.

## What got in the way / was wrong or confusing
1. **Courtyard overlaps are silently not checked.** The project sets `courtyards_overlap` to *ignore*.
   `bt drc` (correctly) follows the project, but I read "no errors after placement" as "no overlaps", routed
   on top of it, and found 19 overlaps much later by accident (two caps visibly on top of each other in a render).
   `bt place`/`bt drc` should say "courtyard check is off in this project" loudly, or `bt drc --courtyards`
   should force it on. (I never ran `bt place`, which reports overlaps itself - my own fault, but the trap is real.)
2. **`bt route --nets` on long nets is slow and gets stuck.** First run (48 nets, `--passes 3`) exceeded
   10 minutes and had to be killed with nothing written - output only appears at the very end, so a
   kill loses everything. Suggest: write the partial result as it goes (or on SIGTERM), and print progress
   unbuffered. Per-net time limits ("gave up after 20 s") hit about ten cross-board nets; the same nets routed in
   2–5 s each with `--grid 0.1`. A coarse-to-fine default for long connections would have saved me ~40 minutes.
3. **"boxed in" failures at 0.4 mm pitch.** With "shortest first" the router happily runs a track
   across the mouth of the neighbouring pin (CM4 connector, RP2040). The message is clear, but passes 2/3
   rarely fixed it and took minutes. Doing `bt escape` for all fine-pitch pins automatically before a
   multi-net route (or reserving each pin's exit lane) would avoid the whole class.
4. **`--rip` took 25 other tracks/vias out to route one net** (CM4_EN) and reported success for "1/2". It did keep
   everything connected, as promised, but the quality of what it re-laid is unknowable without looking;
   a one-line summary of which nets got longer / gained vias would help.
5. **Via count.** Long nets came back with 8–12 vias each. There are `--via-cost` and `--max-vias`, which I did
   not get round to trying (time), so this may be partly my own doing; a "long haul on one layer" default (escape, one
   long segment, land) is what a person does. I only approximated it with `--prefer B.Cu`.
6. **`bt pair`** on a 16 mm connection gave a 8 mm 45° diagonal and a P track that ended 0.15 mm off the
   start pad's axis with a tiny hook. I switched to my own mitred-offset generator for every pair. `pair`
   would be much more useful with "Manhattan with 45° corners" style and explicit bend points.
7. One `bt route` run wrapped in `timeout 100` was still running after 10 minutes (I did not investigate whether
   bt or my shell loop was at fault).
8. **`bt fan` on a QFN with decoupling caps placed round it** fanned 6 of 37 pins and listed the rest as
   blocked by the caps. True, but it is the normal situation; it could offer via-in-ring escapes as `escape` does.
9. `bt length --nets` patterns: `Net-(C4[89]-Pad2)` (character class) silently matched nothing.
10. stderr progress of `bt route` is block-buffered when redirected to a file.

## What I did myself instead, and why
- **Placement**: a pcbnew script with one helper (`place(ref, x, y, direction of pad 1, side)`).
  With 170 parts and a floorplan in my head, a table of coordinates was faster than 170 `bt place --move`.
- **All differential pairs and the PCIe fanout**: generated geometry. The topology (which pair hops
  layers, which gap in the M.2 pad rows each pair uses) had to be decided by reasoning about pin
  orders; once decided, exact coordinates were easier to write than to coax out of a router.
- **Skew compensation**: bumps computed from `bt length` output.
- **Buck converters**: one template, nine instances.
- **Zones**: pcbnew script (polygons with notches are awkward on a command line).

## What I would change / add / remove
- Add: courtyard check that cannot be silently off; partial output + live progress for `route --nets`;
  automatic `escape` pre-pass; coarse grid for long nets; `pair` with waypoints and a skew-fix option
  (a trombone on the short leg) - I had to script that and it is always needed after a U-turn.
- Add: `bt offset` (parallel copy of a polyline with mitred corners) and `bt bump` - both trivial, both
  things I wrote in the first hour.
- Add: a compact `bt nets` (just names and pins, no coordinates) - `bt board` was too big to read twice.
- Keep exactly as is: `probe`, `apply --checked`, `render`, `ratsnest`, `drc --baseline`, `escape`.
- I did not miss anything that I would remove; the commands I did not use were simply not needed with
  a scripted flow.
