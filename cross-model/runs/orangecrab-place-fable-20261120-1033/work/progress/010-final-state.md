# 010 – where it stopped

**What I did since 009.**

* Remaining mux / analog-header nets: single-net `bt route` in a planned order, with hand-made
  first legs for IO_A1, IO_A2, IO_A4 (three more lanes through the gap between J6 pins 2 and 3,
  SD0_DAT0 shifted 0.2 mm to make a fourth lane). When the corner was full the router put
  ADC_MUX2, ADC_MUX3 and ADC_SENSE_HI on In4 straight through the 1V1 and 1V35 islands
  (ratsnest then showed the planes in pieces) – taken out again. The six nets that had no
  other way now run in In3 (ground) in the north-west quadrant. Not good, but connected.
* JTAG: TCK and TMS were boxed in between TDI and TDO (ball order differs from the header's
  pin order). Re-fanned on top: TCK leaves between two other balls so it comes out south of
  TDO, TMS goes through the gap between J6 pins 2 and 3 and round pin 2. R27 moved to pin 4.
  One GND ball (U14) lost its link for this.
* /IO/A4 and /IO/A5 along the south edge on In4; `bt plane` for the remaining power pads.

**What failed at the end.** The 2V5 rail, two groups of 1V35 balls, one gap in ECP5_VREF,
VSYS to D2 and about a dozen single ground pads are still open: every router call ended with
"no path" or "boxed in", and the 2V5 LDO turned out to be on the wrong side of the DDR bus.

**Result.** 27 unconnected items in KiCad's DRC; see NOTES.md for the full list. The board is
not ready to order.
