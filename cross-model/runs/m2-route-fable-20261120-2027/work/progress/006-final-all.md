# 006 – final board
Last changes after reviewing each layer zoomed in:
- 44 GND stitching vias (bt stitch per region, then edited by hand: one dropped next to a pair via,
  the column bt put on the 12V zone edge moved to the mounting-pad side);
- local GND pours at the decoupling caps with tighter clearance than the board-wide B.Cu pour;
- +3V3 fingers: each finger now has its own stub past the pad end and the joining bar sits under
  solder mask instead of bridging the gold fingers; three J2 ground vias moved to make room;
- four more +3V3 vias tying the F.Cu pour to the In2 island earlier;
- net class Z85_PCIE via set to 0.5/0.25 to match what the pairs use.

Result: KiCad DRC at all severities: 0 errors, 0 unconnected, schematic parity clean; only the 20
"footprint library not configured" warnings the unrouted board already had. `bt same`: no
footprint moved. All 9 pairs 0.000 mm intra-pair skew. 362 segments, 189 vias, 21 zones.
Pictures: all layers, and F.Cu / In1 / In2 / B.Cu separately.
