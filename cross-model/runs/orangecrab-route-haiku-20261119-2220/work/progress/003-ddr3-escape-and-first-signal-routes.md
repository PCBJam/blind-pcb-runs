# 003 - DDR3 (U4) escape, DDR3 power/ground vias, first DDR3 signal routes

**Order changed on purpose.** The first attempt routed the rails (P1.1V, P3.3V, P1.35V, P2.5V) with their
decoupling links first. Those links ran on F.Cu/B.Cu/In2 across the channel between the FPGA and the DDR3, and
the DDR3 signals then failed (18 of 50 in pass 1). That attempt was thrown away; the board was rebuilt from
`/tmp/nm/order_g` (the FPGA cluster only: ground microvia stubs, power through vias, In4/In2 power tracks in the
cluster) and the DDR3 was done first.

**Steps in this version**
1. `bt fan U4` on a scratch copy with the DDR3 ground and power balls cleared: 50 of 53 signal nets escaped (N, E, S, W exits; the middle 3-column gap of the BGA is used by In2 exits).
2. Applied the escape. Then `bt via --near` for the 38 DDR3 ground and power balls (through vias, 0.28/0.15). The site solver was tried first but found too few legal sites once the escape copper was in place.
3. VDD and VDDQ routed to their balls and FB2/FB3 on In4/F/B (`bt route --all`, 0.3 mm): VDDQ 15/15, VDD 14/14.
4. `bt route --nets "RAM_*"` on F.Cu/In2/B: 41 of 50 connected; 9 gave up (RAM_CK±, RAM_D11, RAM_D12, RAM_D15, RAM_A10, RAM_A13, RAM_BA0, RAM_CAS#). Routes go around the FPGA's top and bottom edges because the fan exits on the far side of the DDR3 have to wrap round the BGA: this is the main quality problem so far (long detours, byte-lane length matching is not done yet).

**Picture:** `003-ddr3-escape-and-first-signal-routes.png` (F/B red/blue, In2 orange, In4 teal, FPGA cluster in the middle of the teal copper).
