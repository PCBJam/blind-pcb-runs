# 008 — LVDS pairs, first routing (partial)

`bt pair --nets <13 pairs> --order given` (and reversed), In2 allowed in the north window.
Result: 9 of 13 pairs route; Z2, Z6, Z7, Z8, Z11, Z12 are the ones with trouble.
The picture shows the pairs leaving the BGA's north side and turning towards J5 on F, B and In2. Skews
are 0.2 to 7 mm. The J5 upper-row pins can only be reached from the north or through the channel between
the rows, so those pairs detour round the header; the lower-row pins are reached from the south.
Why it is hard: the north exits are packed at 0.4 mm, and each pair routed first walls in the next one.
