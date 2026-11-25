# 005 every part placed

All 54 footprints are now on the board. Unlocked parts are all on B.Cu, including J101.

Still to fix at this point:
- C120 (+5V_LED bulk, 1 uF) had only spots in the LED lanes. Moved it to the free top-left (96.5, 103) and will route its net to it.
- The block is 92 x 42 mm including empty margin. The final outline will be cut back with `bt outline --fit` after routing, keeping the key area inside.
- Net classes set with `bt rules`: Power (0.5 mm) for +5V, +5V_LED and the fuse's VBUS side; Vdd (0.3 mm) for +3V3 and +1V1; Default (0.2 mm) for everything else.
