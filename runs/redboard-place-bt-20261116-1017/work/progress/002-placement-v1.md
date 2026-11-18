# 002 – first complete placement
Floorplan:
- ESP32-P4 (U1) at 156,106, MIPI/USB/flash side facing north towards the two FPCs, SDIO side facing east towards the C5 module.
- ESP32-C5 module (U3) on the right edge between the standoffs, antenna end flush with the board edge.
- Flash U4 at the NE corner of U1 (pins 27-33), CSI series resistors in a row between U1 and the FPC corridor.
- Decoupling in a ring round U1 (west side is the dense supply side: two columns), buck (U5/L1/C6/C7) at the SW corner next to VDD_DCDC/FB/EN pins,
  crystal directly south of pins 99/100, LDOs + power mux SE near the 5V/3V3 header pins, charger + fuel gauge next to the LiPo connector.
- SD pull-ups in a column right at the card connector pads; USB ESD arrays and CC resistors at the two USB-C connectors; LEDs beside their silk labels.
- Bottom: test points and jumpers beside their bottom-silk labels, and the LM1117 block (U10, C52, C53, R16, R17, D10) under the SD socket, because a SOT-223 does not fit on top without covering silk or leaving the power corner; the tab gets a bottom pour for heat.
Result: no new courtyard overlaps (the 7 reported are between locked parts and were there before).
