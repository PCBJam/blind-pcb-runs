# 004 – FX2 power stubs, FX2 <-> FPGA bus on F.Cu, bottom-layer escapes under the BGA

- FX2 (U1): GND pins tied straight into the exposed pad, each +3V3 pin gets a 0.45 via at the pad end and a short
  B.Cu link to its decap under the pad row; decap GND pads go to the pad's thermal vias.
- `bt route --nets` could not start from the QFN pads at all ("the path found doesn't join the start"): it leaves a
  0.5 mm pitch pad diagonally and then rejects its own first segment. Work-around: a 1.1 mm straight stub on every signal pin.
- First router run for the 12 bus nets: 10 ok, D5/D6 failed and D3/D4 wandered around TP2. Thrown away.
- Worked out by hand which nets can be planar on F.Cu (PKTEND, A0, A1, OE, ALERT, FLAGA/B/C, D3..D7) and drew D3..D7,
  FPGA_DONE and FPGA_RESET myself: D6/D7 pass north-west of R9, D3..D5 south-east of it, RESET lands on R9 in the wedge
  between them. The other seven went in with the router in one pass, no vias.
- B.Cu escapes under the BGA drawn along the lanes planned in step 002 (D0/D1/SDA west past the PLL filter, eight
  nets through the south window, four east past the PLL1 filter), PLL filter links, decap links.
- `bt apply` ignored the "remove" uuid prefixes in my items file without saying so; used `bt rm --uuid` instead.
