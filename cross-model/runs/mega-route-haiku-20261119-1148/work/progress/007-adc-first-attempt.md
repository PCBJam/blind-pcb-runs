# 007 ADC bus first, then the rest (partly successful)

**Why:** every ADC link crossed routed copper on every layer (bt congestion). The N-side ADC pins (x 144-151.5, y 95.65) sit under a band of 45-degree tracks (the west-top bundle to J6/J7 and TXD2/RXD2 to J8), and the router's per-group calls had boxed them in. A single ADC8 trial route existed only as a 62 mm detour round the west side of the chip.

**What I did:**
1. Unrouted the ADC nets, PB0-PB3 and the west-top bundle (13 nets) plus TXD2/RXD2 (154 items removed).
2. One bt route call with the ADC nets first (order given), then the west-top nets, TXD2/RXD2, PB, TXD3/RXD3 and the E leftovers, with 3 passes.
3. Pass 1 routed ADC15,14,13,12,11,10,7,6,2 and PH3, PE0, PE4, PE5, PG5, PB6, PB1. Failed: ADC9,8,5,4,3,1,0; the west-top PH4,PH5,PH6,PB4,PB5, PE1, PE3; TXD2, RXD2, TXD3, RXD3, PC1, PG0, PG1; PB0, PB2.
4. Pass 2 recovered ADC8 and ADC5 and PG5. I stopped the run after pass 2 (it was spending most of its time on failures) and applied what it had: 19 nets, 195 segments, 49 vias. Probe: all 244 items clear.

**Result:** 19 nets connected, but not the set I need. The ADC nets now take the north-west corridor and cut across the west-top bundle, so the bundle no longer fits. The two bundles cannot both pass the north-west corner at 0.2 mm tracks with 0.15 mm clearance.

**Next (see 008):** the failing nets are retried with the narrower default class.
