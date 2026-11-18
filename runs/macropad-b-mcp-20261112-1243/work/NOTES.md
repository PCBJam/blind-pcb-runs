# macropad-top — placement and routing notes

## Result

- Board is now a 61.15 x 38.1 mm rectangle (1 mm corner radius), about 2330 mm². The original outline was about 3075 mm².
- The left edge moved from the old extension to x = 115.0 mm, 1.95 mm left of the key area. The key area itself is untouched.
- All 42 previously unplaced parts are on B.Cu, including the USB-C connector. The 12 locked footprints (switches, LEDs) were not moved; a script check confirms position, rotation, side and pad nets are identical to the original.
- DRC (`kicad-cli pcb drc --severity-all --schematic-parity`): 0 errors, 0 unconnected, 0 parity issues. One warning remains: U103 "does not match copy in library". It was in the original file and I did not touch footprint definitions.
- Gerber and drill export run without errors. I did not upload to JLCPCB or run their DFM check.

## Something I broke and repaired: `macropad-top.kicad_pro`

Saving the board through the `pcbnew` Python module rewrote the project file with defaults before I noticed. I had no copy of the original.

- **Restored from values I had printed earlier:** the board design rules (min clearance 0.1, edge clearance 0.2, hole clearance 0.19, min via 0.4, etc.), DRC severities, the Default net class, and the four text variables (FAB, FAB_PROFILE, RELEASE_DATE, REV).
- **Not recoverable:** the rest of the file, which is the schematic-side settings (ERC settings, drawing defaults, sheet list and similar). The file was about 20 kB and is now about 10 kB. The schematic still opens and exports the same netlist, but if you have the original `.kicad_pro` in version control, diff it against this one.
- **Added on purpose:** a `Power` net class (0.4 mm) for +5V, +3V3, +5V_LED, +1V1 and the VBUS net. It is documentation only; widths were set by hand.

`macropad-top.kicad_dru`, the schematics and `.kicad_prl` are unchanged.

## Placement

The left extension is almost gone because everything fits in the gaps between hot-swap sockets and LEDs on the back. The 1.95 mm that remains is what the USB-C connector needs to sit at its datasheet edge position without its pads hitting D201.

| Area | Parts | Why there |
|---|---|---|
| Left edge, centred y = 116 | J101, R101/R102 (CC), F101 | Connector opening faces left, board edge on the footprint's "PCB Edge" line |
| Under D201 | U102 (ESD) | In line with the D+/D- path, right behind the connector |
| Bottom-left corner | C101 (10 µF bulk) | Next to the fuse output; only free spot big enough |
| Between columns 1 and 2 | U105 (LED switch), U106 (level shifter), C119–C121 | Close to the first LED (D201) |
| Between columns 2 and 3 | U103 (RP2040), crystal, R105, 12 decoupling caps | Largest free window; flash sits directly below |
| Below the MCU, row 2 | U104 (flash), C118, C114 | QSPI runs straight down the channel between two sockets |
| Right of the MCU | U101 (LDO), C102–C104, C110–C112 | 3V3 reaches the MCU over a 10 mm, 0.5 mm wide B.Cu trunk |
| Bottom, between columns 1 and 2 | SW101 (BOOTSEL) | Only gap that fits it |
| Next to each LED | C201–C701 | VDD pad of the cap within about 2 mm of the LED VDD pad |

## Routing

- **Layers:** B.Cu carries the parts and most routing. F.Cu is a GND plane with jumpers; both layers have a GND pour, tied by 129 vias in total (about 38 are pure stitching).
- **USB:** D+/D- run as a 0.2/0.2 mm pair, connector → U102 (flow-through) → 27 Ω resistors → MCU. Total per line is about 44 mm, mismatch under 1 mm. The last 15 mm to the MCU pins is on F.Cu because the QSPI bundle is in the way on B.Cu.
- **Crystal:** XIN is 9 mm and runs under the crystal body between its pads; XOUT goes straight into R105. Load caps sit in the socket channel above. No other signal crosses the crystal on B.Cu; the KEY2 jumper passes on F.Cu just south of it, under R105 and the 1V1 caps.
- **QSPI:** six 0.15 mm traces, about 13–17 mm, with F.Cu ground underneath. The 0.15 mm width is needed to fit six traces between two socket pads.
- **Power widths:** VBUS and +5V 0.4–0.5 mm, +5V_LED 0.4–0.5 mm, 3V3 trunk 0.5 mm.
- **Keys:** static signals, routed on F.Cu from vias beside the MCU. KEY1 is 78 mm because it goes round the south and west side.
- **Vias:** 0.6/0.3 mm everywhere except three 0.5/0.3 mm vias in tight spots (pins 48/49 of the MCU, U102 GND, D401 GND).

## Known weaknesses

- **MCU decoupling is not one cap per pin at the pin.** There is no room for that with 0603 parts on one side.
  - Pins 1, 10, 23, 26, 42–45, 48/49 have a cap within about 1–2 mm.
  - Pins 22, 33 and 50 reach their cap through a ring via and a short F.Cu trace.
  - C114 ended up beside the flash, not at the MCU.
- **3V3 to the west side of the MCU and to the flash goes through F.Cu links** 0.25–0.3 mm wide. Currents are small, but it is a chain, not a plane.
- **+5V takes a long way to the LDO:** fuse → F.Cu jumper (about 25 mm) → top edge → right edge, roughly 100 mm at 0.4 mm. I estimate about 0.1 Ω, which is fine for the MCU load but not elegant. C102 is at the LDO input.
- **+5V_LED reaches D701 through a 20 mm F.Cu jumper** from D401, and D501/D601 through a jumper under the USB pair.
- **LED data D301 → D401 is 68 mm long.** It goes round the top edge on B.Cu because the direct path is blocked by the MCU.
- **F.Cu ground is cut by these jumpers and the key traces**, mostly south and east of the MCU. The plane is continuous under USB, QSPI and the crystal.
- **USB pair impedance is not controlled** (0.2/0.2 mm on 1.6 mm 2-layer is well above 90 Ω). Acceptable for full-speed at this length.
- **BOOTSEL hangs on a 25 mm tail** of QSPI_SS past the flash, with no series resistor in the schematic.
- **Several clearances sit at exactly 0.20 mm** around the MCU fan-out. They pass DRC but have no margin.
- **Ground vias sit under the SOT-23 bodies** of U101 and U102, and close to a few 0603 pads.
- **Silkscreen was not tidied.** Reference texts are where the footprints put them after flipping.
- **C101 is 5.4 mm tall** on the back, taller than the USB connector. Check it against the case.
- **Schematic observation, not changed:** about 12 µF sits directly on VBUS (C101 + C102 + C119), above the 10 µF USB inrush limit.
