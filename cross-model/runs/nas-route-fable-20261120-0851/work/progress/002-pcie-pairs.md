# 002 – all 15 PCIe pairs
Routed first, by generated coordinates (script, then `bt probe` / `bt apply --checked`), because everything else has to give way to them.

- M.2 side: the pairs sit on the outer (odd) pad row, so each drops through vias under the connector body and runs on B.Cu under the inner pad row. RX and TX need P/N swapped between socket and switch pin order, so their two vias are placed in tandem and the pair leaves B.Cu mirrored (equal length by symmetry). GND pins 39/45/51/57 get their own via right next to the signal vias.
- Long runs on B.Cu over the In2 ground plane, 0.15/0.15, 1.05 mm pair pitch, 45° bends only. Lanes jog 1 mm east to clear the temperature-header pins.
- At U12 every pair returns to F.Cu outside the ring of decoupling caps, so nothing runs on B.Cu under the switch: that area is free for a +1V2 island (In2) and +3.3VA (B.Cu).
- REFCLK pairs are in the wrong order at every socket relative to the switch pins; each crosses its slot's RX/TX where those are on the other layer (no extra vias).
- CM4 uplink on F.Cu all the way; only CM4-RX takes a 4 mm B.Cu hop under CM4-TX (pin order forces one crossing).
Result: 594 segments, 68 vias, probe clean. Intra-pair skew ≤1.4 mm before tuning.
