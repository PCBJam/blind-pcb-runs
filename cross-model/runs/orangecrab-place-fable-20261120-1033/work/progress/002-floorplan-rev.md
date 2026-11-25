# 002 – floorplan revised (flash and 1V1 buck swapped out of the south strip; FPGA/RAM re-aligned)

What changed and why
- The flash's exposed pad sat exactly under the FPGA's south-edge pins, where ~20 signals need
  vias. Flash moved to the bottom south-east strip; 1V1 buck moved to the bottom, west of the FPGA
  under its all-GND west rows (the core plane can be fed from there without crossing other rails);
  LDO and rail test points to the bottom south-west strip.
- Oscillator moved to the top, north-east of the FPGA (the bottom gap between FPGA and RAM is
  needed for DDR vias); RGB LED next to it.
- After drawing the DDR lanes I shifted the FPGA up to y=102.30 and the RAM down to y=103.75:
  the FPGA's row-A/B escape lanes then meet the RAM's row gaps almost straight on (address and
  data nets on F.Cu need less than 0.6 mm of jog instead of 2-3 mm).
- USB test points moved into the strip between JST and JTAG header, tangent to the USB pair.

Result: placement of everything except the decoupling capacitors under FPGA/RAM (placed after the
breakouts so they sit between the vias).
