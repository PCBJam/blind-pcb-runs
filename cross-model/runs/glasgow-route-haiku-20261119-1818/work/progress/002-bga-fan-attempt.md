# 002 — first BGA fan-out (bt fan U30, F/B/In2): PARTLY KEPT, then discarded

`bt fan U30 --layers F.Cu,B.Cu,In2.Cu` escaped 88 nets (rows 1-2 on F, dogbones to B, interior on In2),
but left 27: the interior power balls (D4, H4, D8, H8 +1V2; D6, H6, F8 +3V3; E4, G4 VIO_AUX) and about
ten signals. Its fan stubs also walled in D4 (the +1V2 ball), so the +1V2 net could not leave.
The GND vias I added for the BGA's centre (bt plane --ref U30) boxed in D4 further.

Decision: throw this fan-out away and redo the BGA with the power balls routed before the signals
(see 003 onward). The picture shows the outer-ring escape is fine; the centre is the problem.
