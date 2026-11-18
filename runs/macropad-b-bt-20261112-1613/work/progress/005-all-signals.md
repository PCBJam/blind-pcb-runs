# 005 – keys, LED chain, enable, BOOTSEL: everything but ground
- First try with `bt route --batch` and layer-tagged waypoints: 3 of 4 routed but with pointless via pairs (it changes layer
  at every tagged point) and KEY4 boxed in. Thrown away; keys written by hand instead (stageE.py).
- KEY2/KEY3 on B.Cu; KEY5/KEY6 via in the channel above the MCU, F.Cu along the top and down through the flash pocket;
  KEY1/KEY4 on F.Cu threading between the SW201 holes.
- LED_EN and LED_DIN_3V3 leave pins 8/9 in the wrong order for their targets (enable goes east, data west). Fixed by taking
  LED_EN the long way: west, up the left edge, along the top edge, down the right edge (≈150 mm, static signal).
- First attempt shorted LED_EN and LED_DIN_3V3 where one turned north across the other (KiCad DRC: tracks crossing); the two
  were swapped in the channel below the MCU.
- LED data chain uses short F.Cu hops; bottom-row LED supply is an F.Cu trunk along the bottom edge.
Result: 0 errors, only GND unconnected.
