The KiCad 10 project in /work (board file: /work/ESP32-PoE-ISO_Rev_O.kicad_pcb) is a 4-layer board. The board outline with its cutouts, the mounting holes and the connectors (Ethernet jack, micro-USB, microSD, UEXT, the two extension pin rows and the battery connector) are already placed and locked. Every other footprint has been moved off the board, below the outline, all on the top side. There is no copper routing: no tracks, no vias, no zones. The schematic is in /work.

Your job: place the remaining parts and route the board, so it is ready to order as a 4-layer board. Keep the already placed parts where they are. You can use both sides for parts and all four copper layers. Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Rules:
- Locked footprints (already on the board) must not be moved, rotated, flipped or removed.
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/ESP32-PoE-ISO_Rev_O.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: a summary of your important decisions (placement, layer stack use, routing approach) and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.


Board tools: `bt` is installed (run `bt help`). It reads a .kicad_pcb and the rules next to it and answers in short text, without writing anything unless you ask. The tools:
- `bt board` prints the whole board in one go: rules, parts, every net with its pads, and the ratsnest.
- `bt congestion` shows, before you route, where it will be tight: which nets' connections cross, where more connections pass than tracks fit, and which IC pins have one way out or none.
- `bt route` routes one connection pad to pad, or a net's missing links, on the layers and through the points you give. It returns the track and via coordinates for your own scripts, or names what blocks the route and where. With `--shove` it pushes tracks routed earlier out of the way (or `--rip` reroutes them), and undoes everything if they can't be put back.
- `bt cleanup` straightens small jogs in tracks already on the board.
- `bt escape` adds a stub and a via per pad.
- `bt probe` checks proposed tracks or vias for clearance before you commit them.
- `bt place` and `bt near` try placements without saving them.
- `bt render` draws a labelled PNG of any window.
- `bt drc --baseline` runs KiCad's DRC and shows only the new violations.
- `bt same` checks that locked parts didn't move.
- `bt apply` writes tracks and vias into the board as text.

You decide the floorplan, the layer use and the order; the tools do the coordinates and the checks. Use them or not, as you see fit.

Good to know: saving a board through pcbnew can rewrite the .kicad_pro next to it with defaults. Keep a copy of it, or write copper with `bt apply`, which only touches the board file.

Progress log: keep a visual log of how the board develops in /work/progress/. Each time you reach a step worth seeing (a placement attempt, a routing stage, a DRC round, a change of plan), save a numbered pair: a picture of the board (or of the area you worked on) as NNN-<short-name>.png and a short NNN-<short-name>.md with what you did, why, and what the result was. Number them in order (001, 002, ...). Keep the attempts that failed or that you threw away too, and say in their note why they failed. Aim for one entry every few minutes of work, not for every command.

`bt` is experimental, and we want your honest opinion of it. After the board is finished, write /work/BT-REVIEW.md: which bt commands you used and how often, which helped and how much (time, tokens, fewer mistakes), which got in the way or gave wrong or confusing answers (with the command and what happened), what you did yourself instead and why, and what you would change, add or remove. Say so if you didn't use it at all, and why.
