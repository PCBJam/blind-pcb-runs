# 001 – first floorplan (superseded in part by 002)

What: FPGA (U3) and DDR3 (U4) placed, then a first cut of the functional blocks.

Why this arrangement
- The ECP5 ball map fixes the big picture: with U3 at -90° all DDR pins face east, JTAG faces west
  (J6), SD/USB/ADC pins face north, SPI/config and header IO face south. U4 at 180° puts its
  address half (rows J-T) north and data half south, matching the FPGA banks, so the RAM goes east
  of the FPGA with a ~4.7 mm ball-to-ball gap.
- Top-left (between USB-C, JST and the JTAG header): charger U5 with battery pins towards the JST,
  analog mux U9 with its channel pins towards the A0..A5 header pins.
- Bottom strips north/south of the FPGA ball field: 3V3 buck (north), flash + 1V1 buck (south).
- Bottom right end: 1V35 buck next to the RAM, ferrites + bulk for RAM_VDD / RAM_VDDQ between them.
- Button on the top right end (only spot that takes a 5.2 x 3.3 mm part without covering a fiducial
  opening or the OSHW copper logo).

Result: all courtyards legal except bt's bbox-based warnings for parts without courtyards (SW1,
test points). Plan for the south strip changed afterwards (see 002): the flash's exposed pad sat
exactly where the south-edge FPGA pins need their vias.
