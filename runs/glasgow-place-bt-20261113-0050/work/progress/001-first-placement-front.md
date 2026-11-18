# 001 – first scripted placement (front view)

Floorplan decided from the netlist:
- FPGA (U30) centred under the LVDS header J5, rotated so the LVDS balls face J5, port-A balls face east, port-B balls south, FX2 balls west.
- FX2 (U1) below-left of the FPGA next to the USB-C connector; LDOs for 3V3/1V2 between USB and FPGA; bulk cap C87 beside them.
- Port A level shifters in one row under J2, port B in one row above J3, each with ESD + series arrays on the connector side, 0402 decoupling on the back under each buffer.
- VIO regulators / DAC / INA233 in the strip between the right mounting holes (A top, B bottom).
- LEDs along the bottom-left edge, EEPROMs above them, reset button on the left edge.

Result: placement script `tools/place.py`; ~20 courtyard conflicts left (USB/LDO corner on the back, some test points). Not applied to the real board yet.
