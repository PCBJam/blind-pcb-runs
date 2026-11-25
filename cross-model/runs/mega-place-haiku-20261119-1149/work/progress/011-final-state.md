# 011 — final state of this session (not finished)

Picture: 011-final-state.png (the whole board; the grey-blue fill is the GND pour on B.Cu, the
red hatched block in the bottom-left is the +5V pour on F.Cu).

What is connected (copper: 962 tracks, 214 vias):
- All locked headers and parts (unchanged, `bt same` clean).
- The USB side: D+/D-, shield, CC, the 22 ohm array, the 16U2 and its crystal, its SPI/ICSP and
  RESET2 and the LEDs.
- The power regulator and the barrel input: VCC, +3.3V, USBVCC, XVCC, Net-(D4-A).
- The serial and I2C group to J8 (7 of 8), and 11 of 16 west-face nets to J6/J7/J12.
- 28 of the 29 J5 nets (PC3 open).
- CMP, GATE_CMD, AVCC, AREF.

What is not connected (27 signal nets, plus the pour pieces of GND and +5V):
- ADC0–ADC15 (16 nets): the ADC pins are on the north face of the TQFP, but J9/J10 are at the bottom.
- XTAL1, XTAL2 (2): the crystal pins on the south edge are boxed in by the PB0–PB2 lanes.
- RESET, PB7 (2): long nets from the south edge to J11/J6.
- PE0, PE1, PB5, PB6, PB3 (5): west-face pins blocked by SDA's diagonal and by the +5V pads.
- SCL (1), PC3 (1).
- GND: 7 pour pieces not joined; +5V: 6 pieces not joined (including TQFP VCC pins 10, 31, 61).

Checks at this point:
- bt check: CHECK FAILED (58 unconnected items, 29 nets in pieces).
- KiCad DRC (kicad-cli): 4 courtyard overlaps between locked footprints that were already in the file;
  50 dangling escape vias (for the open nets); 1 starved thermal (fixed by a solid GND connection on the
  through-hole pads); 92 silk-over-copper and 67 silk-overlap warnings (footprint graphics over their own pads,
  which I may not change); 51 library-footprint mismatch warnings.
- The file opens in KiCad's DRC and pcbnew.
