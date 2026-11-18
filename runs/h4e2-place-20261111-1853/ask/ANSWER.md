# Looking back at the H4E2 run (62 min, $21.67)

Source: `timeline.txt` and `NOTES.md`. My scripts lived in `/tmp/w`, which no longer exists, so their
description is reconstructed from the transcript (calls and edits), not from the files. The transcript
shows that I was thinking but not what I thought; the time and token figures below are my estimates.

## 1. Tools I built for myself

- **`lib.py`**: a wrapper over `pcbnew` with these helpers:
  - `P(ref, x, y, rot)` places a part on B.Cu.
  - `S(net, layer, width, [points or 'REF.pad'])` adds a track; `R(...)` is a pad-to-pad variant.
  - `V(net, x, y)` adds a via.
  - Others create and fill the zones, run `kicad-cli pcb drc` to JSON, and print a filtered summary
    (types, positions, unconnected items with GND noise removed).
- **`place.py`**: every placement as a literal `P(...)` line, rebuilt from the original board each run.
- **`route.py` / `route2.py`**: every track as hand-written coordinates (ADC and channel first, then
  the rest).
- **`finish.py`**: ground stitching vias with obstacle checks, silkscreen value repositioning, zone
  fill, final save and an invariants check against the original (locked parts, outline, nets).
- **Render pipeline**: `kicad-cli pcb export svg`, then `cairosvg` to PNG (pip-installed at step 12),
  with cropped region views (`v_adc`, `v_tl`, `v_keys`, …) that I read as images.
- **One-off dumps**: pad/net tables, pad offsets per footprint type, courtyard boxes, outline holes,
  and track length per net for the notes.

Wanted ready-made next time: the board dump, the render-region-to-PNG tool, the DRC summary and diff
against baseline, the invariants check, and the stitching and silkscreen passes. None of these is
specific to this board, and I rewrote all of them from scratch.

## 2. Tools that would have saved the most (ranked)

1. **Constrained interactive router: "route net N from pad A to pad B".**
   - Input: layer, width, optional waypoints or keep-out corridors.
   - Output: the path, or the blocking object with its coordinates.
   - Speed: under 2 s per call, obeying the `.kicad_dru` clearances.
   - Why: I computed about 2200 mm of track as coordinates in my head, in three big script writes
     (steps 35, 43, 66) with long thinking before each.
   - Saving: 25–30 min and about half the cost ($9–11).
   - A batch autorouter (Freerouting; I checked for `java` at step 12 and it was not there) would do
     for the digital nets, about half of that saving. I would still want to steer analog and power.
2. **Placement helper: "put C2009 next to U2002 pin 15, on this side, B.Cu".**
   - Output: a courtyard-legal position and rotation, plus a fast courtyard/overlap check (under 1 s,
     without a full DRC).
   - Why: I placed 62 parts by mental arithmetic on pad offsets and then nudged them by 0.1–0.6 mm
     after DRC (steps 32, 40, 79).
   - Saving: 8–10 min, $3–4.
3. **Board state query in one call**, as JSON or a compact table, under 2 s.
   - Contents: outline, free areas, locked footprints with pad positions and nets, courtyards,
     ratsnest lengths per net given the current placement, and schematic grouping (which caps belong
     to which IC pin).
   - Why: steps 3–16 were six separate dump scripts plus reading the schematics by grep.
   - Saving: 4–5 min, $1.5–2.
4. **Render tool: `render(region, layers, mirror)` to PNG**, under 3 s, with reference and net labels
   drawn on it.
   - Why: I read about 15 images, and each needed an export/convert command.
   - Saving: 2–3 min, $1. More if labels spared me cross-referencing coordinates.
5. **DRC delta: "new violations since baseline", grouped, with coordinates and both items.**
   - Why: I only ran DRC on the untouched file at step 71 to learn which warnings were pre-existing.
   - Saving: 2 min, $0.5–1.
6. **Finishing passes as ready commands**: stitch GND vias (grid plus one per pour island) and
   de-overlap silkscreen. Saving: 3–4 min, $1–1.5.

## 3. Hardest parts and back-and-forth

- **Floorplan before any feedback.** I settled the floorplan and net topology in one long thinking
  step (17) and then had to revise it once routing started. At step 40 U1001, R1001 and C1003 moved
  from the top left to below the XIAO, and several other parts moved with them. A ratsnest or
  crossing count per candidate placement would have shown this before I wrote the routing.
- **XIAO pin interleaving and the ADC pin order.** The display and ADC signals alternate on the
  module pads, and the ADC inputs are in the opposite order to the keys. Solving that without
  crossings (the channel under the module, entering under the SOIC) was pure head work. A router
  that reports "blocked by X" would have turned it into a few trials.
- **Coordinate errors in hand-written tracks.** After each routing write came rounds of string-replace
  patches (steps 47, 49, 63, 83) for clearance misses and unconnected ends.
- **Silkscreen.** Value texts over pads and copper took steps 69–79, including moving one capacitor
  (C26002) to clear a label. A de-overlap tool would have removed this.
- **Zone islands and stitching.** I switched island removal from ALWAYS to NEVER late (step 91) and
  re-ran the finishing pass. I also added a late keep-out under the XIAO for vias and text (step 103).
- **Notes written from memory.** Step 110 corrected lengths in `NOTES.md` after I measured them.
  I should have measured before writing.

## 4. Brief and environment

- **Open-ended quality bar.** "The way an experienced designer would" has no stated checks. I spent
  thinking on things like LED rail topology and analog isolation without knowing their weight.
  That is fair for the task, but it cost time.
- **Pre-existing DRC noise** was not mentioned: 10 library warnings, the excluded NPTH item and the
  logo parity warnings. A line in the brief or a baseline report would have saved a detour.
- **Missing tools.** There was no image converter (pip install needed) and no Java or autorouter.
  The `pcbnew` API needed probing: `GetBoardPolygonOutlines` failed on its signature at step 19.
- **Schematics only as raw `.kicad_sch`.** There was no netlist or PDF export in the folder, so I
  recovered design intent (for example the "end of the LED rails" note) by grep.
- **Each iteration was a full rebuild** (place, route, fill, DRC) from the original file. That is
  robust, but the loop took tens of seconds, and every small nudge paid for it.
- Nothing was blocked that I needed. The proxy only saw the PyPI download.
