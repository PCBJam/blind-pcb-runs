# 005 — power, control and zones (full board, state after this step)

Routed:
- Control: PERST# (J2.50 -> R4 -> J1.A11), WAKE# (J2.54 -> R3 -> J1.B11), CLKREQ# (J2.52 -> R2,
  via at 111.75/103.8, and the R2 0R to GND). CLKREQ needed the D2 OUT P leg re-routed
  around R2 (R2 sits in the middle of the fan).
- +12V (J3.1 Molex pin 1, J4 test pad, J1 A2/A3/B1/B2/B3, decaps C1/C2): 0.8 mm tracks.
- +3V3 (J2 pins 2,4,12,14,16,18,70,72,74; J1 A9/A10/B8; R1, decaps C3/C4/C7/C8/C9):
  0.6 mm; three links necked to 0.18 mm on the finger pads (short, 2.6 mm total).
- +3V3_AUX (J1 B10, R1.2, C5, C6): 0.4 mm. +5V (J3.4 to J5 test pad): 0.5 mm.
- Power class in the .kicad_pro: track 0.6, via 0.6/0.3, clearance 0.145 (0.2 caused four
  false clearance errors against the NC finger pads).

Zones: GND on In1.Cu and In2.Cu (whole board) and GND pours on F.Cu and B.Cu (whole board),
clearance 0.2. No power planes: In2 carries lanes, so 12 V and 3 V3 stay as tracks.

Remaining: ground pads (see 006).
