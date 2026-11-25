# 001 start-unrouted

**What:** Board as received: all 66 footprints placed, no copper, 152 nets (ratsnest only).

**Measured before routing (bt congestion / bt board):**
- 738 link crossings between 715 net pairs; 48 hot spots (2 mm cells).
- 38 IC pins with one way out or none (RN2/RN3/RN4 resistor arrays, U4 ATmega16U2 pins 2,4,10,11,13,15,18-21, and others).
- MCU U3 (ATmega2560, TQFP-100, 0.5 mm pitch) has its ring of pins going to headers on every side: W pins to the top headers J6/J7 and J8, S pins and E pins to the right-hand header J5, N pins (ADC0-15) to the bottom headers J9/J10. Some of these routes have to cross the MCU's own ring.

**Decisions taken this step (bt rules, written to the .kicad_pro):**
- Default class clearance 0.1 -> 0.15 mm. Power class clearance 0.1 -> 0.15 mm.
  Reason: JLCPCB 1-2 layer minimum track/spacing is 0.10 mm (1 oz) and they recommend 0.15 mm between SMD pads of different nets. 0.15 gives margin without making the MCU fan-out impossible (0.5 mm pitch leaves 0.3 mm between parallel stubs).
- Board minimums: track 0.1, clearance 0.1, via 0.5 OD / 0.3 drill, annular 0.1. Copper-to-edge stays at the project's 0.5 mm; hole clearance 0.15 and hole-to-hole 0.25 left as they were.
- Default track 0.2 mm and via 0.6/0.3 mm kept (JLCPCB's standard via). Power class (+5V, VCC, Net-(D4-A)) track 1.0 mm kept.

**Result:** rules set. Nothing routed yet.

Source for the JLCPCB numbers: https://jlcpcb.com/capabilities/pcb-capabilities (1-2 layer min track/spacing 0.10/0.10 mm at 1 oz; SMD pad-to-pad 0.15 mm; via hole min 0.3 mm; via OD min 0.5 mm; PTH annular ring 0.20 mm recommended 0.25 mm, absolute 0.18 mm). Note that the 0.6/0.3 via has a 0.15 mm ring, which is below JLCPCB's stated PTH ring figure; I keep it as their long-standing standard 2-layer via, and note it in NOTES.md.
