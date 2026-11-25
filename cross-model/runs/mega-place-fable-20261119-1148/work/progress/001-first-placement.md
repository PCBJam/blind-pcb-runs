# 001 – first placement

Rules first: board minimums raised to JLCPCB's standard 2-layer process (clearance/track 0.127, annular 0.13,
hole clearance 0.25); Default class clearance 0.15 (was 0.1), Power class clearance 0.2, default width 0.5
(trunks are drawn 1.0 by hand, the 1.0 default made every pin connection a neck).

Floorplan (all 49 loose parts placed, all on F.Cu, JP1 flipped to the front):
- U3 (ATmega2560) at 179,96 rot 0, between ICSP J12 and the double-row header J5. Rot 0 puts PA/PC on the J5
  side, PE/PH/PB towards the top headers, PL to the south-east. Only the ADC side faces the wrong way (north);
  the 16 ADC nets will dive on vias under the body and run on B.Cu straight to J10/J9 (pin order then matches).
  x=179 is forced by FID1's courtyard, y=96 lines PA/PC pins up with their J5 rows.
- One 100n at each VCC/GND pair of U3 (C8 W, C13 S, C6 E, C7 N), C18+FB2 at AVCC, C5 at AREF, Y1+R1 under XTAL pins.
- U4 (16U2) at 117.6,97.6 between USB-C, its ICSP header J2/J3 and crystal Y2; F1, RV1/2, RN2 between J1 and U4.
- Power bottom-left: J4 → D4 → C1 → U1 → C2, U6 (3V3) above U1. Power-select Q1/U7/RN5 east of U4.
- Reset switch S1 in the top-left corner (reachable with a shield fitted).
Result: no courtyard overlaps, ratsnest 10.4 m → 3.0 m.
