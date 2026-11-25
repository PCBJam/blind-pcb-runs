# 000 — placement as delivered (no copper)

Baseline before any routing. Board 89.15 x 38.1 mm, 2 copper layers, 54 parts, 65 nets, 0 tracks, 0 vias, 0 zones.

Pictures: 000-placement.png (whole board), 000b-rp2040-area.png (USB-C, LDO, RP2040, flash),
000c-key-area.png (six MX hot-swap keys, SK6812 LEDs and caps on B.Cu).

What the placement tells me:
- Key switch sockets are SMD pads on B.Cu only (pin 1 = GPIO, pin 2 = GND), so every key contact sits on the back.
- The six SK6812 LEDs and their decoupling caps are also on B.Cu, under the keys. The LED data chain snakes row 1 left to right, then row 2 right to left.
- RP2040 (QFN-56) on F.Cu: the six key GPIOs (pins 31-37) all come off the north edge; USB D+/D- and QSPI come off the west edge; the flash (U104) sits south of the chip with its pins on its north and south edges.
- Several RP2040 decoupling caps are on B.Cu inside the chip's footprint, so their pads alternate +3V3 and GND.
- USB-C (J101) has its D+/D- pads interleaved (B7 D-, A6 D+, A7 D-, B6 D+), so each net needs a bridge around the other.
- The outline has a notch at lower-left (x < 117, y > 127.3).
