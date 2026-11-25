# 002 — FPGA escape (bt fan) and planes

**What I did**
- Moved the bottom-side parts out of the FPGA's ball field (they blocked the B.Cu vias): 16 power decaps went to a strip above the FPGA (x 85–98, y 84–89, B side), the 12 LED resistor/LED pairs went to the top-left B side above J5, 10 signal resistors and U32 went to the bottom-centre B side. First fan-out: 69 of 107 nets; after moving: 91 of 101 nets.
- Net classes: Default vias 0.45/0.2 (was 0.6/0.3), clearance 0.15; Power vias 0.5/0.25; new class USB with 0.45 mm tracks and a 0.45/0.15 differential pair (about 94 ohm estimated on this 0.48 mm dielectric to In1).
- Planes: In1.Cu = GND (full board). In2.Cu = +3V3 (full board) with higher-priority islands for +1V2 (FPGA core), VIOA (Port A and the right-strip regulator) and VIOB (Port B and its regulator), joined by corridors that go round the DNP socket pads.
- FPGA fan-out applied with `bt fan --layers F.Cu,B.Cu --via-size .45,.2 --width .15` (probed first with `bt apply --checked`): 184 segments, 41 vias.

**Why**
- The BGA's inner rows need B.Cu vias; decoupling caps and resistors under the ball field took those spots. The power balls connect straight to the planes, so their decaps can sit a few mm away.
- USB pair width comes from the stackup estimate: 0.48 mm to the GND plane needs about 0.45 mm tracks for 90 ohm differential.

**Still open**
- 10 FPGA balls not escaped: 6 are centre signal balls (rows 3-4 or 9-10, e.g. D0 at H7, DA2 at D7) that would need a third layer; 2 need a via 0.1 mm further from a +3V3 via; 2 are VIO_AUX power balls that go to a plane instead.
