# 006 — J5 corridor: the 30-signal bundle, and the attempts that did not finish (scratch copies)

The J5 header (30 signals) takes its signals from the east face of the TQFP (PA3–7, PC0–7,
PG0–2, RXD3/TXD3), the south-east corner (PD7, PL0–7) and the bottom pins (PB0). The corridor
between the TQFP's escape vias (x ~188) and J5's inner column (x 190.85) is about 4 mm wide.

Picture 006-j5-corridor-attempts.png is the best variant (sb4): 28 of 29 J5 nets connected. The
open net is PC3, and PC2 and PC4 wander round the inside of the TQFP ring, which is the router's only
way out.

Attempts, in order (all on scratch copies except the first, which was then undone):
1. All 29 nets in top-to-bottom order, both layers (real board, then undone): 27 of 29. PD7 and
   PG1 failed: the PC bundle had already filled the middle of the corridor.
2. PD7 (B.Cu) then PG1 (F.Cu) first, then the rest: PD7 and PG1 connect, then PC0 and PG0 are boxed
   in by the diagonals PD7 (B.Cu) and PG1 (F.Cu).
3. Layers fixed by hand: PG2 and PD7 on B.Cu; PG1, PC0, PG0 on F.Cu: PC0 went west into the TQFP ring
   and boxed PG0 in.
4. Cluster order PC1, PC0, PG1, PG0 first (adopted as the real board, sb4): 28 of 29. PC3 open;
   PC2 and PC4 detour into the TQFP interior.
5. Same nets, `--via-cost .4 --passes 3`: 28 of 29, with PC3 and PC4 detouring.
6. Interior keepout (no J5 copper inside x 181–184.4): worse. PA4, PA6, PC2, PC3, PC4 and PL0 fail,
   because the pads' own stubs need the interior to get round each other.
7. Neck tests (0.127 mm, boxed-in ends only): PC0 and PG0 still fail.

Why it does not close: the R-face middle pins (PC2–PC4) must climb through a band where the
cluster of PC0, PC1, PG0, PG1 and PG2 (descending) and PD7 (coming up from the corner) also run. On
two layers that is a crossing problem that needs a hand-planned layer assignment with vias, which the
router does not find. The fan-out itself (stubs ending at x 188.5, mixed F.Cu and B.Cu exits) made
it worse.
