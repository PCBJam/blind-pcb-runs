# bt – review after routing the OrangeCrab (ECP5 csBGA285 0.5 mm + DDR3 BGA, 6 layers)

Short version: the *look/check/write* half of bt is excellent and I used it constantly; the *router* half is fine for open areas and easy nets but could not solve this board's two hard spots (0.5 mm BGA escape next to a DDR3 bus), and that is where most of my time went. I ended up writing my own table-driven fan-out generators, a small exact clearance checker and a grid maze router, and used bt to verify and apply their output.

## What I used (approximate call counts)

| command | calls | verdict |
|---|---|---|
| `bt apply --checked` | ~45 | **Best feature.** Every piece of script-generated copper went through it; nothing illegal ever reached the board. |
| `bt probe` | ~35 | Same engine, used to iterate generators. Messages are precise (net, object, gap). Agreed with my own checker to the micron. |
| `bt route --nets / --batch / --net --all` | ~40 | Mixed, see below. |
| `bt render` | ~30 | Indispensable without a GUI. `--box`, `--layers`, `--pads` are the right options. |
| `bt query` / `bt vias` | ~20 | Good for "what is in this corner"; uuid prefixes make `bt rm` easy. |
| `bt ratsnest` / `bt nets` / `bt board` | ~20 | `bt board` as first command gives the whole picture in one go. |
| `bt unroute` / `bt rm` | ~20 | Reliable; the "comes apart: …" summary is useful. |
| `bt zone` / `bt fill` | ~15 | Worked first time, incl. priorities and polygons. |
| `bt plane` | 7 | Very good: ~80 power/ground vias placed with sensible reasons for every pad it skipped. |
| `bt islands --fix` | 7 | Good; joined most leftover supply pieces. |
| `bt rules` | 8 | Good; only touches the .kicad_pro. |
| `bt fan` | 2 | Not usable here (see below). |
| `bt cleanup`, `bt length`, `bt drc`, `bt check` | a few each | Fine. |
| `bt pair`, `bt bus`, `bt tune`, `bt escape`, `bt stitch`, `bt planar`, `bt congestion`, `bt offset`, `bt near/place/outline/silk` | 0–1 | Not needed or not reached (ran out of time before tuning/stitching). |

## What helped most

- **probe / apply --checked / undo**: I could generate hundreds of segments by script and trust the result. This is what made hand-planned BGA fan-outs practical. Saved hours and certainly many DRC rounds.
- **bt plane + bt islands**: turned "connect 260 power pads to planes" into a few commands; the per-pad explanations ("in the way out of U5.6", "too close to pad …") are exactly what one needs.
- **render**: fast, readable, layer colours consistent. I looked at ~30 crops.
- **bt route for open-area nets** (power stage, DDR links once both ends were fanned out and ordered): 28 DDR links of 2.5–6 mm in 35 s, good 45° geometry.
- Error texts in general: they name the object and coordinates; "start is boxed in", "walls in U3.B4" told me what was wrong even when the router could not fix it.

## What got in the way

