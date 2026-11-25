# 007 – FPGA -> series resistors, and the 16 direction (DIR) lines

- QA/QB (FPGA -> 33R arrays): 14 of 16 on F.Cu with no vias once the two second-ring balls had fixed escape stubs.
  QA4 needs one hop (via under the BGA, 3 mm on B.Cu); QA6 enters its pad from under the resistor array.
- DIR lines, bank A (DA0..7). Three attempts:
  1. `bt route` with the lanes fixed: 4 of 8, 16–30 mm, thrown away. 2. Same with more vias allowed: 5 of 8, thrown away.
  3. By hand. The eight lines leave the FPGA in an order that cannot reach their rows without one crossing, and the
     strip between the FPGA and the first shifter column is full on both layers. What unlocked it: DA1's ball (C8) is
     taken out on F.Cu between ball rows 8 and 9 instead of through a via, which removes the crossing. Then five
     F->B vias in a staircase, eight B.Cu tracks north at 0.45 pitch, each peeling off into its lane. First probe 28
     errors (peel diagonals 0.06 mm apart, vias on lanes), third probe clean.
- DIR lines, bank B (DB0..7): escapes on F.Cu south of the BGA to a via staircase, B.Cu east in order; `bt route` did
  the six B.Cu runs in one pass (needed `--no-guard`: it refused DB3 because a B.Cu track "walled in" an F.Cu SMD pad).
  DB0 and DB1 belong to the row at the bank boundary where bank A's bundle is in the way: DB1 goes round the east
  side of bank B on B.Cu (about 60 mm, static signal), DB0 hops twice to enter through the F.Cu gap between the banks.
- `bt unroute --box` removed whole tracks that only touched the box, including lanes I wanted to keep; redrawn.
All 16 DIR nets and all X/Y/Q nets are connected.
