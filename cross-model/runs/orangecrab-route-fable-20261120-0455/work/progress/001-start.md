# 001 – Starting point

Board as received: 163 footprints placed, 170 nets, no tracks, vias or zones.
Key parts: ECP5 LFE5U-25F in csBGA285 (0.5 mm pitch, U3), DDR3L in BGA-96 (0.8 mm, U4), three bucks + LDO + charger on the left, USB-C, microSD on the back.

Decisions taken before any copper:
- Stack-up: F.Cu signal / In1 GND / In2 signal (DDR stripline) / In3 GND / In4 split power / B.Cu signal + decoupling.
- Net classes: Default 0.127 mm, DDR classes 0.1 mm (0.089 mm necks inside the 0.5 mm BGA), Power 0.2 mm+, class clearance 0.0889 mm (needed between 0.5 mm-pitch balls). RAM_CK± moved into the (previously empty) DDR_CLK class.
- Vias: 0.28/0.15 only under the FPGA, 0.3/0.15 under the DDR3 BGA, 0.45/0.2 elsewhere.

A first trial with `bt route --nets` on the raw DDR address bus (no fan-out) got 16/25 nets in 6 minutes and walled in power balls -> thrown away; the BGAs need a hand-planned fan-out.
