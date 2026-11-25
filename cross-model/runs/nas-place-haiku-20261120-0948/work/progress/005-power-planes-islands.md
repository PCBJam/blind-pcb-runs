# 005 Power: +5V plane, +12V fixes, converter inputs, +12P

**What changed**
- **+5V on In2.Cu.** An L-shaped island over the top band (x 100-226, y 72-92) and down the right edge to y 111
  (the fan headers are through-hole, so their +5V pins land on it), plus a left block (x 84-104, y 72-135) for the
  CM4's six +5V pins (escaped to three vias). The 5 V buck's output, the AP2112 input and the 5 V capacitors each got a
  via into the island. The first attempt had two islands that only touched at a corner, which the fill left apart;
  the second had them overlap by 0.6 mm and GND vias cut the overlap; the third overlaps by 4 mm. Result: +5V is one
  piece.
- **+12P** (DC input): the 1 mm class route failed on clearance to an unconnected pad on IC1 (0.158 mm against 0.2).
  I relaxed the Power12 class clearance to 0.15 mm (still above the board minimum) and routed the four links.
- **+12V** (bottom-side zone, 112-226 x 73-98): the converter VIN pins were walled in by ground stubs and vias
  from the ground-pad escape, and by TSENSE_1, by the M1 +3.3 V link, and by decoupling caps. What worked:
  1. For U13 (M4): unrouted TSENSE_1 (rerouting it is still to do) so the cluster joined the zone.
  2. For U15 (+3.3VA buck): the switch node was walled in by the R44/R45 feedback network; I routed the switch node
     with two vias (4.7 mm detour) and a 0.25 mm +12V track from the VIN pin into the zone.
  3. For U10 (M1 buck): removed the ground stubs in a small box and re-escaped the ground pads with `--avoid`.
  4. For U2 (+1V2 buck): still boxed in by the ASM's bottom-side decoupling capacitors and port-3 lanes (see open items).
- **Ground:** the surface-mount ground pads got stub + via escapes (`bt escape --net GND`), 256 pads, 17 left
  (CM4 pins in the connector field, and a few passives; see open items).

**Mistakes made on the way (kept for the bt review)**
- `bt islands --fix -o FILE` writes an items file, not a board; I passed the board path as `-o` and overwrote the
  board with JSON. `bt undo` restored it (the board had 1822 tracks before the mistake). Use `-o /tmp/x.json` and
  `bt apply` for islands.
- `bt route --nets GND --all` ran for minutes with no output and was stopped; `--net GND --all` makes pad-to-pad
  tracks, not vias into the planes. `bt escape --net GND` on the pad list was the right tool.

**Picture:** 005-power-planes-islands.png is the inner layer In2.Cu near the CM4 left strip at the stage when the
+5V left island was first overlapping the main island (the fill shows the overlap strip cut by ground vias). The
final single-outline version is in 006.
