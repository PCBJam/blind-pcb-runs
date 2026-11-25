# 008 – south side redone by hand: flash, J2 header IO, RAM reset, button

**What I did.** Ripped the autorouter's QSPI/SCK/ADC_CTRL/IO_A routes (ADC_CTRL0 was 64 mm long
and ran through the DDR lanes) and designed the south escape of the FPGA as one piece:

* The 15 south stubs now end in two staggered via rows (y = 107.05 / 107.46, 0.3/0.15 vias,
  0.57 mm pitch inside a row so one 0.09 track passes between two vias). The rows sit in the
  0.65 mm strip between the last ball row and the flash's exposed pad on the bottom.
* Flash: SCK, MOSI stay on top (one via each, right at the flash pad); SS/MISO/D2/D3 take two
  vias and a short In2 hop because their ball order is the reverse of the pad order.
* IO_A5, EXT_PLL+/- stay on top; the PLL test points were moved to sit right below the vias.
* IO_SCK/MOSI/MISO/0/1, RAM_RESET# and USER_BUTTON run as a 7-lane In2 bus under the flash and
  along the south edge (between GND planes), peel off into the J2 pins; RESET# and the button
  go up the east side of the RAM. IO_MISO's via was moved 0.15 mm so IO_MOSI can pass west of it:
  with that the lane order matches the J2 pin order and no net has to hop.
* RAM_CK- via moved 0.15 mm (straight under its ball) to make room for RAM_RESET#.
* Test points TP30/31/32, R31 moved; some rail vias in the south-east strip removed.

**Why.** The autorouter could not do this (see 007): the pattern only works when the via
positions are chosen together.

**Result.** All flash, J2-side IO, PLL, reset and button nets connected, every item probed
clean before writing. Flash SCK is 9.3 mm with one via. Still open: ADC/mux nets, IO_A0..A4,
SD card, LEDs, JTAG, rails for the moved test points, 2V5.
