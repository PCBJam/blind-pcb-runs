# 007 first routing stage: DDR3 data/address and FPGA signal nets

**What:** Routed the DDR3 nets with `bt route --nets "RAM_*"` (escapes-first, 0.089 mm tracks, 0.28/0.15 vias on F.Cu, In2.Cu, In3.Cu and B.Cu), then the non-DDR signal nets in one batch with 0.127 mm tracks. Applied with `bt apply --checked`. Also added the GND pour on B.Cu, removed the ground vias that the DDR3 escape had put in the DDR3 field, and stitched GND (26 vias).

**Why:**
- The DDR3 escape vias for ground pins were walling in the field. Ground balls are already connected by the front pour, so those vias were removed.
- The routes are run with short searches after the first pass, because a 20 s search per net was very slow.

**Result:**
- DDR3: 38 of the 56 RAM nets routed, 18 still open (the figure was corrected in the final state note). The blocks are the routed DDR3 neighbours on the front and inner layers around the DDR3 field, and the reference-voltage caps on the back column at x 166, which sit in the channel.
- Signal batch: 36 of 76 nets routed. The rest are blocked around the FPGA's north-west and south-west edges, where the DDR3 tracks now run.
- `bt check`: 86 DRC errors, which is exactly the original board's count (84 edge clearances from the locked Feather header pads, one malformed locked courtyard, one locked courtyard overlap). 265 unconnected items and 139 nets not fully connected remain.
- The picture shows the state after these two batches.
