# 004 – general routing pass (bulk), after the PCIe and Ethernet pairs

Picture: `004-bulk-pass.png` (full board, F.Cu red, B.Cu blue, In1 green, In2 amber).

**What I did**

- `bt route --nets` over 137 nets (every net except GND, the zone-connected power rails, the PCIe and ETH pairs, and the USB pairs), `--order escapes-first`, `--passes 2`, 20 s per net, `--fixed` on the PCIe and ETH copper. It wrote to the board after each net.
- Run time 1922 s. Result: 124 of 137 nets connected, 112 vias and 693 segments written. Pass 2 (shove) moved some other nets' copper, and each moved net was checked to stay connected.

**What failed, and why**

- RP2040 (U18): PICO_PWM1, PICO_PWM4, LED_V+, TSENSE_0, TSENSE_2, TSENSE_3, PICO_LED_3. The LED nets routed early walled in the RP2040's east and south-east pins, so the TSENSE and fan nets could not get out. Needs a planned fan-out, not a second run with the same order.
- QSPI (U17): /QSPI_SD3 blocked by the SCLK and SD0 tracks beside the flash. Solved in pass 2.
- CM4 left block: SD_CMD (gave up at 20 s, long run to the microSD), +3V3 (0.3 mm start boxed in by SDA_CM4 and SD_DAT0). CM4_RUN and CM4_RST: the PCIe uplink copper walls off the module's control signals from the RP2040.
- Buck U2 (+1V2 feedback): Net-(C10-Pad2) and Net-(R24-Pad2) boxed in by the lane-3 PCIe tracks.
- +3.3VA: waits for the +1V2 zone vias (the router would wall in the unrouted +1V2 pads).
- PCIe_RST_M2: every route walls in R20.1 (+3.3V_M1); needs a hand route.

**Still open after this pass** (not yet started): all zone vias (+12V, +3.3V_M1..4, +1V2, +3.3VSTB, +5V), all GND vias to the In1 plane, the two USB pairs, length matching of the ETH and PCIe pairs, zone refill, DRC.
