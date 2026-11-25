# 007 — final state of this session (overview)

**What is on the board**
- Placement complete: all unlocked parts inside the outline; locked parts untouched (`bt same`: nothing locked moved).
- Planes: GND (In1.Cu) and +3V3 (In2.Cu) zones over the whole board, refilled.
- Routed: USB connector to FX2 (pair and taps), CC/VBUS/shield; FPGA escape from `bt fan` (91 nets); 7 of 13 Z-port pairs; 12 of 24 FX2 nets; 48 of 105 bank nets in one pass; GND and +3V3 surface-mount pads to their planes (one via each).
- Not routed: 161 nets (2312 mm of ratsnest). The VIO rails (VIOA, VIOB), +1V2, VIO_AUX and +5V are not routed at all. See NOTES.md, "Open items".

**Checks run**
- `bt check`: CHECK FAILED only because of unconnected items (321 KiCad, 138 nets in pieces). No bt findings.
- KiCad DRC (kicad-cli on a copy): 0 shorts, 0 clearance, 0 hole-clearance errors; 4 footprint-type errors are from the supplied footprint definitions (U1, J1, U8, U36).
- A stale-fill problem appeared twice: new vias landed in zones whose saved fill was older. Each time `bt fill` fixed it (DRC went from 4 clearance and 4 hole-clearance errors to none). Rule for this board: run `bt fill` after every routing apply.

**Image**: the whole board (routes F red, B blue, planes as overlays; green dashed = still unrouted).
