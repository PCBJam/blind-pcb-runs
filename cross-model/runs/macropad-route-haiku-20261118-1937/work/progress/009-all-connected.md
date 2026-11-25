# 009 — every net connected (ratsnest 0), GND pours on both layers

Sequence to get here (each step probed before applying):
1. Six GPIO nets: KEY1-6 routed together on a scratch copy with rip-up (6/6, 4 shoves). Old KEY4/5/6 copper was removed first. Applied. Before, KEY3 had failed in every ordering I tried (see 006).
2. TESTEN (RP2040 pin 19, must be GND): stub into the exposed pad (F.Cu, 3.6 mm via the EP thermal via). First attempt, a straight stub, was blocked by the 3V3 run from pin 22.
3. 3V3 pin 22: removed the old interior run, routed a 0.4 mm via at 110.9,107.9 that lands on the C108.1 decap pad (B.Cu side).
4. GND pours on F.Cu and B.Cu (bt zone --outline). Nine isolated GND pads: four joined with a via each, the EP joined with four 0.6 mm thermal vias inside the exposed pad (107.4,107.0; 109.4,107.0; 107.4,108.6; 108.5,107.6). The ESD GND pin (U102.2) is joined through a 0.4 mm via at 96.75,106.5 that overlaps its own pad and clears the USB bridge.
5. 61 GND stitching vias on a 4 mm grid (bt stitch).

Result: bt ratsnest reports 0 unconnected nets and 0 mm. bt check: CHECK OK. Picture 009-all-connected.png.
