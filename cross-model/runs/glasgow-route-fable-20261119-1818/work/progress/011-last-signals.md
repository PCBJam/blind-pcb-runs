# 011 – last signal nets (east of the FPGA, long control lines)

**What:** finished every signal net that the router sweep (010) had left.

- *East of the FPGA* (FPGA balls A10/A11/B4/C9, R10, U32, R39/R43, PLL supply R32):
  reworked the "staircase" of DA4–DA7 vias by 0.1–0.3 mm so that DA6 and DA7 both pass north of R10,
  which frees the single-track gap between R10 and U32 for R39's net (F.Cu, then the third lane of the
  gap between the two shifter banks). R43's net goes on B.Cu under the same area and uses a B.Cu lane in
  the bank gap; DB0 moved from F.Cu to the second B.Cu lane. QB0 now leaves between balls A10/A11 so A11
  can reach R45.
- *SYNC direction line* (B4 → R10 / U32.5): no outer-layer path exists (DA fan on F.Cu, DA0/DA2 lanes on
  B.Cu), so it runs 11 mm on In2 (static control signal), with an in-pad via on R10.1.
- *PLL1 supply* (R32.2 ← +1V2): 7 mm, 0.25 mm track on In2 from the +1V2 via under ball D8.
- *C44/R24* (bank B current sense): one track was wrapped round R24.2; moved its via east.
- *ENVB and ~ALERT*: run as two extra B.Cu lanes next to ENVA – up the west side of J5, along the top
  edge (lanes at y 71.5 / 71.8 / 72.1), down the east edge (x 128.6 / 129.0). ALERT has to cross the
  FX2's ring of WR/RD tracks, which it does on In2 under the FX2's top pin row (no B.Cu signal runs
  along it there).
- *~CY_RESET*: 10 mm on In2 down the FX2–FPGA channel, then B.Cu/F.Cu to the reset circuit (router).

**Why this way:** these nets are slow or static; the fast buses keep the outer layers and an unbroken
reference. I tried the router first on each (it reported "boxed in"); `bt route` trial runs on a test
copy told me from which side the long nets could be reached at all.

**Result:** `bt ratsnest`: only GND is left unconnected (120 groups – pours and ground vias come next).
Not nice: five nets now have pieces on In2 (CLKREF 4.5 mm, SYNC-DIR 11 mm, +1V2 feed 6.5 mm, ALERT 18 mm,
CY_RESET 10 mm).

(Note: /tmp was wiped between sittings; helper scripts were rebuilt under /work/.w.)
