# 001 core placement: FPGA and DDR3

**What:** Moved U3 (LFE5U csBGA285) to (171.5, 102.5) rotated 90 deg, front side. Moved U4 (DDR3 BGA-96) to (161.5, 102.5) rotation 0, front side.

**Why:** The free space is the central band between the Feather rows (about 42 x 17 mm). The DDR3's data and address balls should face the FPGA's DDR banks, which sit on the FPGA's west edge at rotation 90. I scored the four rotations by the wire length each implies to the fixed connectors and the DDR3 (`orientscore.py` in the notes folder): rotation 90 was best, and 171.5 was better than 172.5 or 173.5.

**Result:** Both placed with no trial problems. The DDR3's east columns face the FPGA's west edge with about 3.4 mm of channel between them. The flash, the crystal and the power ICs still have to be placed.
