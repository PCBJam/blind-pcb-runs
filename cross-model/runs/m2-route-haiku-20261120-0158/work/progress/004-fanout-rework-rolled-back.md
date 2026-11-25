# 004 — fan-out rework to free the M.2 ground column: tried, rolled back

Picture: lanes after the rework (D3 corridors at x 112-113, the other 14 lanes routed
from vias at 113.0 / 113.6), before the rollback.

What I tried:
1. Moved the D3 corridors east (x 112.0-112.99) so columns x 109.8/110.6 are free.
2. Re-routed the other 14 lanes around them: first with vias at x 113.9-115 from site
   lists (0 of 7 routed), then with no-via boxes (x < 111.3: 7 of 11), then OUT-first order
   (8 of 14), then with horizontal-first exits to x 114 and 0.45 mm vias (7 of 14).
3. The six or seven legs that stayed open had no path: the B.Cu exits of the 0.5 mm pitch
   pins and their vias fill the space the router needs.

Rolled back to the complete lane set (all 18 legs routed) from before the rework.
Kept: D3 corridors as they were, every lane leg routed, no DRC errors.
