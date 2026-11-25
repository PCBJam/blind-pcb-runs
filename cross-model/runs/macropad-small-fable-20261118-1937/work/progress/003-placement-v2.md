# 003 – placement v2 (kept)

Changes from 002:
- LDO U101 with C102/C104 moved next to the fuse, right of the USB pads (VBUS → F101 → U101 in 3 mm).
- U102 (USB ESD) turned 180° and placed directly above the connector pads so D+/D- flow through it
  (connector on the east pins, MCU on the west pins).
- 27R resistors R103/R104 vertical, in line with the pair on its way up to pins 46/47.
- West column next to the MCU: C105 (pins 48/49), C116 1uF (VREG_VOUT pin 45), C112 1uF + C108 (pins 42-44).
- C107 below pin 33, C106 at pin 22, C115+C117 at DVDD pin 23, C103+C111 at pin 1, C114+C118 at the flash.
- C501 moved above D501 so the LDO fits; CC resistors R101/R102 at the connector.
- Board left edge at x=109 (board 67.15 x 38.1 mm, was 89.15 x 38.1 with an L-shaped 30 mm block).
All 19 moved parts pass bt place (courtyards, pad clearance); locked parts untouched (bt same).
