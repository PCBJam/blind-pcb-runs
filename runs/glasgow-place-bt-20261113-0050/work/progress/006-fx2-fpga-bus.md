# 006 – FX2 <-> FPGA FIFO bus

The FX2 sits 2.2 mm west of the BGA. Eight control nets whose pin order matches (PKTEND, A1, A0, OE, ALERT, FLAGC, FLAGB, FLAGA) go straight
across on F.Cu; D2..D6 wrap round the FX2's south-east corner on F.Cu; D0, D1, D7, CLKIF leave the BGA on B.Cu.
Failed attempts kept for the record:
- `bt route --nets` on the whole group (three tries, with shove/rip passes): 18/22, 10/14, 8/14 – it boxed in D6/D7/CLKIF, wrapped RD right round the FX2
  and silently put tracks on In1/In2 although `--layers F.Cu,B.Cu` was given. All thrown away.
- Hand analysis showed FPGA_DONE, ~FPGA_RESET (pins on the FX2 side between the direct nets, balls below them), RD, WR and FLAGD cannot be
  untangled on two layers in this gap, so those five make one short hop each on In2 (4-6 mm, in the 3V3 plane). Documented in NOTES.
- PLL0 filter caps (C78, C76) sit on the back under the west ball columns where there are no vias.
Result: all FIFO nets connected, DRC clearance clean.
