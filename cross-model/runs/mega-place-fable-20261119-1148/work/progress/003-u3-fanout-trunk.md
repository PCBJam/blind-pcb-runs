# 003 – U3 fan-out to J5/J8 and the trunk to J7/J6

- East side (PA, PC, PG) on F.Cu straight to J5; even-column pins use the gap under their row. bt route did
  15 of them in one pass; PG0/PG1/PC0 were drawn by hand because the router's first try wrapped PG1 round the
  chip corner. PG2 and PD7 hop on B.Cu (1 via each) because their J5 pins are out of pin order.
- J8 arrivals all on B.Cu from the under-chip lanes (bt route, no vias).
- West side: 14 nets to J7/J6 drawn by hand (scripts/h_trunk.py) as three sub-bundles through the obstacles:
  PG5/PE0/PE1/PE3/PE4/PE5 pass north-east of FID1, PH3-6 between FID1 and the mounting hole, PB4-7 between the
  hole and J12. Then fixed lanes under the header row, each net peeling off to its pin.
  bt route's own attempt at the first bundle put PE3/PE4 flat against FID1's keepout and walled PE5 in, hence by hand.
- PG5 and PE3 are out of order on J7: PG5 goes over the top of the header on the B.Cu margin (1 via), PE3 dives
  under the row on B.Cu (1 via). AREF (B.Cu) and SCL/SDA (F.Cu) use the 1.2 mm margin above the top headers to reach J6.
- +5V for J5 pin 1/2 will not come through the chip area; plan is a separate F.Cu run round the bottom/right edge.
