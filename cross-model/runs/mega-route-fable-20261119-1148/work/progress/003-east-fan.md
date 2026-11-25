# 003 – east side fan-out (ports A, C, G, L, UARTs, I2C)

First try: `bt route --nets PA0..PA7 --layers F.Cu --no-vias`. It connected 2 of 8 in 88 s and
gave up on the rest ("boxed in"), and the two it did route cut straight across the lanes the
others needed. Undone (`bt undo`).

Second try (kept, in the picture): my own lane generator. Every net gets an explicit lane; all
tracks 0.25 mm at ≥0.45 mm pitch, 45° corners, probed clean in one go (219 items):
- PA0..7 leave NE past C7, west of the mounting hole, north of FID1, and enter J5 in pin order
  (even pins through the gap south of their row's west pad).
- PC7 passes through the ICSP header (one track per pad gap), PC6..0, PG1, PG0 pass south of it.
- PD7 and PG2 are the two nets whose J5 pins are out of order: each gets one via near J5 and a
  short B.Cu hop (PG2 down the west side of the J5 column, PD7 diagonally to J5.19).
- South bundle: TXD1, RXD1, SDA, SCL end in a staggered via row (they go north on B.Cu to J8),
  PL7..0 carry on to J5.23-30.
- +5V: pin 80 → C7 → via; 0.5 mm lane along the top to J5.1/2; pin 61 → J12.2 between the ICSP pads.
- UART2/3 on B.Cu to J8.1-4 and SPI/RESET to J12 were done with `bt route --layers B.Cu --no-vias`
  (worked first time, clean 45° runs).
