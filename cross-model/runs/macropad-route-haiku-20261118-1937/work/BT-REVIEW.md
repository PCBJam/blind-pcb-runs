# bt review (from routing macropad-top.kicad_pcb)

I used `bt` for the whole job. It is the reason the board is finished at all. Counts below are from my command history, so they are approximate.

## Commands I used, and how often

| command | about how often | what it did for me |
|---|---|---|
| `bt route` | ~60 | Every net that is not a short hand stub: USB, VBUS, CC, crystal, QSPI, +1V1, +3V3, GPIO, LED chain, +5V_LED, LED_EN, LED_DIN_3V3, GND pads. Almost always as a trial with `-o`, then applied. |
| `bt apply --checked` | ~24 | Wrote every batch (after the probe). |
| `bt probe` | ~16 | Checked my own stubs/vias, the via-spot choices, and the 3V3 pin 22 and TESTEN choices before writing. |
| `bt ratsnest` | ~14 | Per-net progress; the final "0 nets not fully connected". |
| `bt render` | ~14 | Visual check of every stage; the PNGs are in `progress/`. |
| `bt query` | ~11 | Finding the copper round a pad; the uuids for `bt seg` and `bt rm`. |
| `bt unroute` | ~10 | Taking nets out to re-route them in a new order. |
| `bt merge` | ~9 | Combining trial items before a probe-and-apply. |
| `bt rules` | ~8 | Net classes and their width/clearance/diff-pair settings. |
| `bt zone` | 4 | The F.Cu and B.Cu GND pours (`--outline`). |
| `bt check` | 5 | Final gate: "CHECK OK". It also fills the zones. |
| `bt stitch` | 3 | 61 GND stitching vias on a 4 mm grid. |
| `bt length` | 3 | Per-net lengths and layers, used for the notes. |
| `bt congestion` | 3 | Found the RP2040 escape problems before I routed (north keys, the west fan). |
| `bt escape` | 3 | The west-side fan plan (only useful as a diagnostic, see below). |
| `bt fan` | 1 | Layer plan for the north edge. Confirmed my own analysis. |
| `bt seg` | 3 | Widened the LDO 3V3 trunk to 0.3 mm (probed). |
| `bt rm` | 4 | Dry run and removal of the 3V3 interior run. |
| `bt islands`, `bt part`, `bt board`, `bt rules` (show), `bt help` | 1–2 each | Reading the board and the rules. |
| `bt undo --clean` | 1 | Removed the 20 backup copies it keeps in `.bt-undo/`. |

Not used: `bt via`, `bt near`, `bt place`, `bt silk`, `bt outline`, `bt tune`, `bt bus`, `bt pair`, `bt planar`, `bt cleanup`, `bt vias`, `bt gap`, `bt free`, `bt offset`, `bt nets`. For DRC I used `kicad-cli pcb drc` as an independent check, and bt's own `bt check` for the gate.

## What helped

