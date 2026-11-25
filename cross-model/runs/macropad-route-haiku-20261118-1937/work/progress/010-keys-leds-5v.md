# 010 — key field as applied

Picture 010-keys-leds-5v.png (current board).

GPIO (bt length, per net, layers):
- KEY1 17.8 mm, 1 via: 16.8 mm on B.Cu, 1.1 mm on F.Cu.
- KEY2 36.7 mm, 1 via: 34.6 mm on F.Cu, the drop to the pad on B.Cu.
- KEY3 58.7 mm, 1 via: 57.1 mm on B.Cu.
- KEY4 31.8 mm, 3 vias.
- KEY5 42.9 mm, 1 via: 41.2 mm on F.Cu.
- KEY6 60.2 mm, 3 vias: 57.8 mm on B.Cu.
The lengths are the price of the north-edge fan-out; see NOTES.md for why.

LED chain on B.Cu: row-1 DOUT to DIN and row-2 DIN links 14.2 mm each; the D401 to D701 link 21.7 mm down the east side; LED_DIN (U106 to D201) 30.2 mm, 1 via, F.Cu 29 mm.

+5V_LED: 144 mm in total, 8 vias, mostly B.Cu (130 mm). This is a point-to-point net, not a pour.

Key NPTH holes and the pads' clearances are respected (DRC clean).
