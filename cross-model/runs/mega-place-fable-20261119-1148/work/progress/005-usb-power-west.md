# 005 – USB-C, 16U2, power input and the +5 V trunks

- USB: D-/D+ pad pairs of the Type-C joined at the connector (D- on the connector side, D+ on the board side),
  22R array RN2 sits in line; D+ runs through RN2's middle channel so the pair needs no via. Varistors RV1/RV2
  hang off the pair next to the connector and return to the shield pin; FB1 ties shield to GND.
  The two VBUS pad groups are joined by a short B.Cu link, CC1/CC2 leave on B.Cu to their 5k1 resistors.
- 16U2: crystal tracks ~6 mm to Y2, load caps under the crystal, UCAP/UVCC/VCC caps at their pins. UVCC and AVCC
  each need one short B.Cu link (they sit on the far side of the D+/D- and XTAL pins).
- Power: J4 → D4 → C1 → U1 with 1.2-1.5 mm copper, VIN to J11.1 on B.Cu under the header row, U6 (3V3) above U1.
- +5 V distribution on B.Cu, 1 mm: U1/C2 → east at y=110 → south decap of U3, branch north at x=158.5 to ICSP
  J12.2 and on (0.6 mm) to the north side of U3; second trunk from U1 pin 2 to the USB power switch Q1.
  +5 V for J5 pins 1/2 (shield supply) is a separate 0.9 mm F.Cu run along the bottom and right edge, so shield
  current does not pass the MCU's decoupling.
- First try of this area had Q1 east of U4 fed by a B.Cu USBVCC lane between U4 and its headers; that lane blocked
  every B.Cu hop to J2/J3 (the router answered with 3-via routes and a 3.8 mm neck at 0.127). Thrown away:
  Q1/U7/RN5 moved up beside the fuse path, USBVCC goes on F.Cu through the gap between J2 and J3.
- TX/RX LED nets, serial resistors and the J3 header drawn by hand; the rest of the small nets by bt route.
