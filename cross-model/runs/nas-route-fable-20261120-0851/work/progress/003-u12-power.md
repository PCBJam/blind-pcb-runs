# 003 – power copper and the U12 breakout
- F.Cu pours (priority over the later GND fill): +12P from the jack through the TVS to the TPS2420, the +12V drop and a 2.1 mm bus along y≈82.5 with a tab into each M.2 buck's input caps, +5V at L1, each buck output (the four M.2 rails run under the connector edge to all nine 3.3 V pins).
- 12 V for the two central bucks (U2, U15) drops on B.Cu (0.8 mm, 2 vias each end) so the F.Cu corridor y 84–91 stays open for east-west traffic. I moved the J3 pair lanes (diagonal now right after the header) to make room for these taps on B.Cu.
- Under U12: +1V2 island on In2 (fed by a 3 mm "chimney" from the 1.2 V buck), +3.3VA pour on B.Cu (fed by a 2.4 mm strip from the 3.3 VA buck). No PCIe pair crosses either on B.Cu – they all come up to F.Cu before the cap ring.
- Every U12 supply pin goes to its own cap on F.Cu with a 0.45/0.2 via in the path (pin → via → cap), cap grounds have their own via, 3×3 vias in the exposed pad. All coordinates generated and probed (187 items, clean first time).
- SOT-563 bucks: SW to inductor at pin width (0.3), boot and FB nets by `bt route` on F.Cu.
Result: +1V2/+3.3VA fully joined except the two feedback dividers (next).