1. **`bt route --nets` on dense BGA escapes.** Typical result: 60–75 % of the nets, 7–9 minutes per run, the rest "could not be put back after moving it" or "start/target is boxed in for a 0.1 mm track". The router is greedy per net: the first nets take vias and diagonals right in front of the neighbouring 0.25 mm-pitch lanes and there is no global view of "these 18 lanes all need to get out". Changing `--order` just moves the failures around. For the DDR switchbox it produced 13–29 mm detours for 6 mm links until I pre-placed every inner-ball via and seeded the awkward nets by hand.
2. **`bt fan` on the 0.5 mm csBGA285 and on the DDR3 BGA.** It fans out in all four directions and gives every poured-net ball its own via (134 of them under the FPGA); it knows nothing about where the nets have to go, about back-side decoupling caps sitting on the via sites, or about keeping inner-layer lanes free. On this board the fan-out *is* the routing problem, so I wrote it by hand (slot tables). A `--toward U3` / per-side layer assignment / "vias only on these rows" mode would have made it useful.
3. **Width floor and necks.** `--width` cannot go below the class width and a boxed-in end is necked, but a lane end between two other 0.089 mm lanes at 0.178 mm pitch is reported as "boxed in for a 0.1 mm track" even with `--neck-min .089` and a `--neck` box. I had to lower the class width to get anywhere, and even then several lane ends stayed "boxed in" although a 0.089 mm continuation existed.
4. **Grid vs. exact geometry.** Copper I placed at exactly the minimum pitch (0.178 mm) made the router fail with "breaks clearance where the grid missed it: … 0.0835 mm". Honest message, but it means hand-seeded copper needs ~10 µm of slack to be usable by the router.
5. **Speed.** 7–9 minutes for 29 nets near the BGA (10 s per search × shove/rip-up passes). `--batch` (no rip-up) is fast but leaves "target boxed in" when two slot-neighbours approach diagonally. My own plain A* (no shove) did the same nets in under a minute – with the same failures, to be fair.
6. **`--max-detour` was ignored in `--nets` mode** (links of 5–6× the straight distance were accepted with a warning only), and `--avoid` boxes that contain the start made every net "boxed in" without saying that the avoid box was the reason.
7. **bt apply --checked is all-or-nothing** for a file: one bad segment rejects 600 good ones. A `--skip-bad` (apply what is clean, list the rest) would have saved me writing a per-net loop.
8. Minor: `bt cleanup` prints "trial only" unless `--apply` is given even though the help reads as if it writes in place; `bt route` output in `--nets` mode repeats the summary line three times.

## What I did myself, and why

- **Table-driven fan-out generators** for U4 (every ball to a half-row via, tracks in fixed row slots on In2/B.Cu) and for U3's power/ground (site map against the back-side cap pads). bt has no way to express "vias on half-rows, two tracks per row, this net on this layer".
- **A 150-line exact clearance checker** (segments/circles/rects, hole rules) so generators could test candidates without one bt call each. It disagreed with bt only on oval pads (U9), which I had modelled as boxes.
- **A grid maze router** (0.025 mm grid, A*, 45° smoothing against the exact checker) for the last stage. Fast, but it shares the fundamental limit: without a lane-aware fan-out plan the last ~7 nets on each BGA side stay trapped.

## Late findings

- Naming a plane layer in `--layers` (In3) connected P2.5V and VREF in seconds after every attempt on the three signal layers had failed, and got four more nets. That the router keeps off plane layers by default is right, but when a net fails it would help if the failure said "a path exists if In3 may be used".
- `bt check` and `bt drc --refill` crashed on the finished board ("Maximum call stack size exceeded"); plain `bt drc --baseline` on the same board worked.
- A router-made track for Net-(D1-Pad4) ran straight across the plated pad of mounting hole H1 (no net) – bt's own clearance model did not treat that pad as an obstacle; KiCad DRC reported "shorting items".
- End result for honesty: 23 of 143 signal nets are still open. I do not think that is bt's fault alone – I spent too long on the DDR corner – but every one of them ends in "start/target is boxed in", i.e. the missing piece is escape planning, not path finding.

## What I would change or add

- A **BGA escape planner that knows destinations**: per side, which balls leave on the top layer through which gap, which get a via on which interstitial row, with a capacity check ("this side is 2 escapes short") *before* any copper is placed. `bt congestion`/`bt planar` hint at this but do not produce an assignment.
- **Channel/slot routing between two fanned-out parts**: given ordered stub ends on both sides, assign via columns (front-layer verticals, inner-layer horizontals). This is a textbook problem and it is exactly what the DDR bus needed.
- `bt apply --checked --skip-bad`; `bt route --width` below class width with an explicit flag; make `--max-detour` binding everywhere; say when an `--avoid` box contains an endpoint.
- Let `bt fan` take `--via-rows`/`--no-via-on-pads NET-mismatch` awareness of back-side parts (it did report the clashes, which was useful as a map).
- Keep everything in probe/apply/plane/islands/zone/render exactly as it is.
