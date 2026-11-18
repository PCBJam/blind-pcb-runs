The KiCad 10 project in /work (board file: /work/Arduino_Mega_2560.kicad_pcb) is a 2-layer board. There is no schematic file; the board's netlist (pads and their nets) is the circuit. The pin headers and sockets, the connectors, the through-hole crystal and the fiducials are already placed and locked; the mounting holes are part of the board outline. Every other footprint (all the surface-mount parts) has been moved off the board, below the outline. There is no copper routing: no tracks, no vias, no zones.

Your job: place the remaining parts on the board and route it, so it is ready to order from JLCPCB as a standard 2-layer board. Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Constraints for this board:
- Keep the board outline and the mounting holes as they are.
- Place parts on the top side (F.Cu) unless you have a good reason for the back.

Rules for every run:
- Locked footprints (already on the board) must not be moved, rotated, flipped or removed.
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/Arduino_Mega_2560.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: your placement and routing approach, the decisions you made and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
