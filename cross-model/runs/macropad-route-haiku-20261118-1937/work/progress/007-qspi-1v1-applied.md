# 007 — QSPI and +1V1 applied; ratsnest for the rest

Applied, in this order (the order matters, see 005):
1. Key GPIO nets: five of six (KEY1, 2, 4, 5, 6) from the router, applied. KEY3 is still open (see 006).
2. +1V1: cap C115 to DVDD pin 23 (F.Cu stub), pin 23 to VREG pin 45 through the chip's north interior (F.Cu, y = 106.08), pin 45 via at 104.1,105.98 with B.Cu links to C116 and C117, and pin 50 (DVDD) by a 8 mm F.Cu loop round the west of the USB resistors into the same network. Old attempt with a via at 103.0,108.2 was rejected: it was in SD3's only lane.
3. QSPI: five nets F.Cu-only (SS, SD2, SD0, SCLK, SD3) with no vias in the west fan. SD3 (24.7 mm) now clears pin 50's loop. SD1 failed on F.Cu (boxed by SS) and goes up on B.Cu with two vias at 104.09,115.91 and 104.09,110.41.

Still open in the ratsnest: KEY3; +3V3 (23 pads); the LED chain (5 DOUT->DIN links plus LED_DIN); +5V_LED (16 pads); LED_EN; LED_DIN_3V3; GND (pours not yet placed).

Picture 007-qspi-1v1-applied.png: the RP2040 west fan, QSPI runs and the 1V1 loop.
