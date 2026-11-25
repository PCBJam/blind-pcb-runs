# 006 – front-layer links, ground pours, first full check

Picture: F.Cu after the pours (before stitching vias).
- F.Cu is the ground plane; it carries only what could not stay on the back: KEY1/2/3 (they have
  to cross KEY4-6 and the LED bus), the 0.4 mm +3V3 trunk LDO → MCU caps, +5V to the VBUS pin of
  U102, LED_EN, the BOOTSEL line and the +5V_LED tap for U106.
- Change of plan while ordering these: KEY5/6 + LED bus on the back and KEY2/3 on the front form
  a wall between the north and south halves of the board, so LED_EN and the BOOTSEL line could not
  take the short way. Both now run along the top edge (BOOTSEL 47 mm, LED_EN 63 mm) instead of adding via hops;
  KEY3 hops to the back for its run in the strip between the rows (4 vias, static signal).
- GND: 5 vias in the RP2040 exposed pad, a via beside every decoupling/LED cap and switch pad
  (`bt escape`), pours on both layers.
- First `bt check`: 2 errors. U106's courtyard touched the SW201 socket courtyard (bt place had
  passed it) and C501's courtyard covered the SW501 centre hole. U106 moved 0.65 mm down and
  re-routed; C501 turned upright. Seven ground pads had been boxed in by traces: crystal group
  moved 0.5 mm east, C701 0.4 mm west, U105 feed re-drawn so its GND pin reaches C119.
- Second `bt check`: CHECK OK, 0 errors, 0 unconnected.
