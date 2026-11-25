# 002 – escapes under U3 (hand-generated, scripts/a_adc.py … d_decap.py)

- ADC0..15 (north side of U3) go inwards to two staggered rows of 0.6/0.3 vias under the body (0.58 mm pitch,
  so a 0.2 track passes between two vias with 0.18 gap) and leave as a 16-wide B.Cu bus (0.4 pitch) straight
  south under the chip. West→east order on the bus = A0..A15 = order of J10/J9, so no crossings later.
- UART2 (pins 12/13), SPI PB0-3 (19-22) drop on vias in a strip under the west edge of the body; UART3 (63/64)
  crosses the body on F.Cu to the same strip (it has to reach J8.1/J8.2 at the far west end of J8).
- First attempt at SCL/SDA/RXD1/TXD1 (pins 43-46) failed twice: once on clearance (jogs started at different
  heights and ran into each other) and then on topology – the four B.Cu lanes came out in the reverse order of
  J8.5-8, which cannot be untangled on two layers. Replaced by a "staircase": each F.Cu stub runs a bit further
  north and east than the last before its via, so the B.Cu lanes come out already in header order.
- +5V under the chip: pin 80 ↔ pin 10 and pin 31 ↔ pin 61 (0.4 mm), so each half has two feeds/caps. The two
  halves are not joined under the chip (UART3 runs between them).
- Decoupling caps wired straight to their pin pairs; resonator Y1 and R1 directly below the XTAL pins.
Known compromise: the ADC bus passes under Y1/XTAL pins (no other way out on 2 layers).
