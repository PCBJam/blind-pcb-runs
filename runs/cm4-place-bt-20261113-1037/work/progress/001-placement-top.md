# 001 – first full placement (top side)
All 170 loose parts placed by script (`scripts/place.py`). Floorplan:
- ASM1184 PCIe switch (U12) on top at (169.5, 80.5), rotated 180° so port order around the chip matches the socket order (J4, J3, J2, J5) and the upstream port faces the CM4.
- Input protection / hot-swap (IC1, U3) and the 5 V buck (U1) on top in the open area under the DC jack.
- RP2040 block on top near its USB-C, buttons and fan headers; status LEDs along the bottom board edge (one per SSD at the SSD's end) and beside the CM4.
- Ethernet ESD arrays between the RJ45 and the CM4.
Result: KiCad DRC shows no courtyard overlaps or shorts after three small moves (R58, D4 row, TP_1V2).
