# 006 decaps moved out of the ball field; planes and escape vias

**What changed in this step**
- Moved the 24 FPGA decoupling caps from under the FPGA to: a row on the back under the FPGA's south edge (two rows, y 109.3 and 110.9), a row on the front in the bottom-left band, a few on the back in the strip above the FPGA, and a small group on the front bottom-right beside the LDO.
- Moved the five interior DDR3 caps (C21, C23, C33, C36, C37) out of the DDR3 field; the first move put them on J6's pads, so they were parked at the back-right strip and C21 near the charger.
- Moved the mux U9 from the bottom edge to x 148.9 on the back, which cleared the J2 pads and the microSD mounting pad. Moved R27, R48, TP31 and TP32 to a free block on the back.
- Added the planes: GND on In1.Cu (full outline); P1.1V on In4.Cu (interior, box 164.5-180.5 x 96.5-110.5); P3.3V on In3.Cu (interior, box 168.5-177.5 x 97.5-107.5); P2.5V on In2.Cu (interior, box 167.8-175.5 x 99.8-105.6); P1.35V on B.Cu (box 167-177.5 x 97.5-107.5); GND pour on F.Cu (full outline, clearance 0.089).
- Wrote a 0.28/0.15 via-in-pad on each of the 36 FPGA power balls, one for each net on its plane.
- Escape: `bt fan` on the DDR3 (with ground and both DRAM power nets as planes): 33 nets, 108 tracks and 50 vias written, 24 pins left. On the FPGA: 83 nets, 100 ground vias dropped, 19 signal vias and 102 tracks kept, 102 pins left.

**Why**
- A cap under an interior ball takes that ball's via site. The fan could then via only 129 of 233 pads. Moving the caps off the field let it via 159.
- Plane connections for the interior power balls had to be via-in-pad, because no other route exists at 0.5 mm pitch.
- Ground vias for interior balls would have cut every power plane below them, so ground comes from the front pour instead.

**Result**
- `bt check` (with fresh fills): 86 DRC errors. The original board has the same 86 (84 edge clearances from the locked Feather header pads, one malformed locked courtyard, one locked courtyard overlap). The rest are unconnected pads and nets still in pieces, which routing has to fix.
- The image shows the state after the escape vias and before routing.
