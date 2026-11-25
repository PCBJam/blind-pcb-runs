# 002 – placement revised before routing
Working out the PCIe pair order showed three things, so parts moved:
- U12 shifted to (171, 87.5): its port-2 pairs need ~5.5 mm of 45° run to reach socket J3's lanes, and its SW corner must clear the H10 standoff pad (first try shorted pin 48 to it).
- The two core bucks (1V2, 3.3VA) moved south to y 105/113 on the back so their vias stay out of the top-layer pair lanes of port 4.
- Strap resistors R24/R26 moved to the back (they sat where the port-2 pairs sweep west); decoupling caps placed as a radial ring under U12 and around the RP2040 on the back.
Result: no courtyard overlaps, no shorts; locked parts untouched.
