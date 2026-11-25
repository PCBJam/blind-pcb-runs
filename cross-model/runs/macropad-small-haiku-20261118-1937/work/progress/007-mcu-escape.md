# 007 RP2040 bottom escape

Problem: the +3V3 stubs to the cap C114 and to the bottom pins ran down the lane next to USB D+/D- (pins 47 and 46) and left them boxed in. `bt route` could not reach the USB pins.

Fix:
1. Unrouted the +3V3 copper in the box x 107.5..113.6, y 112..116.6 (14 segments; the net then split into 8 pieces, re-routed later).
2. `bt escape U103 --side S --keep "Net-(U103-USB_DP),Net-(U103-USB_DM)"` planned stubs and vias for the QSPI, +1V1 and +3V3 pins on the south edge, and kept D+/D- on B with their way out free.
3. Applied the plan (9 vias).

Result (picture): USB D+ and D- now reach their series resistors on B.Cu. QSPI and the rest of the bottom pins leave by their vias. Routing of the rest of +3V3 and +1V1 followed (see the next steps in the log).
