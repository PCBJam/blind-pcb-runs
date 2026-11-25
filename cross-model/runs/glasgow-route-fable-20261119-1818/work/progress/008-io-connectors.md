# 008 – connector side of both I/O banks

- `bt route` on the eight bank A "Z" nets (resistor array -> ESD array -> J2/J8/pull array): 1 of 8 after 104 s,
  the rest "boxed in" at the 0.5 mm pitch ESD array pads. Thrown away.
- Scripted instead. Bank A: on F.Cu each line runs RN9/10 -> bottom pad of D22/23 -> through to the top pad -> J2 pin,
  so the ESD device sits in line between connector and series resistor; the J2 -> J8 socket branch is a nested fan on
  B.Cu; J8 -> RN11/12 on F.Cu. Z0 needs one 2.5 mm B.Cu hop (a via between the two pad rows of D22) because DA1's
  DIR line comes down the side of U11 there. 142 items, 4 probe errors (Z4/Z5 jog), then clean.
- Bank B is not a mirror (D21/D20 have their channels on the other end), so the RN4 group is nested on F.Cu and the
  RN3 group hops on B.Cu to vias between / below the D20 pad rows; same in-line ESD order. Probed clean first time.
  DB1's detour had to move again: it now goes round the south of J3 and up the east side (about 95 mm, static line).
- After that `bt route` finished the open links: 8/8 J3 -> J6/RN5/RN6, then 19 of 20 for the PCA6408 "P" nets, the
  AUX header nets and the resets, 109 segments, 3 vias.
