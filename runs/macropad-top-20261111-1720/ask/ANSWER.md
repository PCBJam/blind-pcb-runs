# Looking back at the macropad-top routing run

Source: the transcript, my scripts in `routing-scripts/` and NOTES.md. The transcript does not keep the
content of my thinking steps, so the time/token split per phase below is my estimate, not a measurement.
Of 32 turns, about 15 were thinking-only; the tool calls themselves were short.

## 1. Tools I built for myself

| Tool | What it did | Want ready-made? |
|---|---|---|
| Board dump one-liners (steps 2–7, 16, 19) | Footprints, every pad with net/position/size/layer, edge cuts, LED cut-out boxes, rules from `.kicad_pro` | **Yes**, as one call. I spent 6 calls getting to a full picture. |
| `lib.py`: `T(net, layer, width, pts)`, `V(net, x, y)`, `P(ref, pad)`, net aliases | Add a polyline track or via by net name in mm | Yes, but it is 56 lines; cheap to rewrite. |
| `build.py` | Rebuild from the untouched board + all `r*.py` each time, so every fix was a replay, never an edit of a routed board | Yes (the pattern matters more than the code). |
| DRC JSON summariser (steps 9, 31–36, 51) | Run `kicad-cli pcb drc`, count by type, print items with coordinates | **Yes.** |
| `render.sh` | SVG export → PNG via cairosvg (pip-installed), optional crop window | **Yes**; no rasteriser was installed. |
| `r5_zones.py`, `r6_stitch.py` | GND pours on both layers; stitching vias only where both fills are solid, with spacing check | Yes; generic, reusable as is. |
| Placement-unchanged check (step 51) | Compare ref/position/rotation/side against the original | Yes; trivial but mandatory. |

What I did not build, and should have: any geometric query or router. Every coordinate in
`r1`–`r4` (about 330 lines) was worked out in my head from the pad dump.

## 2. Tools that would have saved the most (ranked)

1. **Point-to-point router: `route(net, from, to, layer_prefs, width, clearance, keepouts)` → track
   segments + vias, or "blocked by X at (x,y)".** Pad refs or mm points in; DRC-legal path out; under
   ~2 s per connection. A grid A* over the current copper would do; a push-and-shove router is not
   needed. I would still decide the floorplan, layer roles and order; the tool does the coordinates.
   Estimate: removes 50–60 % of the run (25+ min, $7–9), since the coordinate planning in steps
   14–17, 20–27 was the bulk of the thinking.
2. **Fanout/escape helpers for the repeated patterns:** "via + stub for every GND pad", "decoupling
   cap to pin through via", "bus of N nets from these pins at pitch p along this path". Same shape of
   input, returns the items added. Six LED cells and six key cells are identical, and the RP2040
   decoupling is a pattern. Estimate: 10–15 % on its own, overlapping with 1.
3. **Clearance probe: `check(segment or via, net)` → ok / nearest offender and distance**, in
   milliseconds, without saving and running the full DRC. The first DRC round (step 31–36) found
   shorts and tight clearances from my hand coordinates; each fix was a string-replace in a script,
   a full rebuild and a full DRC. Estimate: 5–10 % (3–5 min, about $1).
4. **Board summary in one call:** JSON with pads grouped by net, ratsnest lengths, per-net pin list
   with pin functions, outline, cut-outs, rules, which side each footprint's pads are on. Under 5 s.
   Estimate: 5 % (saves 5 calls and the re-reading of long dumps).
5. **Render to PNG with crop and net highlight:** `render(layers, bbox, highlight_nets)` → PNG in
   under 3 s. I built this; ready-made saves 2–3 minutes and the pip install. A ratsnest overlay
   before routing would have helped the floorplan more than the plain plot did.
6. **DRC as structured, diffable output:** violations grouped by type with coordinates and
   "new since last run". Saves about 1–2 minutes; mostly convenience.

Speed matters most for 1 and 3: they would be called hundreds of times, so they must return in a
second or two. The others are called a handful of times each.

## 3. Hardest parts and back-and-forth

- **The area under and around the RP2040.** Decoupling caps sit on the back under the chip, so +3V3,
  +1V1 and ground vias compete for the same few square millimetres. The result is the weakest part
  of the board (cut-up ground on the back, vias touching cap pads; both are in NOTES.md). A router
  with a clearance probe would have let me try alternatives; by hand I took the first layout that fit.
- **USB-C connector pads.** The interleaved D+/D- pads cannot be joined on one layer; I settled on a
  back-side hop for D-. Found by reasoning, not by trying.
- **LED_EN and LED_DIN_3V3.** The pinout puts them behind the QSPI fanout, so they take a ~45 mm detour.
  I corrected the overlap length in NOTES.md at the last step (13 mm → 8–10 mm), which shows I was
  estimating geometry from memory instead of measuring it.
- **First DRC round.** A few shorts and clearance errors from mental arithmetic (steps 31–36), fixed
  by patching coordinates as text. Two rounds were enough, but each was a guess-and-rerun.
- **Scratch project setup.** I ran DRC in `/tmp/w` and had to copy the `.kicad_pro`, `.kicad_dru`,
  schematics and footprint library next to the board twice (steps 31, 34) before rules and parity
  applied. At step 29–31 I also found the `.kicad_pro` in /work had been rewritten by a tool run and
  restored it from my backup.

What would have prevented most of it: tools 1 and 3, and working on a full copy of the project
directory from the first minute.

## 4. Brief and environment

- The brief was clear; "route it as a designer who cares" with no acceptance list meant I chose my own
  bar (DRC clean, parity clean, pours, stitching, notes on weaknesses). A stated checklist would have
  shortened the review phase slightly, not much.
- No PNG rasteriser was installed; cairosvg from pip worked through the proxy.
- No autorouter (e.g. Freerouting, which needs Java) was present, and I did not try to fetch one. With
  one available I would have hand-routed only USB, crystal and power, and let it do keys and LEDs.
- `kicad-cli` touches project files beside the board (`.kicad_pro`, `.kicad_prl`); I removed the
  `.kicad_prl` at the end. That file is still listed in /work now, so something recreated it later.
- The pcbnew Python API for KiCad 10 has no documentation in the sandbox; small things (via width
  per layer, filled-polygon access) I got right from inspection, but that cost some probing.
- My scripts use `/tmp/w` paths, which did not survive; they are kept for reference and will not rerun as is.
