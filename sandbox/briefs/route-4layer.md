The KiCad 10 project in /work (board file: /work/{{STEM}}.kicad_pcb) is a 4-layer board with all footprints placed but no copper routing: no tracks, no vias, no zones (the inner layers had planes; they are gone too). The schematics are in /work.

Your job: route this board so it is ready to order as a 4-layer board. Keep every footprint where it is. You can use all four copper layers, and decide yourself what goes on the inner layers (planes, signals or both). Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Rules:
- Do not move, rotate, flip, add or remove footprints. The placement is fixed.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/{{STEM}}.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: a summary of your important decisions (layer stack use, routing approach) and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
