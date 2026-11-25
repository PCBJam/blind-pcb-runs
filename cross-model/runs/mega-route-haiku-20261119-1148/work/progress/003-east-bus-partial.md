# 003 East bus (MCU E side to J5) partly routed

**What:** the 16 nets PA3..PA7, PG2, PG0..PG1, PC0..PC7 from the MCU east edge to the right-hand header J5, routed in one bt route --nets call (escapes-first, F.Cu preferred, 289 s).
- 13 of 16 connected: PA3-PA7, PG2, PC0, PC2-PC7 (PC7 went through a shove pass).
- Failed: PC1, PG1, PG0 ("gave up after 20 s"; pass 2 could not move PC7 back). Their pins are the lowest on the east edge, and the PB0 and PB2 runs (B.Cu under the MCU, then through the gap to J12/J5) block the corridor below J12.
- Cost: 27 vias for 13 nets. Too many; the fan has to cross the two PB ICSP runs and PB0. Revisit.

**Also applied in this step:**
- D- second pad (B7) joined to the D- trunk through two vias (B.Cu jog between the two shell-side tracks). Trial route, probed clear.
- Small local nets: Net-(D1-A), Net-(D2-A), Net-(D5-A), L13, CMP, GATE_CMD (6 nets, 28 segments, 2 vias), all connected.

**Check:** probe of the 13 nets: all 128 clear. bt drc --all: no clearance or short errors; only the 12 courtyard overlaps from the fixed placement.

**Picture:** the fan leaves the east edge in order and reaches J5 pins 3-22 with no copper violations. Visible: PB0 (blue) runs from the far SE pin J5.34 back under the chip, and PB2 runs over the right side of J12.
