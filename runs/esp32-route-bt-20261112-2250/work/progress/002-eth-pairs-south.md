# 002 – Ethernet pairs, centre-tap rail, USB (hand-planned)

Hand-computed coordinates, checked with `bt probe`, written with `bt apply`.

- TD/RD: 0.127 mm tracks, 0.133 mm gap (class Zdiff=100R over 0.127 mm prepreg). Leave the PHY on B, pass *between*
  the 49.9R terminators (each line tees into its resistor), run SW side by side to the neck between the USB shell and
  the DC/DC pins, then down the left corridor. RD stays on B all the way (no layer change; TVS1 hangs on two via
  stubs); TD changes once to F at y≈159 so it reaches TVS1's east pads. Order at TVS1/TVS3 is kept planar
  (RD makes a small U around TVS3 so RD+ lands on jack pin 3 and RD- continues to pin 6).
- RCT (analog 3V3 for the magnetics centre taps) runs on B between the two pairs, 0.4 mm, and hops to F only at the
  jack. C11 gets a via next to its pad; the LNK LED anode is a thin F spur.
- USB (full speed) + VBUS: on F, south of the DC/DC output pins, up through the gaps between pins, around the south
  and east of the CH340 and in between its pad rows – chosen so nothing has to cross the pair on its own layer.
- First attempt failed `bt probe` only on float rounding (gap 0.127 vs 0.127 limit) → pitch widened by 6 µm.
- Zone outlines were adjusted twice so the pairs and USB always have plane under them.
