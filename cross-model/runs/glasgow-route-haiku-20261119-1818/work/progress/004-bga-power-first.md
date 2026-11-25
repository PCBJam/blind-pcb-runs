# 004 — BGA redone, power balls first (kept)

Order that worked: (1) the interior power balls get a short F stub to an interstitial via and a B.Cu
track to their own decoupling cap (D4->C24, H4->C25, D8->C77, H8->C18, F8->C23, D6->C21);
(2) `bt fan U30 --layers F.Cu,B.Cu,In2.Cu` with those already on the board: 88 nets escape, and all of
its items probe clear; (3) the centre GND balls get In1 vias (`bt plane --ref U30`, 0.45/0.2), with one
GND via moved to free H6; (4) H6 (+3V3) gets an F stub to a via at (82.4,95.2) and an In2 track west
into the +3V3 frame; C10 and L11 join nearby +3V3 copper (trial only so far).
The picture shows the outer rings escaping on F, the next ring dropping to B.Cu through dogbones and the
centre using In2 under the window. Still open here: the GND centre (fixed in 005) and +1V2/VIO_AUX.
