# Macropad top board – placement and routing notes

## Result in short

- Board is now a plain rectangle, **68.15 × 38.1 mm** (was an 89.15 mm wide L-shape). The key area is untouched; the outline was only redrawn left of it (new left edge at x = 108.0, 1 mm corner radii).
- All 48 movable parts are on **B.Cu**, including the USB-C connector. Locked switches and LEDs were not touched (checked by script: position, rotation, layer, lock flag, pads).
- Fully routed: 0 unconnected, 0 schematic-parity issues.
- `kicad-cli pcb drc --severity-all --schematic-parity`: **0 errors, 1 warning**. The warning is `lib_footprint_mismatch` on U103 (QFN-56 differs from the library copy). It is in the original board too; I did not change footprint definitions.
- Gerber and drill export run without complaint (test export only, not left in /work).
- Files changed: `macropad-top.kicad_pcb`, `macropad-top.kicad_pro` (one added net class, see below). `.kicad_dru` is unchanged.

## Placement

**Left strip (11 mm wide), top to bottom:**

- **USB-C (J101)** on the top edge, mouth flush with the edge, facing away from the user. I chose the back edge over the left edge because a cable leaving the back is right for a desk macropad, even though it makes the strip about 5 mm wider than the smallest arrangement I could find (connector on the left edge, wedged between two hot-swap sockets).
- Directly under the connector: CC resistors R101/R102, ESD array U102 in line with D+/D-, fuse F101, then the 27 Ω series resistors R103/R104 just before the MCU pins.
- **Flash (U104)** under the connector's east half, with C118 at its VCC pin.
- **RP2040 (U103)** below the flash, rotated so the USB/QSPI side faces up towards connector and flash, the crystal side faces down, and GPIO6/7 (LED data/enable) face the key area.
- **Crystal (Y101)**, R105 and the two 15 pF caps directly below the MCU.

**Under the keys (in the pockets between sockets and LEDs):**

- LDO U101 with C102 (in) and C104 (out) under D201; its output cap C104 is about 2 mm away and MCU pin 1 about 8 mm of track away.
- BOOTSEL switch SW101 between D201 and D301; level shifter U106 + C121 just below it.
- LED load switch U105 with C119/C120 under D301; bulk cap C101 next to it.
- One 100 nF per LED, next to its VDD pad.

**Decoupling around the RP2040:**

| Location | Parts | Serves |
|---|---|---|
| NW corner | C112 (1 µF), C116 (1 µF), C117 | pin 42 / VREG_VIN side, VREG_VOUT (1V1) |
| NE corner | C114, C105, C103, C104 (1 µF, also LDO output) | pin 1 |
| South | C115, C107 | DVDD pin 23, IOVDD pin 22 |
| South, on the same 3V3 spine | C108, C110, C106, C111 | bulk only (no room nearer the pins) |

## Routing

- **Layers:** B.Cu carries the parts and almost all routing. F.Cu is a ground plane with as few cuts as I could manage. GND pours on both layers, 93 vias in total (89 × 0.6/0.3 mm, 4 × 0.5/0.3 mm where space forced it).
- **3V3 at the MCU:** a C-shaped track inside the QFN pad ring (between pads and exposed pad) links all IOVDD/AVDD/VREG_VIN/USB_VDD pins on B.Cu, fed from the LDO at pin 1. This avoids slicing the F.Cu plane under the chip.
- **1V1:** pins 45, 50 and 23 are joined by a short F.Cu link under the chip (3 vias).
- **Exposed pad:** 4 ground vias; TESTEN tied to it.
- **USB:** D+/D- run straight down from the connector through the ESD part and series resistors, 0.2 mm wide, about 15–19 mm in total. The second pad pair (A7/B7) is joined with one short F.Cu hop on D-.
- **VBUS/+5V:**
  - The two VBUS pads are joined on F.Cu under the connector body, then go to the fuse.
  - +5V leaves the fuse on F.Cu, runs along the left and top board edges (0.5 mm) and drops in at C101/U105. I put it at the edge so it does not cut the plane.
  - From there a 0.4 mm B.Cu trunk runs under the U105 and U106 bodies to the LDO.
- **QSPI:** 5–13 mm per signal, wrapping the flash on both sides so no tracks cross. BOOTSEL hangs off the flash CS pin through the gap above D201 (about 11 mm stub to the switch, plus a 6 mm link between its two pads).
- **Keys:** the six key lines leave the west side of the MCU, wrap around its west and south sides on B.Cu (clear of the crystal), then each drops through a via and runs north–south on F.Cu to its socket pad.
- **LED power:** one 0.3 mm rail from U105 along row 1, down the right edge and back along row 2. LED data is chained on B.Cu.

## Rule changes

- Added a net class **Power** (0.4 mm track, 0.2 mm clearance, 0.6/0.3 via) for +5V, +5V_LED, +3V3, +1V1 and VBUS, so later edits default to sensible widths. No constraint was loosened.

## Known weak points and things not done

- **Decoupling is not one cap per pin.** IOVDD pins 10, 33 and 48/49 and DVDD pin 50 have no cap at the pin; they rely on the inner ring / 1V1 link, 2–4 mm from the nearest cap. Four 100 nF caps sit in the south cluster only because there was no room nearer.
- **USB is not impedance controlled** (not achievable at sensible widths on 1.6 mm 2-layer). The pair splits to 1.9 mm apart through the ESD part, D- is a few mm longer than D+, D- has two vias, and a short F.Cu +5V stub (ESD pin 5) crosses under D-. Fine for full-speed USB, not good practice for anything faster.
- **Flash 3V3** reaches C118/U104 through a 12 mm F.Cu hop that crosses under three QSPI tracks.
- **F.Cu plane in the key area** is split into vertical panels by the three long key tracks (near x = 122, 140, 159). The panels join along the top strip and through the B.Cu pour and stitching vias. The MCU, USB, flash and crystal all sit on one unbroken panel.
- **B.Cu pour is fragmented** into 19 islands; each has at least one via, several only one.
- **Crystal:** XIN is 8.3 mm, longer than I would like. The KEY1/KEY4 F.Cu tracks pass under the XIN load cap C109.
- **Tracks under component bodies:** the +5V trunk under U105 and U106 (between pad rows), LED power and data under the BOOTSEL switch, one 3V3 link between the pads of C115.
- **Long power paths:** +5V reaches the LDO over about 95 mm of track (estimated 0.1 Ω). The last LED (D501) is about 150 mm down the 0.3 mm rail (estimated 0.25 Ω). Both are calculated, not measured.
- **Fine geometry:** one 0.16 mm track into MCU pin 1, and four 0.5/0.3 mm vias. Both are within the project's JLCPCB rules, but tighter than the rest of the board.
- **Silkscreen not worked on.** Reference designators on B.Silkscreen are hidden, as delivered.
- **Not checked mechanically:** connector against a case or plate, soldering access next to the hot-swap sockets, component height (C101 is 5.4 mm tall on the back).
- **Not added** (not in the schematic): mounting holes, fiducials, SWD test points.
