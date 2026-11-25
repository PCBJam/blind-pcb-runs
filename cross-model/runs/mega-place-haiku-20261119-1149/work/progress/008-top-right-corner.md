# 008 — top-right corner: where SCL cannot get through

Picture of the area between J8 (top header, y 81) and the TQFP's north and east edges.
Visible: the north-face ADC and PA0–2 exits, the F.Cu diagonals of PA0–2 running toward J5's top
pins, the SDA route (B.Cu) cutting diagonally through the TQFP interior toward J6.2, and the
mounting hole at (187.9, 80.9).

Why SCL (TQFP PD0, south edge) cannot reach J8.8 from here:
- SCL's pad is boxed on the north by the vias of PL7 (179, 110.6), SDA (180, 110.6) and the
  TXD1/RXD1 stubs, all within 1 mm. The only gap between those two vias is 0.4 mm.
- Its only exit is south (B.Cu via at 179.2, 114.7), and PD7's B.Cu route runs east at y 114.7.
- The route to J8.8 would have to cross the PA0–2 diagonals (on F.Cu), so it needs a B.Cu lane
  up past the north-east corner of the TQFP. That corner is free only once the south-east
  corner has been cleared.

Status: SCL is still open (three groups: J6.1, RN1, J8.8 plus the TQFP pin).
