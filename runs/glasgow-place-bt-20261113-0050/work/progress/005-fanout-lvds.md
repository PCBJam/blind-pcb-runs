# 005 – BGA fan-out and LVDS pairs

- Scripted fan-out (`tools/fanout.py`): outer two ball rings leave on F.Cu, inner balls drop to 0.4/0.2 mm vias; GND balls tied together
  on F.Cu, six 0402 decouplers sit on the back directly between the power and ground vias; CLKREF's two balls (D5, L5) are linked on F.Cu inside the ball field.
- LVDS: the seven pairs that end on J5's lower pad row are routed on F.Cu, the six that end on the upper row go down under the BGA
  and run on B.Cu to a via between the two pad rows (`tools/lvds_b.py`). Pairs stay coupled (0.15/0.15) and fan only at the pads.
- Mistake on the way: I copied a stale scratch board over the real one twice and lost tracks; everything was scripted so `tools/rebuild1.sh` rebuilt it.
  First attempt with `bt pair` on an empty board used the BGA escape channels greedily (thrown away); `bt pair` with fan-out stubs present worked for 5 pairs,
  Z0/Z2 next to fiducial FID8 were done by hand.
Result: DRC shows no clearance errors; intra-pair skew <= 1.2 mm (worst Z4, one leg escapes on F.Cu).
