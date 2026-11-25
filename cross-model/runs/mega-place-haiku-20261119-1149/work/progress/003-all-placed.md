# 003 — every part placed

The remaining small parts placed with `bt near` (each next to its pad) and by hand where
the corridors mattered. Decisions:
- Corridors kept free for routing: the strip above the TQFP (AVCC/AREF/ADC escape area), the
  gap between the TQFP and J5 (30 signals), the gap between J12 and the TQFP's west edge, and
  the bottom strip between the TQFP and J9/J10.
- USB parts (R3, R4 CC pull-downs, RV1/RV2 ESD varistors, FB1 shield ferrite, F1 fuse, RN2
  22 ohm array) beside J1 and between J1 and the 16U2.
- LEDs D1/D2 (TX/RX), D5 (L), D6 (power) and their resistor arrays RN3/RN4 kept off the 16U2
  pins (the first trial had them blocking the 16U2's east pins).
- JP1 (solder jumper, both pads GND) moved to the top side (it was on B.Cu).

Checks: courtyard overlaps only between locked parts already in the file. bt congestion shows
the expected hot spots: the 16U2's QFN pins and the TQFP bottom-left corner (before escape).
