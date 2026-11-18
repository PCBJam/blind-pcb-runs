# 004 – PoE converter section and PHY fan-out (hand-planned)

- PoE side: In1 = Earth plane, In2 = Spare1 (+48 V) under the buck / Earth under the DC/DC input. Switch node kept
  tiny (D5 pad → U5 pin 1 / C12, two vias up to L4). Earth pins of U5, R34, U2 go straight into the D5 anode pad and
  to In1 by vias. Feedback, CDB, DEN, CLS are thin tracks kept off the switch node. Spare2 is a 0.6 mm F track from
  the jack to C24/D10/U2. Shield: pins 7/8 and both shell tabs joined, C2 to the east tab.
- R27 (under the jack): Spare1 and Earth reach it on the inner planes round the east side of the jack pins, so no
  PoE copper runs between logic pins.
- PHY: every pin escape, the strap-resistor nets and the via positions drawn by hand after two autoroute attempts
  boxed pins in. Via row north of the PHY for RXD0/RXD1/CRS_DV/MDIO, three TX vias east of it, the clock comes over
  the top on F as the westmost lane and lands on a via at pin 5. VDDIO/C14 gets 3V3LAN through a short F hop
  (the strap pads leave no B-layer way in).
- First PHY version failed `bt probe` (RXER via 0.04 mm from the CRS_DV track) → via moved, clean.
