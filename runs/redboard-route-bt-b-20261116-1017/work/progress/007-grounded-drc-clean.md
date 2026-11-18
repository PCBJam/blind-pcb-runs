# 007 – grounding, DRC rounds, skew tuning, final file
- `bt plane` gave ~50 GND vias, `bt stitch` 73 more; an F.Cu ground pour was added. About 25 GND pads in the dense areas still had no ground
  (cap column west of U1, caps south of U1, the TVS D2 and LED D5 that sit right over the USB-HS pair). Fixed one by one: short top-layer links,
  vias at/inside the pad where nothing else fits, and small re-routes to make room (SD rows jogged on B.Cu, DSI D0 bends earlier, USB-HS pair moved 0.45 mm under D2, reset track nudged).
- KiCad DRC rounds: neck width 0.12192 printed as 0.1219 (below the minimum) → set to 0.122; thermal spokes starved on the F pour → solid pad connection;
  3.3V islands on In2 found twice (cut off by In2 tracks) → region re-shaped / charge-LED net moved / lane tied in through R27.
- `bt tune` on the MIPI pairs: only part of the skew could be taken out (runs too short): residual ≤ 2.4 mm.
- Outline moved back into footprint H1 (`scripts/edge.py to_final`); final check with kicad-cli incl. schematic parity:
  0 unconnected, 0 parity, no new errors (12 courtyard overlaps and 4 silk warnings were in the board as received; 4 via-dangling warnings are mine).
