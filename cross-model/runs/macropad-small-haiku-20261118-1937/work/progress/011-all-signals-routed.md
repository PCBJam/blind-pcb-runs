# 011 all signal nets routed (before the GND vias)

What is on the board now:
- Six key nets routed in one call from their escape vias, with F.Cu preferred for the lanes that pass the RP2080's east pins. DRC clean of key crossings.
- +1V1 and +3V3 finished, with escape vias for the bottom pins 45 and 50 and for top pin 22.
- CC1/CC2, LED data-in (34 mm, 2 vias), the five LED-chain links, and the 15 +5V_LED links (all on B.Cu, 0.5 mm, no vias).
- QSPI: east-side nets on B.Cu, west-side nets through vias; BOOTSEL moved to (95, 116).
- GND: F.Cu pour over the outline added (`bt zone`, clearance 0.2). The GND pads still need vias into it; that is the next step.

DRC before the GND vias: 0 errors, 5 warnings (3 dangling escape vias to tidy, RP2040 footprint library mismatch that I leave alone, a silk clip). Unconnected: GND only.
