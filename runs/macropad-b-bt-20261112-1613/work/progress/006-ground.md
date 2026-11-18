# 006 – ground
- `bt escape --net GND` gave a stub+via for 52 of 57 ground pads; the "via in pad" proposals for the socket pads, C101 and
  the QFN pad were dropped, the rest applied. The five it could not do were linked by hand (C115-C117, C116, C102-U101,
  cap column, D301).
- GND pours on both layers (pcbnew script), 71 stitching vias on a staggered grid, each checked with `bt probe`.
- DRC then showed one unconnected item: the QFN exposed pad. The 3V3 ring closes it in on B.Cu and the USB D+ track ran round
  the vias on F.Cu, so pad + 4 vias were an island. Fix: D+ now cuts diagonally under the chip, which leaves the F.Cu copper
  under the QFN open to the west over ~4 mm. TESTEN (pin 19) got its own track to the SW501 ground pad (R105/C201/C113 shifted
  0.35 mm to make room for it).
Picture: F.Cu after the fix.
