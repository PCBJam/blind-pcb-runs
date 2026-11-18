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

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed, and a KiCad MCP server (`kicad`, with a Freerouting autorouter) is connected. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
