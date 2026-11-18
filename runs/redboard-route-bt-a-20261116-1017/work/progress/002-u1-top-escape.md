# 002 – ESP32-P4 top-side escape, DSI/CSI/flash by hand
Hand-computed (scripted, `bt probe`-checked) routes on F.Cu:
- DSI D0 enters J6 through the channel between its staggered pad columns, DSI D1 from the right with one leg passing between two pads. DSI CLK cannot reach its pads in the right polarity on one layer, so it gets ring vias under U1 and will run on B.Cu.
- CSI D0/D1 go up between J5 and J6 to their 100 Ω series resistors; CSI CLK (resistors left of J5) cannot cross D1, so it also drops through ring vias.
- Flash D/CLK/HOLD over the decoupling caps to U4's top row, CS around R13, Q/WP by ring vias to vias under U4. VDD_FLASH pin goes straight to its caps.
- USB HS: ring vias (B.Cu run comes later).
The gaps between C26/R33 and R32/C27 only take 4 tracks at 0.3 mm pitch; this dictated the whole arrangement.
Result: all probe-clean.
