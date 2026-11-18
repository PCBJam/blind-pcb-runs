# 004 – LVDS pairs FPGA → J5 (generated geometrically, not autorouted)
- First attempt with `bt pair` per pair: worked for 5 of 7 top-layer pairs, but each pair took the greedy shortest path,
  so one pair's horizontal run under J5 boxed in the pads of the next ("start is boxed in"). Thrown away.
- Second attempt (kept): a small script generates a non-crossing 45° fan. Pairs to the lower J5 row stay on F.Cu
  (reference: In1 GND), pairs to the upper row run on B.Cu and come up through 0.6/0.3 vias between the two pad rows.
  In-pair spacing 0.15 mm, pair-to-pair 0.45 mm gap. P/N order was checked at both ends: no pair is twisted.
- Ball D2 (Z4_P) leaves the BGA on F.Cu and drops to B.Cu just outside, next to its partner.
- VIO_AUX (balls E4/G4, cap C33) cannot leave the BGA on F or B without crossing the fans, so it uses a short
  0.3 mm In2 track (x=84.1, then y=89.4 east) to a via east of the fans. Known compromise: the B.Cu pairs cross this
  0.8 mm slot in the 3V3 plane right at the BGA edge.
- In-pair skew: ≤0.7 mm on F pairs, up to ~1.5 mm on B pairs (≈10 ps) – not length-tuned.
