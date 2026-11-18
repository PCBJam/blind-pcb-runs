The KiCad 10 project in /work (board file: /work/m2-pcie-adapter.kicad_pcb) is a 4-layer board. The board outline, the connectors (the M.2 card edge, the PCIe socket, the power connector and the two pogo pins) and the logos are already placed and locked. Every other footprint has been moved off the board, below the outline, all on the top side. There is no copper routing: no tracks, no vias, no zones. The schematics are in /work.

Your job: place the remaining parts and route the board, so it is ready to order as a 4-layer board. Keep the already placed parts where they are. You can use both sides for parts and all four copper layers. Do it the way an experienced PCB designer would for a product they care about, not only so it passes DRC. Think about the circuit.

Rules:
- Locked footprints (already on the board) must not be moved, rotated, flipped or removed.
- Do not add or remove footprints, and do not change their footprint definitions.
- You may add tracks, arcs, vias and zones, and edit net classes and design rules if you have a reason to.
- Save the result in place as /work/m2-pcie-adapter.kicad_pcb, readable by KiCad 10.
- When you are done, write /work/NOTES.md: a summary of your important decisions (placement, layer stack use, routing approach) and why, and anything you know is not finished or not good.

Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed. Python, Node and pip/npm work. You have internet access through a proxy, and some sites are blocked. There is no GUI.

Work on your own until the board is finished; nobody will answer questions.



Board tools: `bt` is installed (run `bt help`, which has examples). It reads a .kicad_pcb and the rules next to it and answers in short text, without writing anything unless you ask. It keeps the same rules KiCad's DRC does for copper: net classes, edge clearance, pad and footprint clearance overrides, copper logos, and the .kicad_dru's clearance rules (`bt board` says which it applies). The tools:
- `bt board` prints the whole board in one go: rules, parts, every net with its pads, and the ratsnest. `bt part`, `bt query`, `bt gap`, `bt length` and `bt free` answer smaller questions.
- `bt congestion` shows, before you route, where it will be tight; `bt islands` shows which pieces of a net no pour could join.
- `bt route` routes one connection, a net's missing links, or several nets at once (`--nets`, shortest first, with shove and rip-up passes for what fails). It takes keepout boxes per layer, no-via boxes, via sites, a narrower neck, a via limit and a length budget, and returns coordinates or names what blocks the route and where. `--shove`/`--rip` move earlier tracks out of the way, only on the layers you allowed, and undo everything if any moved net would end up less connected. `bt bus` routes nets side by side, `bt pair` a differential pair or a group of pairs side by side.
- `bt fan` escapes a BGA or a fine-pitch IC side by side (rows between the balls on the top layer, dog-bone vias for the next rows) and lists where each net comes out, in order along each side.
- `bt escape`, `bt plane` and `bt stitch` add stubs and vias to reach pours.
- `bt probe` checks proposed tracks and vias against the board and against each other (exit 1 on any problem); `bt apply --checked` probes first and writes nothing if anything is wrong.
- `bt place` tries placements and `--apply` writes them; `bt near` finds legal spots.
- `bt render` draws a labelled PNG of any window, zone fills included.
- `bt drc --baseline` runs KiCad's DRC and shows only what is new; `bt same` checks that locked parts didn't move.
- `bt apply`, `bt unroute`, `bt cleanup`, `bt zone` (add, `--delete`, `--replace`), `bt fill` and `bt outline` write to the board (copper as plain text; zones, fills and placements through pcbnew on a copy, with only the .kicad_pcb coming back). Each write keeps the old board: `bt undo` puts it back.

You decide the floorplan, the layer use and the order; the tools do the coordinates and the checks. Use them or not, as you see fit.

Good to know: saving a board through pcbnew can rewrite the .kicad_pro next to it with defaults. Keep a copy of it, or write with `bt`, which only touches the board file. bt reads the rules from the .kicad_pro next to the board: a copy of the board in another folder is checked against KiCad's defaults (bt says so).

Progress log: keep a visual log of how the board develops in /work/progress/. Each time you reach a step worth seeing (a placement attempt, a routing stage, a DRC round, a change of plan), save a numbered pair: a picture of the board (or of the area you worked on) as NNN-<short-name>.png and a short NNN-<short-name>.md with what you did, why, and what the result was. Number them in order (001, 002, ...). Keep the attempts that failed or that you threw away too, and say in their note why they failed. Aim for one entry every few minutes of work, not for every command.

`bt` is experimental, and we want your honest opinion of it. After the board is finished, write /work/BT-REVIEW.md: which bt commands you used and how often, which helped and how much (time, tokens, fewer mistakes), which got in the way or gave wrong or confusing answers (with the command and what happened), what you did yourself instead and why, and what you would change, add or remove. Say so if you didn't use it at all, and why.
