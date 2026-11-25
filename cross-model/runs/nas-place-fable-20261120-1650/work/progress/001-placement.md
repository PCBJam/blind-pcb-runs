# 001 – first complete placement
All 190 loose parts placed by script (`scripts/place.py`).
- Tall parts (seven bucks with 2 mm inductors and 0805 caps, LDO) go on the **back**: the top is covered by the M.2 SSDs and the CM4. Each M.2 buck sits right under its socket's 3.3 V pins.
- ASM1184e (U12) on top under socket 2, rotated so its port order matches the socket order (no pair bundle has to cross another).
- 5 V buck, hot-swap/eFuse and TVS on top next to the DC jack (only top area not under a module).
- RP2040 beside its USB-C/boot/reset parts; status LEDs in one column on the free left edge.
Result: no courtyard overlaps left after two small fixes (AC caps vs U12, crystal vs R58).
