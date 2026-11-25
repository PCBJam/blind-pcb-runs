# 002 — major parts placed (top side)

Placed: U3 ATmega2560 TQFP-100 at (177, 104), rot 0. Reason: its right edge (pins 51–75,
PA/PC/PG) faces the J5 header (30 signals), and it sits clear of J12, the holes and FID1.
U4 ATmega16U2 at (126.5, 96.5), rot 90: USB D+/D- pins on the west (toward J1), crystal
pins on the south (toward Y2), ICSP J2/J3 on the north.
Power: D4 (barrel reverse-polarity diode) between the barrel jack and C1 (47 uF), U1
NCP1117 (rot 0 so its input faces the barrel side), C2 47 uF output, U6 LP2985-3.3 near J11.
Crystal: Y1 resonator + R1 beside the 2560's XTAL pins; C16/C17/R2 north of Y2 (16U2).
S1 reset switch bottom-left, clear of J11.

Result: no locked part moved; bt same clean. Courtyard DRC: only the four overlaps between
locked footprints that were already in the file (J2/J3, J2/J6, FID3/J1, FID2/J4).
