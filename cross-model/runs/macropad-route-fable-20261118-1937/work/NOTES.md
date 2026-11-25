# Routing notes – macropad-top

## State
The board is fully routed and filled. KiCad 10 DRC (all severities, with schematic parity) reports 0 errors, 0 unconnected items and 0 parity issues. The one warning, "U103 footprint does not match the library copy", was already there on the unrouted board. No footprint was moved, rotated, added or removed.

399 track segments, 128 vias, GND zones on F.Cu and B.Cu. The only project-file change is three new net classes; the board minimums and the JLCPCB .kicad_dru are untouched.

## Approach
The board has two very different halves, and I treated them differently.

**Key field (x > 120).** Every pad is on the back: hot-swap sockets, reverse-mount LEDs and their capacitors. The front has nothing but mechanical holes. So the front is left as an unbroken ground plane and all key, LED-data and LED-power routing stays on the back with the pads. The only front copper in the key field is a 10 mm stretch of +5V_LED and LED_DIN coming in at the lower-left corner.

**MCU corner.** Parts are on the front and the RP2040's decoupling capacitors are on the back, under the chip. Signals are routed on the front where possible; the back carries the 3V3 trunk, the 1V1 link and two slow control lines.

## Decisions and why

**Net classes.** Power (+5V, VBUS, +5V_LED): 0.5 mm tracks, 0.8/0.4 vias. Supply (+3V3, +1V1): 0.3 mm. USB: 0.2 mm with 0.2 mm gap. Everything else 0.2/0.2 with 0.6/0.3 vias. Tracks narrow to 0.2 mm only where they enter 0.2 mm QFN pads.

**RP2040 power.**
- The ten 3V3 pins are joined by a 0.25 mm ring track on the front, inside the pad frame. Five vias drop from the ring to the capacitor groups on the back, so each IOVDD pin has a capacitor within about 2 mm.
- The 3V3 trunk (0.5 mm, back) feeds the south capacitor pair directly; the other groups get their DC through the ring. I did this on purpose: linking the groups on the back would have closed a 3V3 ring around the exposed pad's ground vias and cut the chip's ground off from the plane.
- Five ground vias in the exposed pad land between the four centre capacitor ground pads. That island is tied outward at all four corners of the capacitor array.
- 1V1: pin 45 → C116 and pin 50 → C117 through a via right beside each pin, pin 23 → C115 directly; one 0.3 mm link on the back along the top of the chip joins the two sides.

**USB.** D+/D− go connector → USBLC6 (straight through under its body) → 27 Ω resistors → pins 46/47, all on the front, no vias, about 12 mm in total. Not impedance-controlled: 90 Ω is not achievable with sensible widths on a 1.6 mm two-layer stack, and at full speed over this length it does not matter. The two D+ pads are joined on the board side of the pad row, the two D− pads on the connector side.

**QSPI.** All six lines on the front with no vias. SS, SD1, SD2 enter the flash from the MCU side; SD0, SCLK, SD3 wrap round the far side of the flash, which is the only crossing-free order for this placement.

**Keys.** Six lanes leave the QFN's top row on the front and each drops through one via just east of the chip. The via positions do the reordering, so no key net needs a second via. KEY1–3 run along the top on the back; KEY4–6 go down a channel at x ≈ 119 and along the corridor between the rows.

**LEDs.** +5V_LED is a 0.5–0.6 mm trunk per row with each LED's 100 nF on the spur between trunk and LED. By my estimate (about 36 mA per LED at full white, 1 oz copper) the drop to the last LED is below about 20 mV. Data links run on the back round the capacitors.

**Ground.** Zones on both layers, 0.25 mm clearance, thermal reliefs (0.25 mm gap, 0.4 mm spokes) on all pads. Every ground pad also has its own via: each LED, each LED capacitor, two per socket ground pad, every decoupling and IC ground pad. 45 further stitching vias tie the two planes along the edges, between the sockets and beside the QSPI lanes.

**JLCPCB limits.** Checked against their capability page on 2026-11-18: smallest track and gap used 0.2 mm (limit 0.10), smallest via 0.5/0.3 mm (limit 0.25/0.15), copper to edge ≥ 0.2 mm, stitching vias ≥ 0.55 mm from the edge. Vias are tented both sides (board setting, as received).

## Known weak points
- **VBUS link under the USB pair.** The top VBUS pad pair reaches the fuse through a 5.5 mm back-side link at x = 95.75, which puts a 1 mm slot in the back ground directly under D+/D− next to the connector. Fine for full-speed USB; I would not accept it for high-speed.
- **D− bridge under the connector.** The track joining the two D− pads runs at x = 93.5, 0.35 mm past the pad ends on the connector-body side, so it sits under the rear of the USB-C shell with only solder mask between them. It was that or two extra vias in the pair.
- **QSPI length spread.** SD3 is 23 mm and SCLK 20 mm against 8 mm for SD1/SD2, and they cross two slots in the back ground (3V3 trunk, LED_EN/LED_DIN_3V3). Stitching vias sit beside both crossings. There are no series resistors in the schematic; I expect this to work at normal RP2040 flash clocks but it is the least tidy high-speed routing on the board.
- **Thermal reliefs everywhere.** Chosen for hand-soldering the sockets and connector. A designer who prefers solid SMD connections would change the zone setting; nothing else depends on it.
- **Exposed-pad vias are open 0.3 mm holes** in the QFN paste area, so some solder will wick into them. Normal for this package but it is not a plugged-via design.
- **Ground vias sit close to their pads** (the ones placed with `bt escape` are 0.05 mm from the pad edge). They are tented and on the same net, so the worst case is slight solder thieving.
- **One ground via does little:** C110's (104.94, 104.78) lands in an isolated pocket of front copper. C110's ground is carried by the back-side tracks instead.
- **Thin front pour strip** between the KEY1 lane and the top edge (x 108–116), about 0.4 mm wide. It is connected but adds nothing.
- Not done: teardrops, silkscreen tidy-up, fabrication outputs (gerbers, drill, BOM/CPL).

## Files
- `macropad-top.kicad_pcb` – routed board, zones filled.
- `macropad-top.kicad_pro` – three net classes added, nothing else changed.
- `progress/` – five numbered picture-and-note pairs.
- `BT-REVIEW.md` – review of the `bt` tool.
