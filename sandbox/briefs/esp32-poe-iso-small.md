The KiCad 10 project in /work (board file: /work/{{STEM}}.kicad_pcb) has every footprint placed off to one side, all on the top side, and no board outline. There is no copper routing: no tracks, no vias, no zones. The schematic is in /work.

Your job: make this board as small as you can as a 4-layer board. Place every part (connectors and mounting holes included, wherever you think they belong), draw the board outline on Edge.Cuts, and route it, so it is ready to order as a 4-layer board. You can use both sides for parts and all four copper layers. Keep the circuit's isolation requirements (it is a PoE device with an isolated supply). Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Rules:
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/{{STEM}}.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: a summary of your important decisions (placement, board size and shape, layer stack use, routing approach) and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.
