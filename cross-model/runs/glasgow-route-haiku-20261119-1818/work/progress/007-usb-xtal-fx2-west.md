# 007 — FX2 west side, USB pair and crystal (kept)

`bt escape U1 --side W --keep "/USB_P,/USB_N"`: all 12 west pins escape, GND and +3V3 pins share the
plane vias already present, and the USB pins keep their lanes. The earlier GND vias that blocked the
corridor were reused, not moved.
USB: D+ J1.B6 -> U15.6 (6.8 mm, F) -> U1.8 (2.7 mm, F), no vias. D- joins A7/B7 through two vias
(the connector pads are interleaved); D- runs 5.9 mm to U15.5 and 2.9 mm to U1.9 on F.
U15's USB pins face away from J1, so the two nets cannot both reach the switch on one layer without a
crossing; the chosen answer costs D- two vias in the connector join. Skew about 0.7 mm.
Crystal: XTALOUT U1.4 -> Y1.3 -> C11 (2.8 + 1.6 mm), XTALIN U1.5 -> Y1.1 -> C12 (4.6 + 1.6 mm), F.Cu,
0.15 mm. Ground-guard vias still to add.
