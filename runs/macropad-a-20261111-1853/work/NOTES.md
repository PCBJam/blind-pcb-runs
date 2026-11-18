# macropad-top – placement and routing notes

## Status

- All 30 unplaced footprints are placed, every net is routed, and both layers have a GND pour.
- `kicad-cli pcb drc --schematic-parity --severity-all` (also with `--refill-zones`): **0 unconnected, 0 parity issues, 1 remaining message**.
  The remaining message is `lib_footprint_mismatch` for U103 (the board copy of the QFN-56 differs from the library copy). It was there before I started and I did not touch footprint definitions.
- Locked parts (switches, LEDs, J101) are untouched. No footprints were added or removed. The board outline is unchanged.
- Checked only by DRC and by looking at rendered images. Nothing was simulated, and no Gerbers / BOM / CPL were generated.

## Floorplan

The key grid fills the right-hand part of the board, so all electronics sit in the 30 × 27 mm block on the left, next to the USB connector.

| Area | Contents |
|---|---|
| Right of J101 | USB fan-out, U102 (ESD), R103/R104, then U103 (RP2040) |
| Above the USB lines | R102 (CC1), C112 + C114 at the MCU's top-left corner |
| Strip between MCU and key 1 | Y101, C109, C113, R105, C115 |
| Below the USB lines | U104 (flash) with C118, SW101 (BOOTSEL) under it, R101 (CC2) |
| Below J101 | F101, C101 (bulk) |
| Below the MCU | U101 (LDO) with C102/C103/C104, U105 (LED load switch), U106 (level shifter), C110, C119, C120 |
| Back, under the MCU | C105, C106, C107, C108, C111 (3V3), C116, C117 (1V1) |
| Back, by U106 | C121 |
| Back, beside each LED | C201 … C701 |

Everything else is on the top side. C101 (5.4 mm tall) is in the corner furthest from the keys.

## Decisions and reasons

**RP2040 orientation (90°).** USB pins face the connector, QSPI pins face the flash, the LED GPIOs face the LED driver below, and the key GPIOs exit upward into a free band along the top edge.

**USB.**
- The duplicate D+/D− pads of the Type-C connector are fanned out to 0.9 mm pitch and bridged with two 1.8 mm links on the back.
- The pair then runs straight through U102 (in on pins 1/3, out on 6/4, under the body) to the 27 Ω resistors, which sit about 1 mm from the MCU pins.
- No impedance control or length matching: this is full-speed USB over about 14 mm.
- The two VBUS pads are joined by a 0.5 mm link on the back; CC resistors are right at the connector.

**3V3.**
- The LDO output goes 4 mm straight up into IOVDD pin 1, past C104 and C103.
- From there a 0.3 mm C-shaped track runs on the top layer under the QFN, between the pad row and the exposed pad, and picks up every 3V3 pin from the inside.
- The C is open at the lower right so TESTEN (pin 19) can reach the exposed pad.
- Five vias on this track feed 100 nF caps directly underneath on the back. The other 3V3 caps are on top: C112 (1 µF, VREG_VIN) and C114 at pin 42, C110 at pin 10.

**1V1.**
- Pins 45, 50 and 23 escape outward to vias and are joined by a 0.3 mm track on the back, which crosses under the MCU.
- C116 (1 µF) is at the regulator output pin, C117 at pin 50, C115 on top at pin 23.

**Crystal.** XIN is about 3 mm long. R105 sits at XOUT, and the track from R105 to the crystal goes around the outside. Load caps are at the crystal pads with ground vias beside them.

**Flash.** Rotated so the six QSPI lines reach it without crossing: three go into the top pad row, three wrap around the right side into the bottom row. BOOTSEL hangs off the end of the CS line.

**Power path.**
- VBUS → F101 → C101 below the connector.
- +5V then runs 0.5 mm wide on the top layer along the bottom edge to the LDO and to U105. It stays on top there so the back plane is not cut.

**LED supply and data.**
- U105's output and U106's output drop to the back through vias, because all LED pads are on the back.
- +5V_LED is a 0.5 mm rail under each LED row, with a 100 nF cap and a ground via at every LED.
- Data follows the schematic chain order (row 1 left to right, down the right edge, row 2 right to left).

**Keys.** All six lines run on the top layer, which is otherwise empty under the switches, and drop through one via each to the hot-swap pad. KEY1–3 use the band above the switch holes; KEY4–6 go down between the MCU block and key 1, then along the gap between the rows.

**Ground.**
- The back is the reference plane, and I kept back-side tracks few and short.
- The top is also poured, with 83 stitching vias plus a via at every top-side ground pad that the pour could not reach.
- The area under the USB shell is kept free of stitching vias.

**Rules.**
- Tracks are 0.2 mm with 0.2 mm clearance; power is 0.3–0.6 mm; vias are 0.6/0.3 mm. This is inside JLCPCB's standard 2-layer limits and the project's `.kicad_dru`.
- I added a "Power" net class (0.4 mm default width) to `macropad-top.kicad_pro` for +5V, +5V_LED, +3V3, +1V1 and VBUS. It only sets the default width for later edits.

## Known weaknesses

- **Cuts in the back plane.** Besides the LED rails and short stubs, there are four:
  - the 1V1 link under the MCU (about 9 mm);
  - a 3V3 hop to the flash (10 mm, under the flash body), needed because the QSPI lines enclose the flash VCC pin on top;
  - a +5V hop to U102 pin 5 (about 13 mm, L-shaped), needed because that pin is enclosed by the D+/D− tracks;
  - the VBUS link at the connector (5 mm).
- **+5V_LED rails split the back pour** along each LED row. The top pour and stitching vias bridge them.
- **Long +5V feed to the LED switch.** About 45 mm from the fuse to U105, with the 10 µF bulk cap at the fuse end; only C119 (1 µF) is local. The DC drop is around 10 mV at full LED current.
- **KEY6 runs beside the crystal's R105-to-Y101 track** for 5 mm at 0.25 mm spacing. Key lines are static, so I accepted it.
- **The four ground vias in the MCU exposed pad sit inside the paste apertures** and will take some solder. Ask for plugged vias or accept it.
- **Back-side assembly is required** for 14 capacitors (the LEDs and sockets are on the back already).
- **Fab-layer value texts overlap** in the dense area. Reference designators were hidden on silkscreen in the original file and I left them hidden, so there is effectively no silkscreen labelling.
- **No SWD access.** SWCLK/SWDIO are unconnected in the schematic and I could not add pads.
- **Thermal reliefs on every ground pad**, including the hot-swap sockets and the USB shell. Good for soldering, slightly weaker mechanically for the shell.
