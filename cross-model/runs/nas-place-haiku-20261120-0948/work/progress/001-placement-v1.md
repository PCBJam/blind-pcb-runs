# 001 placement v1 (first pass of every unlocked part)

**What:** placed the big ICs and the M.2 converter groups, then all passives next to the pin they serve (bt near --each).
- DC input (U3 TPS2420, IC1, D1/D2, sense resistors) in the free strip above the CM4, F side, next to the DC jack.
- +5V buck U1, +1V2 buck U2, +3.3VA buck U15, AP2112 U4: bottom side (B) to keep the top clear.
- M.2 3.3V bucks U14 (M3/J4), U11 (M2/J3), U10 (M1/J2), U13 (M4/J5): bottom side, one under each slot's power-pin group, with their inductors, bootstrap, feedback and output caps.
- ASM1184 (U12) on the front side between the M.2 row and the CM4, rotated 180 so its four downstream ports face their slots (port1 east, port2 north, port3 west, port4 south) and the upstream pins face the CM4 (south-west).
- RP2040 (U18), flash (U17), crystal (Y1): first put in the middle, moved later (see 002).
- ETH ESD U8/U9 just below the RJ45 (U7).

**Why:** the NVMe drives lie flat over x 129-220, y 62-142, so the front side under them is kept to low-profile parts; tall parts (inductors, 22 uF caps) go to the bottom side, which is empty. The CM4 module hangs over x 88-128, y 90-146.

**Result:** all 254 parts on the board; bt place/bt near found legal spots for everything. bt congestion (see /tmp notes) flagged: CM4 left column pins with no way out (LEDs/resistors in the strip), RP2040 decoupling caps boxing in its pins, PCIe LEDs in the M.2 power-pin zone.
