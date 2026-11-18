# Retrospective: macropad-top place and route (35 min, $12.27, 33 turns)

Basis: the transcript record and NOTES.md. The record shows tool calls but not the content of my thinking, and my scripts were in `/tmp/w`, which was not kept, so script details come from the truncated calls.
All savings figures are rough estimates, not measurements.

## 1. Tools I built for myself

| Tool | What it did | Want ready-made? |
|---|---|---|
| Inline dump scripts (steps 3, 5, 7, 18, 26) | Footprints, pad positions/sizes/nets, net-to-pad list, courtyard boxes, footprint graphics, design settings | **Yes**: one "board facts" call |
| `render.py` / `view.py` | `kicad-cli` SVG export, then cairosvg (pip-installed) to PNG, cropped to a window in board mm at a chosen px/mm | **Yes**: I needed it for every visual check |
| Schematic SVG to PNG | To read the circuit as a picture | Yes, or better a text netlist with pin names |
| `lib.py` (class `B`) | `place`, `place2` (put a named pad at a point), `tr`, `via`, `P(ref, pad)`, `fill`, `save` over `pcbnew` | **Yes** |
| `build.py` | The whole board as one script, rebuilt from the untouched original each run | Keep the pattern; the content is board-specific |
| `drc.sh` + report filter | DRC with parity, grouped, known library-mismatch note dropped | **Yes** |
| Stitching-via generator (step 42) | Grid candidates kept only where both pours exist with margin | Yes |
| Invariant check (step 48) | Locked parts unmoved, nothing outside the outline, list of back-side parts | **Yes** |

## 2. Tools that would have saved the most, ranked

The run had only about four build/DRC rounds, so tool output was cheap.
The cost was in working out the floorplan and every coordinate by hand before step 23, and again at each fix.

1. **Point-to-point router: `route(net, from_pad, to_pad, layer prefs, width)`.**
   Returns the track/via geometry or "blocked by X". Obstacle- and clearance-aware, under 1 s per connection.
   I would still choose order, layer and topology; it removes the coordinate arithmetic.
   Estimated saving: 40–50% of cost and time.
2. **Fan-out / escape helpers for the hard parts.**
   QFN-56 escape with an inner power ring and decoupling vias, USB-C duplicate-pad bridging, a bus router for the six QSPI lines.
   Input: footprint and pin groups; output: stubs and vias. A few seconds each.
   Estimated saving: 10–15% (these were the densest hand calculations and the source of the QSPI clearance errors).
3. **Placement helper with live courtyard and clearance check.**
   `place(ref, x, y, rot, side)` returns overlaps and resulting pad positions at once; plus "put this cap next to pin N of U103".
   Under 200 ms. Would have removed the first DRC round's courtyard overlaps and the flipped resistor.
   Estimated saving: 10%.
4. **Incremental DRC as structured JSON** (type, nets, refs, x/y, required vs actual clearance), under 2–3 s, with a baseline diff so pre-existing messages are hidden.
   Estimated saving: 5%.
5. **One-call board summary** (item 1 of the table) and a **schematic digest** (per IC: pin name, net, neighbours; chains such as LED data order).
   Replaces steps 3–18, about six turns. Estimated saving: 5–8%.
6. **Windowed renderer** (`render(layers, bbox, px/mm)` giving a PNG with pad and net labels), under 2 s.
   Saves the setup and one pip install; small token saving, about 2–3%, but better checks.
7. **Autorouter for the easy nets** (keys, LED chain, rails) once the critical area is done by hand.
   I looked for Java/freerouting at step 9 and it was not there. Perhaps 5%, with a review cost.
8. **Ground stitching and return-path report** (plane cuts under signal tracks).
   Saves little time, but would have turned my "known weaknesses" list into something measured.

## 3. Hardest parts and back-and-forth

- **The floorplan around the RP2040.**
  Choosing its rotation so USB, QSPI, crystal, LED and key pins all face the right way, with all 30 parts in a 30 × 27 mm block, was decided in my head with no way to test a candidate cheaply.
  A quick ratsnest length/crossing score per candidate placement would have made that a few fast trials.
- **First build (step 23) was written blind as one large script.**
  It came back with courtyard overlaps, one resistor facing the wrong way, QSPI fan-out clearance errors and unconnected LED-cap grounds (step 28).
  Building in stages with a check after each (placement, then MCU core, then the rest) would have caught these earlier and smaller.
- **Nudging the LDO group three times** (U101 from y 115.4 to 117.0 to 117.25, with C102–C104 and their tracks).
  Every move meant hand-editing dependent track coordinates by string replacement.
  Tracks defined relative to pads, or a router, would have made the move a single edit.
- **Enclosed pins.**
  The flash VCC inside the QSPI lines and U102 pin 5 inside D+/D− forced back-side hops that cut the ground plane.
  I saw this only after routing; a planner flagging "this pin will be enclosed" would have let me pick a different pin order or placement.
- **Ground vias near the crystal and LDO** needed two relocation rounds (step 31) for clearance.

## 4. Brief and environment

- **No renderer installed.** No rsvg/inkscape/ImageMagick; I had to pip-install cairosvg and write the crop script.
- **No autorouter** (no Java, no freerouting).
- **A pre-existing DRC message** (library mismatch on U103) had to be identified and filtered each round; a stated baseline would help.
- **J101 overhangs the board edge by design**, which tripped my own "inside the outline" assertion at the end (step 47) and cost a check.
- **"The way an experienced designer would"** has no stated measure, so I spent effort on stitching, decoupling on the back and notes without knowing how they would be weighed.
  A short list of what will be checked (plane integrity, decoupling distance, USB routing, silkscreen) would focus the effort.
- **I worked in `/tmp/w`**, so the scripts did not survive with `/work`. That was my choice; next time I would keep them in the working directory.
- The brief was otherwise clear, and the locked/unlocked split was easy to read from the board.
