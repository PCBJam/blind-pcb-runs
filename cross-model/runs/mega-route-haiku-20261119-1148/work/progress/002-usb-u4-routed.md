# 002 USB block and ATmega16U2 routed

**What was done (in order, each applied to the board after checking):**
1. Net-(D4-A) barrel jack to reverse-polarity diode D4 (10 mm, F.Cu, 1 mm Power class; no vias).
2. VCC (raw input) from D4 to the regulator U1 input, bulk cap C1, C4 and the power header J11. One branch (to RN5.6) is boxed in and necked to 0.127 mm; to revisit.
3. USB D+ and D- as a pair on F.Cu: D+ joining loop from the two D+ pads of J1 round the WEST end of the connector (the east loop would cross the D- escape), then D+ and D- trunks to RN2 pins 5 and 8, and the 5 pF shield caps RV1/RV2.
4. RD+/RD- from RN2 to U4.29/U4.30, routed as a pair with length tuning (skew 0). Two small bumps on RD-, clear of the UVCC pin.
5. CC1/CC2 to their 5k1 pull-downs (R3, R4).
6. USHIELD: the router proposed two vias and diagonal B.Cu runs through the connector. Replaced by hand: shell pads joined on F.Cu, one B.Cu strap along the west edge of the connector, FB1 and RV1/RV2 on F.Cu.
7. XVCC (VBUS, 0.3 mm): F1 to a junction west of the connector, then to A9 and round the west side to A4. The connector's two 0.65 mm mounting holes at (104.14, 90.67) and (104.14, 96.45) sit right at the pads' west ends, so the path is diagonal between them (probe found the first try too close to the D+ loop and the holes, moved to x=103.8).
8. USBVCC (fuse output) to U4.31, C10 and Q1 (0.2 mm, F.Cu).
9. U4 ATmega16U2 nets (MISO2, SCK2, MOSI2, RESET2, PB4-PB7 header nets, DTR, RXL, TXL, M8TXD, M8RXD, both crystal nets, UCAP): 16 nets via bt route --nets, escapes-first. Two needed a shove pass.

**Check (bt drc, KiCad on the saved board):** no clearance or shorting errors. The 12 courtyard overlaps are in the fixed placement (C16/Y2, J3/J2, J6/J2, FID3/J1, J2/D3, J4/FID2, ...). They are not routing problems; I can't move parts.

**Not good yet:** RESET2 is 36 mm (it runs from U4.24 at the top to RN5.7 at the bottom and passes the U4 crystal pad on B.Cu). DTR is 26 mm, because it reaches C9 at the bottom of the board (auto-reset). Both are placement-driven; I'll tidy them later if there's room.
