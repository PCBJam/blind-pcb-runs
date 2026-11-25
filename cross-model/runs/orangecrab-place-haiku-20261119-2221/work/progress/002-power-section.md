# 002 power section on the front-left

**What:** Charger U5 went to the back-left under the battery connector (147.67, 99.88). Mux U9 went to the back-left near the analog header pins (152.27, 110.8). Flash U6 went to the back-right at the FPGA's north-east corner (178.1, 98.6). Buck converters U7 (3.3 V), U2 (1.35 V) and U1 (1.1 V) went to a column on the front-left at x 144.5, with their inductors L3, L2, L1 beside them at x 148.4.

**Why:** Each buck is a switching loop (input cap, IC, inductor, output cap), so the loops stay tight. The column sits between the battery input and the DDR3 and FPGA loads. The flash sits next to the FPGA's configuration balls. The mux sits next to the analog pins.

**Result:** No trial problems. The front-left area is now crowded, and the USB and SD routes will have to pass through it.
