# 002 – first placement attempt (thrown away in part)

Board cut to a rectangle (x 109…176.15) and all loose parts flipped to B.Cu.
Floorplan: USB-C on the left edge near the bottom, RP2040 left of D201 with its
USB/QSPI side facing west, flash above it, crystal in the strip between the key rows.

What was wrong with this attempt (found by walking the nets before routing):
- LDO (U101) and ESD (U102) share the small area above the connector; the USB pair,
  the 27R resistors and the VBUS pin of U102 could not all get through without crossings.
- Horizontal 27R resistors in the west column left no way for the pair to turn south.
- C117 / spare 100nF caps not placed yet.
Next: LDO moves next to the fuse, U102 turns 180°, resistors go vertical in line with the pair.
