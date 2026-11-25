# 005 – FPGA power/ground vias, decoupling placement, header IO on B.Cu

What
- GND balls of the ECP5 tied together on F.Cu with a 0.12 mm mesh (181 segments, each probed) and
  dropped to the planes through 16 vias on a 1 mm grid in the centre plus single vias for the
  isolated GND balls; 1V1 / 1V35 / 3V3 / 2V5 / VREF balls get interstitial 0.28/0.15 vias.
- 22 of the 0201 decouplers placed on the bottom under the BGA with `bt near --each` (it only
  offers spots whose pads are clear of the via field and of the DDR tracks already on B.Cu).
- East-edge IO (IO_5/6/9/10/11, SCL, SDA, REF_CLK): the pin order at the FPGA is the reverse of the
  header order, so three nets run north under the FPGA's NE corner and five run north in the
  FPGA-RAM gap, all on B.Cu, then fan out to the J1 pads. RAM_A3 had to move from B.Cu to F.Cu
  across the gap to let that bundle through.

Why: the gap between FPGA and RAM is the only N-S passage on any layer that the DDR address lanes
(F.Cu and In2) do not fence off.

Dead ends on the way: a single 8-track lane under the NE corner (the eastmost lane would have had
to cross the other seven to reach the westmost header pin); `bt route --nets` for the header
fan-out at 0.12 mm (two clearance failures at the lane pitch and one 26 mm detour) - replaced by an
explicit fan-out.
