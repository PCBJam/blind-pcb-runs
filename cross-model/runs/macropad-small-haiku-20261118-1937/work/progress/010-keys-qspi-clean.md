# 010 six keys routed, QSPI untangled, DRC clean

- Six key nets routed from their escape vias (`bt route --order escapes-first`, all connected).
- QSPI: moved BOOTSEL to (95.0, 116.0) beside the flash; routed the east-side nets (SD0, SD3, SCLK) directly on B.Cu; routed SD1 and SS on F.Cu/B.Cu; SD2 needed its own escape via inside the RP2040 body.
- DRC: 0 errors, 3 warnings (one dangling via, the RP2040 footprint-library mismatch which I leave alone, a silk clip). 108 links still unconnected: GND (pour not yet made), +3V3 (22), +5V_LED (15), +1V1 (5), CC1/CC2, LED data-in and the five LED-chain links.
