# 002 – planes created, FPGA (U30, BGA-121 0.8 mm) dog-bone fan-out

- Zones: In1 GND (whole board), In2 +3V3 (whole board), VIOA and VIOB combs, +5V south strip.
- `bt fan U30` was tried first (trial only): it left 16 balls and ignores which balls are LVDS pairs, so I threw
  it away and worked out the via map by hand: 53 vias (0.45/0.2) on interstitial sites, 63 short F.Cu stubs.
- Rules I held to: outer two rings leave on F.Cu; the six deep LVDS pairs get vias placed so each has a free
  lane north on B.Cu; no via on the row y=95.1, so /CLKREF runs D5 -> L5 on F.Cu between ball rows and In2 has an
  unbroken strip there for +1V2; decap pads on B.Cu sit on their ball's via.
- First attempt failed `bt probe` on 9 items: ball-to-ball GND links pass 0.075 mm from a neighbour's via.
  Fixed by giving every GND ball a dog-bone to a GND via instead. Second probe: all 119 clear.
