# 002 – DDR3 (U4) fan-out, hand-planned

Every used ball of U4 gets a dog-bone to an interstitial via (0.3/0.15) that sits on a "half-row" line.
Tracks on In2 and B.Cu run west in fixed slots at row ±0.1 mm, two per row per layer, so no via ever blocks a track.

- East columns (1-3): 25 signals on In2 (stripline between the two GND planes).
- West columns (7-9): 5 data nets on spare In2 slots, 14 nets on B.Cu, CK± on In2 as a loose pair (termination R5/R13 reached on B.Cu from the same vias).
- A1/A8/A11/A14 leave on F.Cu over the top of the package (their order matches the FPGA corner, zero vias).
- Every power/ground ball has its own via (a few GND pairs share one); vias land on C34/C36 pads of the same net where the pads are in the way.

`bt probe`: all 286 items clear. Applied with `bt apply --checked`.
