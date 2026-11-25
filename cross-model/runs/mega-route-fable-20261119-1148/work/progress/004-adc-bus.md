# 004 – ADC bus to J10/J9, I2C/UART1 to J8, top-edge strip

- ADC0..15 on B.Cu from under the chip to the bottom headers. First version (straight 45° runs
  from the bus to every pin) could not work: the direct diagonals of the low channels cross the
  verticals of the high ones, and ADC7's passed 0.1 mm from the lower mounting hole. Kept version:
  ADC0..6 peel off one after another as plain diagonals, ADC7 goes under the hole, ADC8..15 run as
  a parallel group north of the hole and drop into J9. Scripted, probed clean, 84 segments, no vias.
- TXD1/RXD1/SDA/SCL: from their via row north on B.Cu, each straight under its J8 pin.
- I2C pull-ups (RN1) hooked up on F.Cu from two vias on the SDA/SCL B.Cu runs; RN1's +5V comes down
  on B.Cu from a via on the +5V top lane, between the RXD1 and SDA runs.
- SDA/SCL continue from J8.7/8 along the top edge (0.2 mm, F.Cu, between the header pads and the
  board edge) to J6.2/J6.1; the power-LED line (D6) uses the same strip on B.Cu.
