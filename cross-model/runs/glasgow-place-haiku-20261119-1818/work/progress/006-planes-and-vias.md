# 006 — planes, plane vias, and the state of the remaining routing

**What I did**
- Planes: In1.Cu = GND (zone over the whole board). In2.Cu = +3V3 (zone over the whole board).
- Tried In2 islands for +1V2, VIOA and VIOB (priority 1). Deleted them again: each island covered +3V3 pins (FPGA VCCIO pins, the buffers' VCCA pins), which would have been cut off from the +3V3 plane. A VIOA finger/comb version (9 zones) was also tried: every candidate via spot at the buffers' VCCB pins was blocked by routes already on the board, so it was removed.
- One via per surface-mount GND pad (`bt via --near PAD --radius 2`, applied one at a time): 193 of 206 placed. The 13 without a spot within 2 mm were retried at 5 mm.
- One via per surface-mount +3V3 pad: 78 placed; the rest are FX2 power pins and buffer VCCA pins in the crowded areas.
- `bt islands --fix` joined the GND pieces no pour can reach (34 segments, 10 vias).
- Power rails routed as tracks (+1V2, VIOA, VIOB, VIO_AUX, +5V): 0 of 5 routed in the first pass; every route is walled in by decoupling caps and buffer pins.

**State after this step** (`bt ratsnest`): GND 7 groups left (7 mm), +3V3 15 groups left (22 mm); 100 signal/power nets open in total.

**Why**
- The GND and +3V3 pads had to be stitched by vias one at a time, since the planes are on inner layers. Placing them sequentially lets each via see the previous ones; a batch placement would have produced clearance conflicts.
