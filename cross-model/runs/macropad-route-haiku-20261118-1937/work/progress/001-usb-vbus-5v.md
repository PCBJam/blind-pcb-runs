# 001 — USB pair, VBUS, +5V tree, CC pulldowns

Net classes first (bt rules): Power5V (+5V, VBUS) 0.5 mm; LED5V (+5V_LED) 0.4 mm; Power3V3 (+3V3) 0.3 mm; USB class (D+/D- pair width 0.2, gap 0.2).

What I did
- USB D+/D-: bt route found a clean F.Cu solution. D- runs straight from connector B7 through ESD pins 1 and 6 and R103 to the RP2040. D+ runs from B6 through ESD pins 3 and 4 and R104. The duplicate connector pads are bridged on F.Cu: D+ around the east side, D- around the west side, so the two bridges never cross.
- VBUS: the connector's A9/B4 pad is boxed in by the NPTH hole and CC2, so the first route was 0.127 mm necked on the west side. I rejected that. I used the east side instead: F.Cu from the fuse under the connector, then up a B.Cu trunk at x = 95.55 between two vias, to A4. Vias are at 95.55,108.9 and 95.55,104.4.
- +5V: F101.2 feeds LDO VIN (via a 0.3 mm jog round the LDO's GND pin) and EN, C102, C119/TPS VIN and C101. The ESD VBUS pin (U102.5) is enclosed by the two USB lines, so it gets a stub and via at 100.6,106.5 and a 13.9 mm B.Cu run to the 5 V tree.
- CC1/CC2 pulldowns: short F.Cu links, clear of the VBUS vias.

Tried and discarded
- Router's first VBUS route ran down the east side on F.Cu and crossed the USB lines. Rejected.
- Router's second VBUS route went west: necked to 0.127 mm on both ends (boxed by the hole and CC2). Rejected.
- Router could not reach U102.5 on F.Cu (walled in by the USB lines). Solved by hand-placed via.

Result: all power-input nets have no ratsnest gap. Picture: 001-usb-vbus-5v.png.
