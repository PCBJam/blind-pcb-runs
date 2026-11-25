# 006 Final state (what is in the file now)

**Status: not finished.** `bt check` reports CHECK FAILED with 17 DRC errors, 435 warnings, 147 unconnected pads,
38 nets in pieces and 0 bt findings. The 17 errors are all footprint-attribute mismatches on library footprints
(J1, J3, J4, J5, J7, U18 and eleven others): they come from the footprint definitions, which I was not allowed to
change. Locked parts: unchanged (`bt same`).

**Connected (ratsnest):** all PCIe lanes (four M.2 slots, the ASM1184 upstream, the AC-coupling caps), all Ethernet pairs,
USB (CM4 D+/- via L7, RP2040 D+/- to J15 apart from two series-resistor nets), +5V (one In2 island, fans, CM4 +5V pins),
+12P (DC input), +1V8, +1V2 (nearly; 4 small groups), +3.3VA (partly), the M.2 3.3V rails for M1, M2 and M4 (their
converter outputs and zones), and GND (240 of 256 SMD pads have a via into the planes).

**Not connected (ratsnest, 77 nets):** the RP2040 control and LED nets (LED_V+, LED_1, LED_4, PCIe_LED_1, PCIe_LED_4,
CM4_RUN, CM4_EN, M2PWR_EN, PCIESWPWR_EN, IMON, VMON, SCL_CM4, SDA_CM4, TSENSE_0..2, PCIe_RST_M2), the ASM1184 straps
(R23-R30, R36), +3V3 (CM4 peripheral rail), +3.3VSTB (RP2040 and flash rail), +12V inputs of the M2, M4, M1 and M3
converters' clusters and U2, the M3 and M2 3.3V pins, the M1 3.3V left pins, and the two unconnected shield pins of J7 and J15.

**Zone and plane summary:** In1 GND; In2 GND plus a +5V island; B.Cu +12V zone; four F.Cu +3.3V zones (one per slot).
