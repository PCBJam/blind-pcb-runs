# 002 – placement v2 (front)

Changed plan after working through the USB corner: with the FX2 below-left of the FPGA the USB pair had to run
alongside the connector pads and blocked the CC/VBUS/GND pad exits and the crystal. Now:
- FX2 sits directly east of J1 with D+/D- pins at exactly the height of the A6/A7 pads (3.5 mm straight pair).
- FPGA moved down/right to (76.4, 96.7), level with the FX2 so the FIFO bus is ~2 mm long; LVDS pairs get a clear field between J5 and the FPGA.
- Crystal north-west of the FX2, reset button + supervisor in the top-left corner, bulk cap and 3V3/1V2 LDOs south of FX2/FPGA.
- Port A/B rows shifted 0.6 mm east.
Result: no courtyard/pad conflicts reported by `bt place`; applied to the board.
