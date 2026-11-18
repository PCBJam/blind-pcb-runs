The KiCad 10 project in /work (board file: /work/Arduino_Mega_2560.kicad_pcb) has all footprints placed but no copper routing: no tracks, no vias, no zones. There is no schematic file; the board's netlist (pads and their nets) is the circuit.

Your job: route this board so it is ready to order from JLCPCB as a standard 2-layer board. Route it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit and decide your own approach: track widths, layer use, copper pours, via use, and so on.

Rules:
- Do not move, rotate, flip, add or remove footprints. The placement is fixed.
- You may add tracks, arcs, vias and zones, and you may edit the net classes and design rules if you have a reason to.
- Save the result in place as /work/Arduino_Mega_2560.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: your approach, the decisions you made and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
