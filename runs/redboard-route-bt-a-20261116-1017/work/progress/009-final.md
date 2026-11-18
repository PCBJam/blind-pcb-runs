# 009 – final board
Finishing steps after 008:
- 1.1 V island deleted; 1.1 V routed as 0.3–0.6 mm tracks (direct feed inductor → pin 91, chain to the other three pins), widened segment by segment where clearance allowed.
- Sub-minimum router necks widened (50 of 64; the rest are my intended 0.127 mm slot tracks).
- GND pours on F.Cu and B.Cu (thermal reliefs), 33 stitching vias, extra vias/links for the handful of GND and 3.3 V pads that ended up in plane pockets (R19, C26, J6.22, R30, R27, C41/C42, pin 62).
- The temporary board-level outline was removed and H1's own Edge.Cuts lines restored.
Result (kicad-cli DRC, all severities, with schematic parity): 0 unconnected, 0 parity issues, 12 courtyard overlaps + 4 silkscreen warnings (all in the original placement), 1 "dangling end" warning on a 5 V track that ends on its trunk. `bt same`: nothing moved.
Pictures: all layers, F.Cu, In2 (L3), B.Cu.
