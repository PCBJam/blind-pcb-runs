# Glasgow – routing notes

State: every net is connected, KiCad 10 DRC (`kicad-cli pcb drc --refill-zones --severity-all`) reports 0 unconnected items and only the
violations that the unrouted board already had (library/footprint mismatches, courtyard and silkscreen warnings, schematic-parity items).
No footprint was moved, rotated, added or removed (`bt same`). The board is routable-complete, but read "Not finished / not good" before ordering.

## Layer stack use
| Layer | Use |
|---|---|
| F.Cu | components, most signals, LVDS pairs to the lower J5 row, GND pour in the gaps |
| In1.Cu | solid GND plane (only 13 mm of foreign copper, see below) |
| In2.Cu | power: +3V3 base, islands for VIOA, VIOB and +5V; also ~250 mm of slow/static signal hops |
| B.Cu | decoupling, second signal layer, LVDS pairs to the upper J5 row, GND pour |

Why: the FX2↔FPGA bus, the LVDS port and all 16 I/O lines sit on F.Cu directly over an unbroken GND plane. Power is on In2 because every
power pin has its capacitor on the bottom side right under it, so a via from the pin drops through the island into the capacitor pad.

In2 islands: VIOA (top right, comb under the bank-A VCCB pins, tongue to J2 pin 2), VIOB (mirror, tongue to J3 pin 2), +5V strip along the
bottom edge and up the right side to both VIO regulators. +1V2 is not an island (it would have separated the FX2 from the 3V3 regulator);
it is a 0.4 mm B.Cu trunk from U36 to C14 and short links under the FPGA.

## Design rules I changed (glasgow.kicad_pro)
- Net-class clearance 0.15 → **0.125 mm**, minimum track 0.15 → **0.1 mm**. Reason: with 0.15/0.15 no track fits between two vias on the
  0.8 mm BGA grid, and the bottom-side capacitors leave only 0.4 mm slots. 0.1 mm is used only as necks (347 short segments: between BGA vias,
  between the caps under the FPGA, in the level-shifter row gaps); normal tracks are 0.15 mm, power 0.2–0.6 mm.
- `min_resolved_spokes` 2 → 1 (21 GND pads in the F.Cu pour get only one thermal spoke; all of them also have a track or via).
- Vias: 0.45/0.2 mm (290, the only size that fits between 0.8 mm balls, also used in the shifter block) and 0.6/0.3 mm (286).
  Check both, and 0.1 mm track / 0.125 mm gap, against your fab's standard 4-layer class before ordering.

## Routing approach, block by block
- **FPGA (BGA-121)**: fan-out by hand/script. Power and GND balls go to a via that lands in the pad of the bottom-side cap. North side = LVDS
  port, west = FX2 bus, east = bank A, south = bank B.
- **LVDS (13 pairs to J5)**: generated as a non-crossing 45° fan, 0.15 mm track / 0.15 mm gap. Pairs for the lower J5 row on F.Cu, pairs for the
  upper row on B.Cu, coming up through vias between the two pad rows. P/N order checked, no pair twisted.
- **USB**: D+/D- side by side on F.Cu over GND, through the TPD3S014 pads into the FX2; the duplicate USB-C pads are joined under the
  connector via the bottom test points.
- **FX2**: 3V3 pins have an in-line via to the cap under the pin, GND pins tie to the exposed pad. Control signals to the FPGA are a planar
  fan on F.Cu, D0–D7 split between F.Cu and B.Cu.
- **Level shifters**: one repeated cell (see progress/007). Data on F.Cu, direction lines on B.Cu, VCCA/VCCB vias directly above the pins.
- **I/O side**: 33R array → both pads of the ESD array → header pin on F.Cu; a B.Cu fan links the main header to the optional socket.
- **VIO regulators**: LDO out → sense resistors → rail kept short and 0.4–0.6 mm wide; the thin tracks there are only the Kelvin taps to the INA233.
- **Slow nets that go across the board** (ENVA, ENVB, ALERT, SDA, SCL): on B.Cu round the top and bottom board edges and up the right side.
- **GND**: a via to In1 at (almost) every GND pad, pours on both outer layers, 124 stitching vias.

## Not finished / not good – please read
1. **Signal copper on plane layers.** In2 carries hops for static or slow nets that could not be made planar on two layers:
   FPGA_DONE, FPGA_RESET, CLKIF (14 mm, under the FX2), CLKREF (2 hops), DA0/DB0/DB1 (direction lines), the two AUX lines (R39/R43, 17 mm each, through
   the corridor between the VIO islands), LED U5, CY_RESET (43 mm down the west edge), SCL (27 mm) and SDA (7 mm), ALERT (7 mm), +1V2/GNDPLL0 links.
   Each one is a 0.5 mm slot in the 3V3 plane. CLKIF (48 MHz) and CLKREF are the only fast ones.
   **In1 (GND) has 13 mm of +3V3 track**: 5 mm under the FPGA centre joining three VCCIO balls, and two links (2.8 mm and 4 mm) under the level shifters
   that tie the 3V3 "finger" to the rest. The 4 mm one runs under an F.Cu data lane (bank A, X7). I could not find another way; it is a real compromise.
2. **LVDS is not length-tuned and not impedance-checked.** In-pair skew is ≤0.7 mm on F.Cu and up to ~1.5 mm on B.Cu. No stack-up is defined in the
   project, so 0.15/0.15 is a guess for 100 Ω. The six B.Cu pairs are referenced to the 3V3 plane and cross the VIO_AUX slot at the BGA edge.
   One pair (Z4) leaves the BGA with its two legs on different layers for the first ~2 mm.
3. **Autorouted leftovers that work but are ugly**: the U32-direction net (68 mm, runs under the right shifter column), LED U2 (42 mm, 9 vias),
   LED U3/U4, parts of SDA/SCL on the right side, CY_RESET. All static or 400 kHz. I did not hand-clean them.
4. **3V3 feed into the shifter area is thin**: the 3V3 between the VIO islands is fed through 0.4–0.7 mm necks plus the In1 links above.
   Fine for the µA–mA these pins draw; each has its own capacitor and GND via.
5. **Vias in pads** (untented vias here would wick solder – tent/plug them): R32.2, R9.1, U14.5/R7.1, U31.5/R56.1, U14.2, U13.6, U12.1, U19.15,
   C8.2, and the cap pads under the FPGA and under every shifter.
6. **Decoupling compromises**: C14 (4u7 on +1V2) reaches GND through a 4 mm track; C19/C20 get 3V3 through a 0.1 mm neck.
7. **+5V to the VIO regulators** is the In2 strip, perforated by signal vias near U20/U13; I added a 0.4 mm track in parallel as backup.
8. Not done at all: teardrops, silkscreen clean-up, fabrication outputs, a second pair of eyes. The pre-existing DRC warnings were left as they were.
9. Zones are saved filled. If you edit anything, refill (B) before running DRC.
