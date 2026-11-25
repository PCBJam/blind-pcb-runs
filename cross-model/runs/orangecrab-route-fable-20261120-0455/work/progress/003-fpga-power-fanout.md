# 003 – FPGA (U3) power / ground fan-out

Script-generated, table-driven where it matters:
- every power ball (1.1 V core, 3.3 V, 2.5 V, 1.35 V, VREF) has a dog-bone to a 0.28/0.15 via on an interstitial site; a site is used only if the back-side 0201 pad under it is the same net (so many vias land in their own decoupling cap pad) or free;
- ground balls are strapped ball-to-ball on F.Cu into a mesh with a via roughly every millimetre (52 GND vias) — straps are only drawn where no foreign via sits next to them;
- sites that the signal escape needs (F.Cu lanes between the outer balls, inner-layer "lines" for row 3/4 signals) were reserved first, and 13 signal vias for inner-row DDR/IO balls were pre-placed so the router cannot wall them in.

First attempts failed the probe (85 errors: straps passing 0.035 mm from power vias; then K/L column conflicts near the EXT_PLL test points) and were reworked; final: all clear.
Known leftovers at this stage: a few cap pads (C1.2, C4.2, C25, C26, C52, C53.1, C61.2, C66.2) still need their own via/track.