- **`bt route` on whole nets.** USB D±, VBUS, CC, XOUT and the C113 node, the LED data chain (6/6), +5V_LED (15/15 links), +3V3 (22/22 at 0.2 mm, no necks), and the GPIOs (6/6 after the rip-up pass). Hand-routing that many links would have taken me far longer and with more mistakes.
- **The "blocked by" lines.** When a route failed, the output named the blocking track, pad or via with coordinates and the net. That is what let me find the USB-bridge conflict, the +1V1 vertical that boxed in pins 48/49, and the TESTEN/pin 22 conflict. The "walled in ... put one route on another layer" advice was also right every time I acted on it.
- **Trial mode with `-o`.** Compute, look at the picture and the probe, then apply. This is the way I worked for everything.
- **`bt probe` and `bt apply --checked`.** I could hand-place a stub or a via and know it was clear (or know why it wasn't, down to the 0.2 mm gap). The "fills older than the copper" warning caught a stale pour.
- **`bt render`.** The best part of the tool. The colour key (red F, blue B, gold TH, grey via) made the layer use readable at a glance.
- **`bt check`.** One line, CHECK OK, plus the KiCad DRC summary. Fast (about 16 s). I ran it before and after every batch that touched pours.
- **`bt rm --dry`, `bt unroute --dry`.** They say which net comes apart before anything is written. Essential when I was taking copper out of the RP2040 area.
- **`bt zone --outline`, `bt fill`, `bt stitch`.** Zones and stitching just worked, and `bt stitch` listed the grid points it skipped and why.
- **`bt congestion`.** Its IC-pin list ("only one way out", "none") predicted the RP2040 escape problems before I had routed them.

## What got in the way, or was wrong or confusing

0. **`bt check` said the fills were up to date when they were not (the most serious problem I hit).** After `bt seg --width .3` widened three +3V3 runs near the LDO output, `bt check` printed "fills were up to date" and CHECK OK, with 0 DRC errors. The file as saved still had the 0.2 mm-era GND fill, and KiCad's DRC on the saved file reported three clearance errors (0.15–0.19 mm against 0.2 mm). I only caught it by running `kicad-cli pcb drc` on the saved file. `bt drc --refill` would have caught it (it compares the saved fill with a fresh one), and `bt check` evidently refilled a copy rather than the file. Fix: `bt seg` (and any other copper edit) should mark the pours dirty, and `bt check` should compare against the saved fill rather than report "up to date" by default.
1. **Trial output hides the geometry.** `bt route` without `-o` prints one line per link (length and vias), but not the segments. I had to write `-o` to a file and then read the JSON to see where the copper went. A `--show` option (or printing the segments in trial mode) would save many steps.
2. **In-place writes that look like dry runs.** `bt unroute` and `bt rm` write the board in place unless `--dry`, `-o` or `--apply` is given. I unrouted XIN to test a move and had to restore it. The default for the removal commands should be a trial, or at least a louder line saying "WRITTEN".
3. **Same-net pads can't be a route's interior.** `bt route --net +1V1 --from C115.1 --to U103.45` failed with "walled in by U103.28 / U103.29" (NC pads). The real fix was `--from U103.23`: the route has to start on the pad of its own net, not on a cap next to it, and the message does not say that.
4. **`--avoid` semantics are unclear.** A keep-out box that was 0.03 mm short of the route still forced a detour. I could not tell whether the box is the track's centre line, its edge, or its edge plus clearance. I found out by trial and error. One sentence in the help would fix it.
5. **Long runs and the tool timeout.** Routes with `--seconds 60` for several nets or with passes run for minutes; my tool call timed out at 120 s, so every long run needed a background job and a polling loop. `--progress` exists, but I did not use it because I did not know it was needed. A default progress file in the working directory would be friendlier.
6. **`--shove --move-board` gives no story when it fails.** For KEY3 it ran 5 minutes, then said "no path" and listed the blockers it had tried. I could not tell which pass moved what, or why the moves did not help.
7. **`bt fan`'s layer plan is partial.** It gave "F.Cu: KEY1, KEY3; B.Cu: KEY5, KEY6" and said KEY2 had no way out, but it cannot search for a full assignment or say that none exists. It is a good diagnostic and no more.
8. **`bt escape` is blind to what is already routed.** On the west side it found only 5 of 12 pins, with "no spot ... too close to pad C110.1 (+3V3)" and similar reasons. Those reasons are right, but there is no way to say "re-plan these pins after you remove that copper".
9. **The `.bt-undo/` folder.** Every in-place write keeps a copy of the whole board (about 0.9 MB each, 20 kept). It was 23 MB in the project folder. It should live outside the project, or be capped lower, or be announced once.
10. **The router's order sensitivity.** The same six GPIO nets came out 5/6, 4/6, 4/6 or 4/6 depending on the order, and 6/6 only with rip-up on the scratch copy. That is "works if you try enough orders", and it hid the real problem (a planar crossing in a 2.3 mm corridor). A planarity check before routing a fan would have saved me an hour.
11. **Necks picked silently into the first pass.** The +3V3 first trial was 21/23 with 8 necks to 0.127 mm, and LED_EN ended with 12.6 mm of 0.127 mm. The output does say "NECKED", but the default lets it happen; I'd want `--max-neck-length 0` as the default for power nets.

## What I did myself, and why

- **VBUS east-side route with two vias.** The router's first VBUS route went down the east side on F.Cu and crossed the USB lines; its second went round the west side and needed 0.127 mm necks. I wrote the items by hand (F.Cu, B.Cu trunk, two vias) and probed them.
- **USB connector bridges.** The router solved these once I gave it the RP2040 side. For the +5 V stub and via on the ESD VBUS pin, the router could not start from a pad walled in by two USB lines, so I placed the stub and via and let the router do the B.Cu run from the via.
- **XIN.** The router tried to shove XOUT and gave up; I placed XIN by hand.
- **3V3 pin 22 and TESTEN.** Both had to share the east-side corridor. I tried several placements and probed each. In the end: TESTEN routed by the router straight into the exposed pad, and pin 22 by hand to a 0.4 mm via that lands on a decap pad.
- **ESD GND via (96.75,106.5) and the four EP vias.** Chosen by probing candidate spots (`bt probe --vias`), since the router could not reach those pads.
- **+1V1 pin 50 and SD3.** The move that fixed the west fan was mine: the 1V1 via for pin 50 moved from 103.0,108.2 to a loop round the west of the USB resistors, which left SD3 a lane.

## What I would change, add or remove

1. **A planar fan-out mode for a chip side.** Input: the pins and their destinations; output: which pins go to which layer, with vias where the crossings need them, and a yes/no if no assignment exists. `bt fan` is close, but it needs to search, not greedily assign.
2. **Same-net start pads.** Let a route start from any pad of its net, not only the pad named by `--from`. The +1V1 case above.
3. **Explicit writes for removal commands.** `bt unroute` and `bt rm` should be trial by default, like `bt route`.
4. **Show geometry in trial mode**, or a `--show`.
5. **Clear keep-out semantics** for `--avoid` (centre line, edge, or with clearance), in the help and the output.
6. **Neck policy:** `--max-neck-length 0` as the default for power classes; for signals, the neck should be reported in the summary line.
7. **Put `.bt-undo/` outside the project folder** (or cap it at a few copies).
8. **Better failure output for `--shove`/`--rip`:** which pass moved which net, and why each move did not help.
9. **A "route in planar order" option** for a group of parallel nets (the `bt bus` idea), applied to the key-corridor problem. That would have been the biggest help.

Overall: `bt` is a real help for routing whole nets and for checking hand edits. The weak spots are the planning of crowded fan-outs, where it needs a planner in front of the router, and the default write behaviour of the removal commands.
