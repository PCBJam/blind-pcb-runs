# 012 – ground: pours, plane vias, DRC clean-up

**What**

1. GND pours on F.Cu and B.Cu (clearance 0.2 mm, islands removed). That alone took the ground net from
   120 separate pieces to 19 – but a pad that only hangs on a pour is not a ground connection I trust.
2. A via into the In1 plane next to every ground pad that had none within 0.9 mm: a loop over
   `bt via --near REF.PAD` placed 143 vias (about 30 min).
3. **Mistake, caught by `bt ratsnest`:** 32 of those vias were next to the level-shifter decoupling caps,
   which already had a ground via 1.1 mm away. They perforated the narrow +3V3 strip that runs on In2
   between the VIOA/VIOB comb teeth and cut six shifters off from 3.3 V. Removed those 32 vias again
   (my 0.9 mm threshold was too strict for that block); +3V3 is one piece again.
4. Four pads no via could reach, fixed by hand: C81.2 (FPGA corner – moved DB7 0.15 mm, via beside the
   cap, 2.3 mm B.Cu link), C20.2 (B.Cu link to the via at C85.2, a redundant 3V3 link removed to make
   room), C88.2 (via at the pad edge), R9.1 (moved the IFCLK B.Cu diagonal 0.8 mm, via in pad).
   C87 (150 µF) got a 0.5 mm via in its ground pad and a wider stub.
5. 30 stitching vias (4 mm grid, only where both outer pours exist).
6. DRC round: two leftover stubs removed; thermal reliefs of the header ground pins were "starved"
   (one spoke) – smaller relief gap on the outer pours, the DB1 track along the south edge moved 1.4 mm
   away from the J3 pins, VIOB island widened round J3 pin 2.
7. **Planes were 0.05 mm from the board edge** (the project's edge-clearance rule is 0.05). All four
   full-board zones now use an outline pulled back 0.4 mm. An empty pocket in In2 under the bank-B
   connector (cut off from 3V3 by the J7 pin row) became a small ground island.

**Result:** `bt ratsnest`: 0 unconnected. KiCad DRC (kicad-cli, zones refilled): 0 unconnected, no
clearance/short/hole violations. Left: 4 `footprint_type_mismatch` errors and 414 warnings (library,
silkscreen, courtyard) – all properties of the footprints/placement as supplied, none about copper.
475 vias (165 of them ground), about 2400 track segments. (Three vias from the loop were taken out again in a last look: two sat on FPGA ball pads, one on the tip of an FX2 pin.)

Picture: all layers, final state.
