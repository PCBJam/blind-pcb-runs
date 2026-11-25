# 008 final state of this session

**What:** Last routing batches and the plane joins, then the full check.
- Power-side nets (VBATT, VSYS, EN, the buck feedback and output nets, C27, R-pulls): 18 of 25 routed with 0.3 mm tracks.
- Plane joins from `bt islands --fix` for P2.5V (1 via, 5 segments) and P1.35V (11 vias, 67 segments) applied with the checked write. The P1.1V joins (98 items, all clear when probed) were refused by the checked apply on the second write, so they are not on the board.
- Final `bt check`: 86 DRC errors, which are exactly the original board's errors (84 edge clearances from the locked Feather header pads, one malformed locked courtyard for J5, one locked courtyard overlap H4/FID6). 210 unconnected items, 114 nets not fully connected, about 1,250 mm of ratsnest, 65 dangling-track and 9 dangling-via warnings.

**Why:** Each batch was routed in the background with short searches and then applied with `bt apply --checked`, so every write was probed first. Batches were stopped when the pass was no longer producing routes, and the rest was kept for the notes.

**Result:** The board is not finished. The image shows the state. Remaining: about 30 DDR3 nets, about 40 non-DDR signal nets (the FPGA's north and south edges and the Feather IO/ADC/SD/JTAG/USB pads), the 1.1 V and 3.3 V plane joins, the DRAM VDD/VDDQ pieces, and the ground pieces. Details are in NOTES.md.
