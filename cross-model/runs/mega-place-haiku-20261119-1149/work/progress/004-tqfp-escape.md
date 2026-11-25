# 004 — TQFP dog-bone escape (written to the board)

Command: `bt fan U3 --dogbone --side N|E|S|W --via-size .6,.3 --width .2`, one side at a time,
each side seeing the copper of the sides before (`--with`), then `bt apply` of the four files.
Result: 174 segments and 66 vias, probed clear.

What it did:
- N side (ADC0–15, PA0–2, AREF, AVCC): stubs on F.Cu, vias ~1.5 mm north of the pads in two
  rows, B.Cu tracks from there heading north.
- E side (PA3–7, PC0–7, PG0–2, RXD3/TXD3): vias at x ~188 into the J5 gap; the gap is now
  narrow (about 2.5 mm) and will be the hardest bundle to route.
- S side (PB7, RESET, XTAL1/2, PL0–7, SCL/SDA, RXD1/TXD1, PD7): vias below the pads.
- W side (PG5, PE0–5, PH0–6, PB0–6): vias at x ~166 beside J12.

Open after this step:
- Power pins: VCC pins 10, 31, 61 and 80 have stubs but no via (no room); GND pins got vias.
- W side PE5: its way out on B.Cu runs into J12's +5V pad (0.02 mm). The router has to find
  another route for it.
