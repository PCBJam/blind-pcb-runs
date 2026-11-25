# 010 — VIOA routed (`bt route --net /IO_Banks/VIOA --all --width .25 --layers F.Cu,B.Cu`)

30 of 30 links routed in 53 s, 36 tracks and 10 vias, 77 mm of track in total (F 50 mm, B 27 mm).
Shape: a trunk on F across the top of the IO-A area from the regulator side (x 118-123) to U19.16, a
branch that drops through two vias to the B-layer caps of the left and right level-shifter columns,
and a long link to J2.2 at the top. The VIO pins are on the inner column and their caps on B.
Kept: the route is clean against everything on the board at the time (probe clear).
Open: the trunk is long for what it feeds; a shorter trunk along the x 103-105 strip would save ~15 mm.
