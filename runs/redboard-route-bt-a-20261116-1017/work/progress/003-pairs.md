# 003 – bottom-layer pairs, USB breakouts, skew tuning
- In1 = GND plane, In2 = 3.3V plane with a GND area (priority 1) under the top-left quadrant, so the B.Cu pairs have a ground reference 0.1 mm away.
- DSI CLK, CSI CLK and USB HS run on B.Cu between ring vias under U1 and vias at their targets; DSI CLK enters its via pair from the west so the polarity comes out right without a twist.
- USB-C breakouts: the A6/B6 (and A7/B7) pads are joined with small loops round the pad ends; test points on B.Cu get a short via stub. USB serial (full speed) stays on F.Cu.
- `bt tune` took out the intra-pair skew (bumps on the short leg). DSI D1 still has 1.5 mm skew: no more room for bumps beside the track.
