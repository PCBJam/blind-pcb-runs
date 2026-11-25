# 001 — first placement pass (everything on the board, no routing yet)

**What I did**
- Put the FPGA U30 (iCE40, BGA-121) at (83, 98), rotated -90, so its Z-port row (B1..K2) faces up to the Z connector J5, its FX2-interface column (L..H) faces left toward the FX2, and its bank A/B pins face right and down to the two IO ports.
- Put the FX2 U1 (CY7C68013A, QFN-56) at (66, 98), rot 0: USB pins 8/9 on the left edge, facing the USB-C J1.
- Port A IO buffers (8x SN74LVC1T45, U4 U11 U6 U16 / U9 U17 U10 U18) on the F side in two rows at rot 180: DIR pin (the FPGA's DA line) faces the FPGA, A/B pins face up toward the Port A connector J2.
- Port B IO buffers (8x, U22..U29) on the B side in two rows at rot 180: DIR faces the FPGA, A/B face down toward Port B connector J3.
- Regulators, monitors, DACs and PCA6408 expanders placed around their ports (right strip for Port A/B power, U19 next to DNP socket J9, U5 next to J7).
- Crystal Y1, USB switch U15, ferrite FB1, USB CC resistors and shield parts placed around J1.
- All 87 decoupling/bulk capacitors placed on the B side with `bt near --each`, each next to the pin it serves (one cap per power sink).
- RN networks (33 ohm) on the B side next to their buffers; ESD arrays next to the connectors; LEDs, resistors, test points, reset switch placed by `bt near`.

**Why**
- The FPGA/FX2 pin maps decide the rotations: the placement keeps the FX2 bus, the Z-port and both IO banks on the side of the FPGA they connect to.
- The SN74LVC1T45's DIR pin sits on the opposite side of the package from A and B, so the buffers were rotated so DIR faces the FPGA and A/B face the connector.
- Passives go on the B side where the top side is full.

**Result**
- 0 parts off the board outline. Locked parts untouched.
- Not checked yet: courtyard overlaps, DRC, routing. Next: DRC on placement, then fanout of the BGA and QFN.
