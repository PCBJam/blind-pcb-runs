# 002 – critical nets routed by hand (scripted geometry), one autoroute attempt thrown away

Pictures: `002-critical-routes-top.png` (F.Cu + In2), `002-critical-routes-bottom.png` (B.Cu),
`002a-autoroute-attempt-discarded.png` (the attempt that was discarded).

What I did
- Inner planes: In1 = solid GND; In2 = +3V3 with islands for VIOA (top right), VIOB (bottom right),
  +5V (left column and bottom edge band) and GND under the LVDS run (so the B.Cu pairs see ground).
- FPGA: dog-bone fan-out (0.4/0.2 vias), outer two rings escape on F.Cu through chosen gaps so that
  every bus leaves in the order its target wants; six 100 nF caps under the BGA; PLL filters at the balls.
- USB: D+/D- as a pair from the A6/A7 pads straight into the FX2; B6/B7 joined on the back through the
  rear test points; ESD/switch IC on a 1.5 mm stub; both VBUS pads joined on the back.
- FX2 <-> FPGA: 13 signals as one planar F.Cu fan (no vias), the rest on B.Cu; D0-D2, CLKIF and the
  CLKREF branch to ball D5 run on In2 (short tracks under the two ICs where B.Cu holds the decoupling).
- LVDS: 7 pairs on F.Cu (J5 lower row), 6 pairs on B.Cu (J5 upper row, vias between the pad rows),
  0.19/0.15 mm, lanes stacked so nothing crosses.
- Port connectors: IDC pin -> ESD array on F.Cu, IDC pin -> pin-socket row as a B.Cu bus.

What failed
- `bt route --nets` for the ten B.Cu nets between FX2 and FPGA: 7/10 connected after 331 s, D0 took a
  22 mm detour round the north side of the BGA (through the LVDS exit), CLKIF needed 4 vias, three nets
  gave up. Restored the board from before and drew these by hand instead (picture 002a).
