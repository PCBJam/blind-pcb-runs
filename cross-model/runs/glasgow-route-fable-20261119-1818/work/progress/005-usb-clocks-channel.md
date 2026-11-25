# 005 – clocks, WR/RD, config signals, crystal, USB

- Router attempt on the ten remaining FX2<->FPGA nets (vias allowed, 206 s): 6 routed, CLKIF and CLKREF "no way through",
  RD 26 mm round the wrong side, DONE/RESET blocked by RD. Thrown away except D0–D2 (rerun later).
- Why it is hard: IFCLK and CLKREF leave the FPGA between FLAGB and FLAGA, in a pocket that is closed on F.Cu by the
  bus and on B.Cu by FLAGD/WR/RD above and the DONE/RESET links below. Done by hand:
  * the F.Cu bundle was re-spaced at minimum pitch so IFCLK runs inside it to a via next to FX2 pins 29/30, then on
    B.Cu round the south of the FX2 to TP7 and pin 13 (one layer change each end);
  * CLKREF gets a via beside the PLL filter and a 4.5 mm hop on In2 to get out of the pocket (the only signal on a
    plane layer; noted in NOTES);
  * WR/RD run on B.Cu under the east pad row and round the north of the FX2; DONE/RESET drop to B.Cu in the wedge by R9.
- Crystal: both traces short on F.Cu, nothing else under Y1.
- USB: both D+ pads and both D- pads of the type-C receptacle are joined at the connector (D+ through TP15 on B.Cu,
  D- round the pad ends on F.Cu), pair runs on B.Cu (0.2/0.15) to vias at the ESD device U15, through its pads and on
  to FX2 pins 8/9. In2 under the USB/crystal corner is a GND island so the B.Cu pair and the crystal see ground.
  Pair lengths 13.5 / 14.2 mm.
- VBUS: 0.3–0.5 mm, both pad pairs joined on B.Cu through TP13. `bt probe` caught the first via positions 0.03 mm
  inside the hole clearance of the connector's locating holes.
- Slip: when I unrouted FLAGD I also removed its BGA via; `bt ratsnest` named it ("meets track on B.Cu with no via").
