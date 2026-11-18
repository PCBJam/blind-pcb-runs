# 006 – every signal and power net connected (GND still to do)
- Power rails routed with `bt route --net X --all --width …` (VIN/5V/5V_BAR 0.6, VBATT/VRAW/USB 0.5, 3.3V_P 0.4), then several hand fixes round U11 (reset hops on In2 so VRAW/VBATT/5V reach its pins).
- The auto-routed VDD_FLASH / VDD_MIPI links ran 30–50 mm on In2 right under the MIPI/USB bottom-layer pairs: thrown away. Replaced by planned In2 lanes west of U1 and rows along its top edge (crossing the pairs once, at right angles, next to their launch vias).
- North-west corner of U1 is the bottleneck (USB-serial pair on F, USB-HS on B, the In2 rows): SDA gets a dedicated via "gate" between the two USB pairs, SCL/IOB35/VDD_SD pull-up feed had to take long ways round (SDA 156 mm, SCL 132 mm – slow nets, accepted and noted).
- 3.3V In2 region re-shaped (north edge to y 95.3) because the UART/IO11 In2 hop had cut the part under U1's north half off from the regulator.
