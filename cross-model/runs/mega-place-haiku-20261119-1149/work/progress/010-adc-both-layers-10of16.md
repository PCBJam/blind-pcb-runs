# 010 — ADC bus, both layers, west-face lanes out of the way (scratch copy, not kept as is)

What was done (scratch copy `sb10`, started from the real board):
- Removed the routed west-face lanes (PE3, PE4, PE5, PG5, PH3–6, PB4–6) inside a box west of
  the escape vias (`bt unroute --box 118,78,164.6,116`). Their fan stubs and vias stayed.
- Routed ADC15 → ADC0 in ring order on both layers (`bt route --order given --passes 2`).

Result: 10 of 16 ADC nets connected. Still open: ADC1, ADC2, ADC3, ADC5, ADC11, ADC12.
Their failures: "gave up" in pass 2, and "could not be put back" where a neighbouring lane
had been shoved aside.

Earlier attempt in the same family (`sb8`): ADC on B.Cu only, 4 of 16. Why it failed: ADC1
leaves the N face on F.Cu (its fan exit), so a B.Cu-only route cannot leave the pad; the
other lanes then box each other in.

Picture: 010-adc-both-layers-10of16.png (the north face, the top corridor and the west edge).
Next step: retry the six open ADC nets with more passes (sb11).
