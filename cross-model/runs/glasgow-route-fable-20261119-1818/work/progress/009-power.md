# 009 – power distribution

- East corner by hand: each LDO's output -> sense resistor -> shunt -> VIOA/VIOB island on wide B.Cu tracks with
  two 0.6 mm vias; +5V comes along the In2 strip on the south edge, up a 0.6 mm B.Cu trunk to U14 and on to U31.
- West corner by hand: USB switch -> 150 uF -> both regulators on 0.5–0.8 mm F.Cu; +3V3 and +1V2 outputs into In2.
- +1V2 is an island on In2 from U36 to the FPGA. First attempt (ten overlapping rectangles) read as four separate
  pieces; replaced by one polygon. Its "bus bar" runs under the via-free ball row I kept in step 002.
- `bt ratsnest` then showed what I had feared in step 002: FPGA balls D6, F8 and H6 (+3V3) had vias but no plane –
  boxed in by the +1V2 island and the via field. Fixed by moving the two PLL1 filter vias one site (opens a 0.6 mm
  channel to D6), trimming the island at F8, and a 2 mm B.Cu link from H6's via to C23. Also re-spaced four QB
  tracks south of the FPGA to fit a via for the bulk cap C19, which was boxed in on both layers.
- `bt plane --net +3V3` proposed a second via for pads I had already tied to a via by a stub, so I did not use it;
  `bt route --net +3V3 --all` joined 26 groups with tracks, and `bt via --near PAD` gave the rest a plane via each.
- VIOB needed its island widened: the Y/Z via rows at RN3 pinched off the leg to U5.
All five rails now read as one piece each, except +1V2 at R32 (PLL filter resistor), still open.
