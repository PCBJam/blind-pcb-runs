# 003 decoupling on the back, first attempt (later reverted)

**What:** Put 12 DDR3 VDD/VDDQ caps on the back, each directly under a power ball, and 24 FPGA core/IO caps on the back under the FPGA's power balls.

**Why:** Caps directly under a ball give the shortest connection.

**Result:** Placed with no trial problems, but this was a mistake for the FPGA. `bt fan` then found only 129 of 233 pads could get a via: the caps' pads sit on the via sites of the interior balls. Under a 0.5 mm pitch ball field every interior ball needs a via site, and caps under the field remove them. The DDR3 caps had the same problem for the signal columns. Both groups were moved in step 006.
