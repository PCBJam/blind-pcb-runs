You are reviewing 3 layouts of the same circuit before one of them is ordered. They are labeled A, B, C, and each is a complete KiCad 10 project in /work/boards/<label>/ (board file: macropad-top.kicad_pcb).

Every designer worked from this job description:

---
The KiCad 10 project in /work (board file: /work/macropad-top.kicad_pcb) is a 2-layer board. The key switches and their LEDs are already placed and locked. Every other footprint, including the USB-C connector, has been moved off the board, below the outline. There is no copper routing: no tracks, no vias, no zones.

Your job: place the remaining parts and route the board, so it is ready to order from JLCPCB as a standard 2-layer board. Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit (the schematics are in /work).

Constraints for this board:
- Every part you place goes on the back side (B.Cu), the USB-C connector included.
- Make the board as small as is sensible. You may redraw the board outline (Edge.Cuts) left of the key area; the key area itself must stay inside the board.

Rules for every run:
- Locked footprints (already on the board) must not be moved, rotated, flipped or removed.
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/macropad-top.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: your placement and routing approach, the decisions you made and why, and anything you know is not finished or not good.
---

Review the boards the way a senior hardware engineer reviews a layout before it goes to the fab. Open the files and measure; don't judge from the file size or the formatting. For every board, score each category from 1 (unacceptable) to 10 (excellent) and back each score with concrete findings (net names, references, coordinates in mm):

1. EMI: return paths and ground continuity under signals, loop areas (supply input, regulators, switching loads, crystal, USB), slots and splits, stitching, traces near the board edge.
2. Signal integrity: the USB pair and any other fast or sensitive signals (clock, crystal, flash/memory buses): length matching, coupling, reference plane, layer changes, stubs.
3. Power: track widths for the currents involved, decoupling placement and loop, regulator layout.
4. Placement: grouping, decoupling distance, connector access, mechanical sense, assembly. If the job fixed the placement, give null here.
5. Routing and manufacturability: DRC, via count and use, acute angles, neck-downs, silkscreen, fit with a standard JLCPCB 2-layer order.

Then give each board an overall score (1 to 10) and rank all boards, best first, with your reasons.


Write two files:
- /work/REVIEW.md: your findings and reasoning per board and the ranking.
- /work/review.json: {"scores": {"<label>": {"emi": n, "si": n, "power": n, "placement": n or null, "routing": n, "overall": n, "summary": "one or two sentences"}, ...}, "ranking": ["<best label>", ...]}

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed, and `bt` (run `bt --help`) can measure and render boards. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI. Don't change the boards in /work/boards; copy them first if you want to experiment.

Work on your own until the review is finished; nobody will answer questions.
