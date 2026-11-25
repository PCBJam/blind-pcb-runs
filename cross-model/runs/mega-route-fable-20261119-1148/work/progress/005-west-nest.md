# 005 – west side of the MCU: header nest, crystal corner, SPI drop

Scripted lanes again (210 items, one probe failure fixed: PE0/PE1 B.Cu hops crossed, re-staggered):
- 14-lane F.Cu nest from the west pin column, west past C8/FB2, north, then fanned to J6.5-10
  and J7.1-8. PE3 and PG5 are the two J7 nets that are out of order; each takes a via and a short
  B.Cu drop into its header pin under the other lanes.
- PE0/PE1 (USB-serial RX/TX) also have to reach RN4 on the far side of the nest: one via in the
  free pad gap at pin 4, one via inside the chip, B.Cu under the nest, up next to RN4.
- Crystal corner: XTAL1/XTAL2 run as a pair to R1/Y1 with the MCU's own GND pin 32 routed alongside
  to the resonator's ground pad; RESET leaves north of them, +5V pin 31 has its own via.
- PB0..3 drop on B.Cu from their vias at the west, pass under the XTAL/RESET tracks, come up south
  of them and run as the outermost four lanes of the south bundle to J5.31-34.
- AVCC: FB2 → C18 → pin 100; AREF and GND pin 99 get vias north of the chip.
- +5V "bar" on B.Cu (0.8 mm) under the north pin row joins FB2/+5V at the west with C7 and the top lane.
