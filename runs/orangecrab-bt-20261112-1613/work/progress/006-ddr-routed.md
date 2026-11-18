# 006 – DDR3 routed (kept)
All 47 DDR3 nets connected, DRC-clean.
- Clock: hand-routed fly-by pair on F.Cu only (no vias): FPGA J18/K18 -> along the bottom of the FPGA -> up the DDR centre channel -> balls J7/K7 -> continues to the 2x51R + 100nF terminator above the DDR (the far end of the line, not a stub).
- Every FPGA and DDR escape via was placed by hand from a per-ball site table (interstitial sites, depopulated-ball sites, vias in the 2.5 mm gap for the outer two rows; centre-channel dog-bones on the DDR).
- Links via-to-via: tools/bus2.py assigns ordered lanes through the DDR via columns (2 tracks per 0.8 mm via gap), draws the DDR-side geometry itself and uses `bt route` only for the FPGA-side hop; address group processed south-to-north, data group north-to-south so that earlier links do not box in later ones. 32 links on In2/B.Cu that way, the rest by hand-directed `bt route` calls.
- D7, D5, D3, D8 are F.Cu only (through the ball lanes).
- Compromise: 10 short links (A4, A8, A14, A15, BA1, D1, D10, D14, LDM + none longer than 11 mm) had no planar slot left on In2/B.Cu and went on In3, which is otherwise the power layer. They stay in the FPGA-DDR gap and the first DDR columns, reference In4 (GND), and the power pours go around them.
What did not work on the way: `bt route --shove` removed other nets' hand-placed stubs and vias in the scratch copy; through-points give only "target is boxed in" when anything is in the way.
