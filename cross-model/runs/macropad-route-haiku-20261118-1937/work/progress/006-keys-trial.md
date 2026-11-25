# 006 — six GPIO key nets, router trial (5 of 6 connect)

bt route --nets KEY1..KEY6 --order escapes-first: 5 of 6 connect (KEY3 fails). Lengths: KEY1 17.7, KEY2 35.5, KEY4 28.4, KEY5 42.9, KEY6 59.4 mm. KEY3 cannot get out of pin 35 (108.7, 104.56).

Other orders tried: KEY3 first (4/6), short-first (4/6), hardest-first (4/6), all with 3 passes.

Why: the north edge pins 31-37 are at 0.4 mm pitch, and their escapes cross each other in the corridor between the chip and the top key row (2.3 mm tall). Each net needs a lane west of the other lanes' drops. I worked through the planar layout by hand: with one layer it is impossible, and with two layers it needs vias at specific points. bt fan U103 --side N confirms: only four of the six exits can be on F.Cu, and KEY2 has no way out.

Picture 006-keys-trial.png shows the five routed keys. Long KEY6 path runs across the channel on B.Cu.
