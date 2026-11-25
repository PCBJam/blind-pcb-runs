# 005 all parts placed (before routing)

**What:** Remaining passives, LEDs, button, crystal, LDO, test points, DDR3 VREF and ZQ parts. Front-side button (SW1) at the front-right strip, its debounce and pull-up beside it. Crystal on the back under the FPGA's west edge (later moved). Bottom LEDs on the front, between the FPGA and the Feather row.

**Why:** Each part next to the pin it serves, so the router only has to join pads.

**Result:** `bt same` confirms locked parts did not move and no pad nets changed. Everything is on the board. Congestion is high around the FPGA and DDR3 because the escape space is small.
