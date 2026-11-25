# 008 Final state of this session (NOT finished)

**What was done after 007:**
- RESET: one 82 mm link (through the top-middle, 5 vias) and the other link routed; RESET now fully connected. +3V3 (U6.5 to C15, J11.5, U7.6) routed.
- GND pour on B.Cu over the board outline (solid connections for through-hole pads; the earlier thermal-spoke error is gone). GND joins written from bt islands --fix, except the D6.1 join (17 mm across the top-right band; D6's anode is open too, so I left it out). Two MCU GND pins got vias from bt via --near (U3.32, U3.62).
- +5V zone on F.Cu over the free left-bottom area (box 99..124 x 110..124). It joins only part of the +5V net.
- Default track width now 0.15 mm, clearance 0.127 mm (for new routes). Existing routes keep their widths.

**Checks (bt check):** CHECK FAILED. KiCad DRC: 12 errors, all courtyard overlaps in the fixed placement; 101 warnings (silk, lib mismatch). Unconnected: 88 KiCad items. Open signal nets: ADC0, ADC1, ADC3, ADC4, ADC9, PB0, PB2, PB3, PB4, PB5, PH4, PH5, PH6, PE1, PE3, TXD2, RXD2, TXD3, RXD3, PC1, PG0, PG1, and D6's anode net (23 nets). GND in 8 pieces; +5V in 8 pieces.

**Picture:** the whole board. The north and west sides of U3 (MCU) and the east edge near J12 are where the open nets are. The bottom of the board and the right-hand headers are routed.

**Where it stands:** not ready to order. See NOTES.md.
