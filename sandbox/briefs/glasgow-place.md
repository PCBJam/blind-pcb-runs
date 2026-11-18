The KiCad 10 project in /work (board file: /work/{{STEM}}.kicad_pcb) is a 4-layer board. The board outline, the mounting holes and the connectors (USB-C, the two IDC headers, the power and sync headers and the expansion connectors) are already placed and locked. Every other footprint has been moved off the board, below the outline, all on the top side. There is no copper routing: no tracks, no vias, no zones. The schematics are in /work.

Your job: place the remaining parts and route the board, so it is ready to order as a 4-layer board. Keep the already placed parts where they are. You can use both sides for parts and all four copper layers. Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Rules:
- Locked footprints (already on the board) must not be moved, rotated, flipped or removed.
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/{{STEM}}.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: a summary of your important decisions (placement, layer stack use, routing approach) and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
