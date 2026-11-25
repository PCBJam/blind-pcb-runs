# 002 – under the ATmega2560

Hand-planned and scripted (my own generator, checked with `bt probe`, written with `bt apply --checked`):
- ADC0..15 leave the north pin row inward, fan from 0.5 to 0.61 mm pitch into two staggered via
  rows, and run south on B.Cu as one 0.2/0.2 mm bus (x 147.0–153.0) towards J10/J9 at the bottom.
  Kept east of x=147 so it does not run under the XTAL pins.
- F.Cu lanes across the chip interior (over the ADC bus): TXD2/RXD2 north of fiducial FID4,
  +5V (0.4 mm, to pin 61) and PB1..3 + RESET (to the ICSP header J12) south of it.
  TXD2 hops under RXD2 on B.Cu at the west so the pair comes out in J8 pin order.
- TXD3/RXD3 go inward to vias in the NE corner, so all four UART lines leave eastwards on B.Cu in
  J8 order (TXD3, RXD3, TXD2, RXD2).
- PB0..3 get a via at the west for the B.Cu drop to the south bus (J5.31-34).

Why so much planning: FID4 sits in the middle of U3 with a 1 mm clearance, which blocks the
obvious straight lanes; first lane plan (RXD2/TXD2 straight across at y=103) had to be redone.
First probes failed (fan diagonals too close to neighbouring vias / pads), fixed by shifting
the via rows 0.35 mm south and re-staggering the PB fan.
