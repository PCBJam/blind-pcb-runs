# 009 — whole board after the 16U2, J8 and west-face groups (real board)

Picture: 009-after-wface.png. What is on the board now:
- Locked headers and the TQFP escape (both sides), the 16U2 escape and its nets (27 of 29 plus the
  SCK2 fix), the J5 bundle (28 of 29; PC3 open), the serial/I2C group (7 of 8; SCL open), and 11 of 16
  west-face nets (PE0, PE1, PB3, PB5, PB6 open).
- Nothing yet on: the ADC bus (16), power (+5V, VCC, +3.3V, USBVCC, XVCC, D4-A) and GND.

Why the west-face and ADC groups are the hard part (seen in the picture):
- The west-face nets run as diagonals from the TQFP's west edge up to J6/J7 at the top.
- The ADC nets have to leave the TQFP's north edge and reach J9/J10 at the bottom. Both groups
  need the north-west quadrant. Whichever is routed first blocks the other.
- SDA's B.Cu route (from the south corner, through the interior, to J6.2) cuts across the west-edge
  pins PE0 and PG5. It was routed earlier by the serial/I2C group.
