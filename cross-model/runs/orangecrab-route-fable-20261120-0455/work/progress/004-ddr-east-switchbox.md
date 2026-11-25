# 004 – DDR3 address/control + lower data byte: FPGA east side to the U4 slots

What is on the board now:
- CK± and CKE leave the FPGA's south edge on F.Cu, run east below the BGA and north along x≈170.3–170.7 (east of the oscillator). CKE goes straight into ball K9 (no via); CK± drop to In2 right in front of U4 on their own "half-line", then the existing U4 vias take them to the termination resistors on B.Cu.
- A1/A8/A11/A14 on F.Cu over the top (no vias).
- 28 nets: FPGA ball -> short F.Cu escape -> one 0.28/0.15 via -> In2 or B.Cu slot track straight into the U4 dog-bone (2 vias per net in total).
- Inner FPGA balls (BA0, A15, RAS#, A2, UDM...) use pre-placed vias under the BGA and leave on an inner-layer "line" that was kept free of other vias.

Attempts thrown away on the way (all on scratch copies):
1. `bt route --batch`, no targets: 39/46 but CK took a 22–27 mm front-layer detour through U4's centre channel, several nets wandered over U6 -> rejected.
2. Batch with explicit targets and an F.Cu keep-out east of x=167: 23–27/30, 5 nets with 13–29 mm detours (the 1.2 mm strip is too narrow for the reordering).
3. `--nets` with rip-up, no keep-out, hard nets first, CAS# hand-routed through the gap between the oscillator pads: 28/28, all links 2.5–5.8 mm.  <- kept

Hand-seeded channel lanes at exactly 0.178 mm pitch made the router fail ("breaks clearance where the grid missed it"); re-spaced to 0.2 mm.
