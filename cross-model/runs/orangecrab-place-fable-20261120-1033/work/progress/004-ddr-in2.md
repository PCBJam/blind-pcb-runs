# 004 – DDR3 routed (F.Cu + In2, a few nets on B.Cu)

What
- F.Cu only (no vias): A4, A6, A8, A10, A14, BA1, A1, A11, D1, D3, D5, D7, D13.
- F.Cu stub -> via at the FPGA edge or in a depopulated ball site -> In2 -> via in the RAM channel:
  remaining address/control, CK pair, CKE, D0, D2, D4, D6, D9, D14, both strobe pairs.
- B.Cu instead of In2 where the pin orders of FPGA and RAM force a crossing: A3, RAS#, LDM, UDM,
  D8, D10, D11, D12, D15.
- CK+/CK- end at two channel vias next to K7/J7; the 2x51R + 100nF termination sits on the bottom
  directly at those vias.

Why it looks like this
- In2 lanes were laid out explicitly: two 0.1 mm lanes per 0.8 mm RAM row gap between 0.3 mm
  row-aligned vias. `bt route` was used for the single-layer F.Cu nets only.
- Attempts thrown away: (1) flash under the south-east corner of the FPGA: its exposed pad blocked
  every via site and all of B.Cu there -> flash moved to the south-west strip; (2) letting
  `bt route --nets` do the south-edge data nets on three layers: 7/10 connected, with 18-26 mm
  routes and 4 vias on D0, not acceptable for DDR -> done by hand with a layer plan derived from the
  pin orders (longest monotone subsequence on In2, the rest on B.Cu).

Result: all DDR nets connected except RAM_RESET# (slow, routed later). Lengths before tuning:
address/control 6.5-14.5 mm (CK 16.6/17.8), lower byte 7.0-14.4 mm, upper byte 11.5-17.2 mm.
