# 003 – Ethernet pairs routed through the ESD arrays (CM4 to RJ45)

Picture: `003-eth-routed.png` (x 82–112, y 70–116).

**What I did**

- Each ETH pair has three links: CM4 pad to the ESD pad on the CM4 side, the ESD pad on the RJ45 side to the RJ45 pin, and the bridge between the two ESD pads of the same line. The ESD (D3V3F4U10LP-7) is a shunt array, so the line pads 5 and 6 (and 4 and 7, etc.) are bridged by copper and no series path goes through the device.
- Escape first: `bt escape` put one via for each CM4 pin (eight vias) in the gap between the module's two pin columns (x≈90.3, 92.2) or on the outside (x≈88.1, 93.4), staggered in y so the vias keep clear.
- Links were routed with `bt route` from those vias to the ESD pads and from the ESD to the RJ45 pins.
- The three ESD bridges (P3+, P1-, P2-) that the router would not place on its grid were drawn by hand as 0.2 mm F.Cu segments between the two pads (x 94.0, 98.2, 92.5) and probed clear.

**Result**

- All eight ETH nets are connected. Pair lengths: P0 44/47 mm, P1 40/50 mm, P2 43/46 mm, P3 44/48 mm. Length matching is not done (P1 is 10 mm apart).
- Several legs run at 0.127 mm near the RJ45 and ESD pins, where the pitch leaves no room for 0.35 mm (P1-, P3-, P0-: 4–6 mm each).

**Known weak points**

- The two members of a pair are not kept side by side: they take different layers (F.Cu and B.Cu) and different corridors through the connector area. Coupling is poor for common-mode noise.
- The bridge tracks are hand-drawn; the router rounds its own paths to a 0.05 mm grid and failed to place them.
- Length tuning (`bt tune`) is still to do.
