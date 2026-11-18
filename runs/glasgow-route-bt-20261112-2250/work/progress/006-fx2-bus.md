# 006 – FX2 ⇄ FPGA bus, FX2 power pins, BGA west side
- Attempt 1 (thrown away): `bt route --nets` on the 22 bus nets, F+B, 3 passes: 4m39s, 12/22 connected; the rest boxed in by
  via "walls" under the BGA and by earlier greedy routes. Also `bt plane` had put 0.6 mm 3V3 vias right at the FX2 pin ends,
  blocking neighbouring pin escapes – removed.
- Rule change: class clearance 0.15 → 0.125 mm, min track 0.15 → 0.1 mm (both ordinary 4-layer capabilities). 0.1 mm necks are used
  only between BGA vias / between the bottom-side caps; everything else stays at ≥0.15 track and normally ≥0.15 gap.
- Kept (scripted by hand, 0 probe errors):
  * FX2 3V3 pins: in-line 0.45 via just past the pad, B.Cu stub to the 0402 cap right under the pin; GND pins and cap GND pads tie into the exposed pad.
  * Right-side control signals (PKTEND, A0/A1, OE, ALERT, FLAGA-C) as a planar 45° fan on F.Cu; D3-D7 + FPGA_RESET on F.Cu around R9
    (RESET lands on R9 on the way); D0-D2 + SDA on B.Cu under the cap field to vias below the FX2.
  * Signals that would have to cross the fan use In2: FPGA_DONE, FPGA_RESET (static), CLKIF (short, under the FX2 between thermal vias),
    and the FPGA D5↔L5 CLKREF link. WR/RD/CLKREF go on B.Cu round the north of the FX2.
