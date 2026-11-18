# Looking back at the macropad run (77 min, $25.90)

Source: `brief.md`, `NOTES.md` and `timeline.txt`. The transcript is shortened and my thinking blocks are empty in it, so the savings estimates below are my judgement, not measurements. My scripts lived in `/tmp/w`, which is gone; only their creation shows in the timeline.

## 1. Tools I built, and which I want ready-made

| Tool (step) | What it did | Want ready-made? |
|---|---|---|
| `sx.py` [9] | S-expression parser to read the schematic (symbols, values, sheet text) | Yes, as a netlist/schematic summary |
| ad-hoc dumps [4, 6, 11, 21, 23] | Footprints, pads, nets, courtyards, lock state in mm | Yes, as one "board state" JSON call |
| `render.py` / `view.py` [17, 35] | `kicad-cli` SVG → PNG crop of a mm window, with ref labels | **Yes**, used about 10 times |
| `lib.py` + `place.py` [26, 28] | Placement table `ref: (x, y, rot)`, flip to B.Cu, redraw outline | Yes |
| `fw.py` [45] | `tr(net, [points or 'REF.pad'], width, layer)`, `via`, zone fill, DRC run + summary | **Yes**, the core of the run |
| `routes.py` [56] | Every track as hand-typed coordinates | No: this is the thing to replace |
| `islands.py` [74] | Finds pour islands and their via count | Yes |
| `iter.py` [84] | Rebuild all → fill → DRC in one command | Yes |
| lock check [88] | Diffs locked footprints against the original | Yes, tiny but mandatory every run |

## 2. Tools that would have saved most, ranked

1. **Pad-to-pad router** (biggest saving; my guess 25–35 min and about half the cost).
   - In: net or pad pair, layer preference, width, optional waypoints or keep-out boxes.
   - Out: tracks/vias committed, or "blocked by X at (x, y)".
   - Speed: under 5 s per net; a whole-board pass under 1–2 min is fine.
   - Even a plain grid/A* router that respects clearance would do. A working Freerouting round trip (DSN out, SES in) would cover the key matrix, LED chain and power rails, which were most of the coordinate typing. I never tried it; I do not know whether it runs in this sandbox.
2. **Clearance query before commit** (guess 10–15 min).
   - In: a proposed segment, via or footprint position.
   - Out: nearest foreign copper/courtyard with distance and coordinates.
   - Speed: under 1 s. Today each check was a full rebuild + zone fill + `kicad-cli drc`, and steps [69]–[71] are three such rounds to shift a bundle by 0.1 mm.
3. **Placement helper** (guess 8–12 min).
   - In: ref, target region or "next to REF.pad", side.
   - Out: legal positions/rotations with no courtyard overlap, plus the resulting pad coordinates and ratsnest length.
   - Five placement passes ([38], [47], [50], [53], [58]) were mostly fixing overlaps and wrong rotations I had worked out by hand.
4. **Board state as JSON in one call** (guess 5 min): footprints, pad positions with nets, courtyards, outline, free rectangles between locked parts. Replaces five survey scripts.
5. **Windowed render** (guess 3–5 min): `view(x0, y0, x1, y1, layers)` → PNG with refs, pad numbers and net names, under 3 s. I had to install `cairosvg` and write it twice.
6. **DRC summary** (guess 2–3 min): counts by type plus coordinates, diffed against the previous run and against the original board.
7. **QFN fan-out / decoupling helper** (guess 3–5 min): stub out of each pin with a via, and report cap-to-pin distance per supply pin. Would also have caught the pins I left without a nearby cap.

## 3. Hardest parts and back-and-forth

- **Floorplan in the left strip.** I weighed USB on the top edge against the left edge, and the MCU rotation, in my head from pad coordinates before seeing any picture. A placement helper with ratsnest length would have turned this into two or three quick trials.
- **Rotations after flipping to B.Cu.** Several parts came out 180° or 90° wrong ([50], [64], [67]: the crystal was rotated three times, and its GND pad numbers were swapped in [74]). A call returning pad positions for a proposed rotation would have prevented all of it.
- **MCU escape.** The 3V3 ring inside the QFN pad ring, the 1V1 link and six key lines round the crystal were fitted at 0.16–0.2 mm with 0.5 mm vias, found by DRC trial and error.
- **Key bundle at the bottom edge.** Three rounds of 0.05–0.1 mm shifts ([69]–[71]) against the edge clearance.
- **Placement moved after routing began** ([58], [64]), so the USB and crystal routes were rewritten. Hard-coded coordinates make every placement nudge expensive; routes tied to pads would not.
- **Pour islands and stitching.** Found only after writing `islands.py`; one via nudged at the very end ([84]).

## 4. Brief and environment

- **pcbnew crash [28]:** removing Edge.Cuts drawings and then touching footprints gave stale SWIG objects and a segfault. Fixed by reordering and using `Delete`. A note on this in the brief would save a round.
- **No SVG rasteriser installed**; `cairosvg` needed a pip install through the proxy [14–15].
- **DRC needs the whole project next to the board** (`.kicad_pro`, `.kicad_dru`, schematics, footprint library), so I built a copy in `/tmp/w/proj` [45]. The `.kicad_dru` rules and the pre-existing U103 library warning had to be discovered; one line each in the brief would help.
- **"As small as is sensible" and "the way an experienced designer would"** are open-ended. I spent thinking time on connector edge choice and how far to push decoupling, with no way to know how they would be weighed. A stated priority order (size vs. plane integrity vs. USB edge) would shorten that.
- **No GUI and no interactive router** is the root cause of the cost: every track was a typed polyline, and every check a full rebuild.
