# 006 West side to top headers J6/J7 routed

**What:** PE0, PE1, PE3, PE4, PE5, PG5 (W and S pins of U3 to J7 and RN4), PH3, PH4, PH5, PH6, PB4, PB5, PB6 (W side to J6 and J7). One bt route --nets call in background (256 s).
- 12 of 13 connected. PE3 (U3.5 to J7.3) gave up: boxed in by the W-side stubs. PE1 failed in pass 1 (walled by U6's GND and +5V pads on the link to RN4.1) and connected in pass 2. PE0 was moved by the shove.
- Applied: 106 segments, 32 vias (cumulative: about 150 vias now). Probe of items: all 138 clear. bt drc --all: no clearance or short errors.

**Picture:** the W-side bundle leaves the chip's west edge and climbs the NW corner in two diagonal bands (F.Cu and B.Cu), then runs along the top to J6 and J7. The J6 group is planar (one layer); J7 needed two nets off-layer, which the router did.

**Open:** the top-middle gap between J6 and J7 is now a wall of tracks, so the ADC route must find a way through it or round it.
