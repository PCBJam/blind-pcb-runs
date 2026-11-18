# 009 – final state (not complete)

- After stripping the router's tracks from In2, every open link was retried with a keep-only-if-planes-stay-whole
  check (route → fill on a copy → compare `bt ratsnest` group counts). 7 rounds; the +3.3 V plane stayed in one
  piece throughout, MDC and most header nets came back, a few links were dropped because they would have cut
  the plane.
- Hand fixes: regulator feedback sense (via + 4.5 mm In2 jumper into the 3V3 plane), regulator GND pin,
  RMIISEL strap pull-up, PHY VDDIO supply, clock via restored, one via moved off the copper layer-number marks,
  one 1 µm clearance nudge.
- Outer pours: GND (logic side) and Earth (PoE side) on F and B, 5V_DCDC pour on F.
- KiCad DRC: 0 errors; 44 warnings (dangling ends of unfinished nets); 43 unconnected items in 25 nets.
  The open links (green dashes in the picture) are listed in NOTES.md. Time ran out here.
