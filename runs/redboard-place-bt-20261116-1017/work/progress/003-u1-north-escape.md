# 003 – hand-built escape of the ESP32-P4 north side
Found that `bt` could not read the outline (it lives inside footprint H1): every command died with "Invalid typed array length: Infinity", and once a board-level
copy of the outline was added H1's own outline was taken as a cut-out covering the whole board. Work-around: `scripts/mode.py` – while working, H1's nine
Edge.Cuts lines sit on the Margin layer and a board-level copy of the outline exists; `mode.py kicad` puts it back (used for every real KiCad DRC and for the final file).

Inner planes added first: In1 = solid GND, In2 = 3.3V with a 1.1V island under U1 reaching the buck output.

North side of U1 by script (`scripts/esc_n.py`, checked with `bt probe`, written with `bt apply --checked`):
- MIPI DSI: the pin order of U1 and of J6 cannot be joined without one crossing (worked through the planar order): CLK goes up the west side of J6, D1 up the east side
  (both all on F.Cu over the GND plane), D0 hops 4 mm on B.Cu under CLK and comes up between the pad columns.
- MIPI CSI: six pins fan in to 0.26 mm pitch (to leave room for the VDD_MIPI cap right at pin 41) and go to the series resistors.
- Flash: D/CLK/HOLD/VDD round the north of U4, WP/Q/CS into the channel between its pad row and centre pad – no vias on any flash line.
- USB HS first leg, both REXT resistors, C26/C41 at their pins.
Several rounds of probe failures first (45° jogs at 0.35 mm pitch come out 0.12 mm apart; J6 has NC pads at its ends that blocked the first via site) – fixed by a shallower jog and moving U4 0.7 mm south.
