# 002 core parts placed (left block, first pass)

What I did:
- Redrew the outline left of the key area: block x 89..117, y 100..130.5, key area untouched (`bt outline --poly ... --radius 1 --replace`).
- Placed the RP2040 U103 at (109.8, 108.8), rotation 0, B side. On B with rotation 0, pins 31..37 (the key lines) face east, toward the key area; QSPI and USB pins face south; XIN/XOUT face north.
- Placed the USB-C J101 on the bottom edge, rotation 180, B side, mouth facing down. Its pad row sits under the RP2040's USB pins.
- Placed the crystal Y101 above the MCU (first try at 108.5,102.5 rot 0) with C109/C113/R105.
- Placed the flash U104 at (103, 116) (QSPI pins 5..8 face the MCU).
- Placed the ESD clamp U102, the 27 ohm series resistors R103/R104, the fuse F101 and the CC pull-downs R101/R102 between the MCU and the connector.

Why: the USB pins sit on the RP2040's south edge, so a south-facing connector gives the shortest D+/D- run with no crossing against the QSPI lines.

Result: all core parts on board. Parts were placed with `bt place` (trial first), then applied. Checked with `bt near` for spots.
