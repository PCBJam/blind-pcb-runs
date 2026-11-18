# 003 – first zone attempt (kept as a failure record)
Added GND planes on In1/In2, GND pours on F/B, +3V3 (F column + B band), +12V (F+B).
Problems seen in the render / ratsnest:
- +3V3 and +12V polygons stopped 0.2 mm short of the socket pads (pads start at y=116.71) -> 2 nets open.
- GND fingers between the B.Cu pairs were dead-ended (connected only at the M.2 end).
Fix: extended the polygons over the pad tops, and added a GND via fence (one via in every gap where an
F.Cu pair column crosses a B.Cu pair row, plus three more per column further down).
