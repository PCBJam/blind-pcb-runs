# 005 – every signal net routed (before ground pours)
What happened between 004 and this picture:
- CM4 left connector by hand, from the pin order: SD lines wrap round the south end of the connector on F.Cu and enter the socket pads in order (only SD_CLK and SD_CMD need a short B.Cu hop); CM4_RUN/RST/BOOT/EN go east as a 4-lane B.Cu bus to the RP2040, the two UART lines beside them on F.Cu; IMON/VMON go north on B.Cu to the hot-swap controller; I2C and +3V3 by hand after two router attempts gave 4–7 vias per net.
- A first `bt route` batch over the same corner (13 of 18 nets, SD_DAT3 57 mm for a 31 mm link, ETH_LED1 with 4 vias) was not applied – thrown away.
- Long, slow nets across open board (M2PWR_EN, PCIESWPWR_EN, TSENSE_0..3, fan 4, LED_V+) were left to `bt route` with the power pours fenced off as keep-outs and the pair clearance temporarily raised to 0.3–0.35 mm so nothing hugs a PCIe/USB/Ethernet pair. Result is long 45° runs on F.Cu with short B.Cu hops under the 12 V / 5 V buses.
- TSENSE_0 first ran through the +3.3VA bottom pour (keep-out list was stale); found with a script that intersects tracks with pour outlines, re-routed.
Still open at this point: GND (pads only joined through the planes where a via exists).
