# 002 — crystal nets (applied)

XOUT (RP2040 pin 21 to R105 and the C113 node) and the C113 node came out of bt route on F.Cu in one pass. XIN (pin 20) failed in the router: it tried to shove XOUT and could not put it back, because Y101.4 (GND) sits between XIN and the crystal's XIN pad. I routed XIN by hand: pin 20 east to x = 112.8, down to the XIN pad at y = 110.85, with a branch to C109. Probed clear (closest pad 0.2 mm). Ratsnest for the three nets is 0.

Picture 002-crystal.png was rendered at the end, after everything else was routed. The crystal area in it is the same as at this step; nothing nearby changed later except the TESTEN/XIN area (see 009).
