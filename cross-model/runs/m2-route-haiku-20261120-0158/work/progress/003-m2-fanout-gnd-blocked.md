# 003 — why the M.2 ground pins cannot be reached (zoom on J2, state after lanes)

Picture: the M.2 fan-out, x 105.5-116, y 86.5-111.

Finding: the M.2 edge has 14 ground pins, all on the B side, interleaved with the lane pins
at 0.5 mm pitch (each finger is 0.35 mm wide and the F-side fingers at 109.4 mm block vias
east of x 109.4 at their rows). A ground via has to sit at x about 109.8 (clear of the F
fingers) or in the next column, and every lane corridor that runs down the west side of the
fan (D3 at x 110.2-111.2 on In1) sits 0.08 mm too close to a via at x 109.8. So:
- pins 1 and 3 (top) are blocked by the +3V3 fingers' bus,
- pins 9..57 and 71..75 are blocked by the lane corridors and the lane vias at x 111.4,
- probe of via sites at x 112.0: only rows 89.77, 91.27, 92.77 were clear.

Attempt that followed (see 004): move the whole fan-out 2 mm east so x 109-111 is free.
Result: not enough routing room; rolled back.
