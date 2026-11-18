# 002 – PCIe routed (hand-generated differential pairs)
Rules first: net classes (HS_DIFF 0.2/0.15, ETH, Power), default clearance 0.15, stackup changed to 0.21 prepreg / 1.065 core / 0.21 prepreg.
All 15 PCIe pairs done with my own offset-polyline generator (bt pair was fine on one layer, but gave 8 mm skew when it needed vias).
Topology: upstream CLK/TX on F.Cu direct; upstream RX on B (unavoidable crossing). Each M.2 port: REFCLK drops to B at the switch pins (in-line staggered vias),
RX/TX stay on F across it and drop later; three-pair trunk on B passes east of the mounting holes, ends in vias between the M.2 pad rows.
RX/TX need a polarity twist (pin order at ASM1184 vs. M.2) – done with staggered in-line vias at the connector.
Result: bt probe all clear, 52 vias, intra-pair skew ≤ 1.3 mm.
