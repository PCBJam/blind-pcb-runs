# Layout review: macropad-top, boards A, B, C

**Ranking: B, then A, then C.** None of the three should be ordered exactly as it is. B has no blocking defect, A has one (quick to fix), C has several, one of them mechanical.

| Board | EMI | SI | Power | Placement | Routing / DFM | Overall |
|---|---|---|---|---|---|---|
| **B** | 6 | 6 | 7 | 7 | 6 | **6** |
| **A** | 4 | 6 | 5 | 7 | 7 | **5** |
| **C** | 3 | 4 | 4 | 3 | 5 | **3** |

## How I checked

- KiCad 10.0.8 DRC on scratch copies (zones refilled, courtyard checks on), plus `bt` connectivity and island checks.
- `pcbnew` scripts for: track width per net, via sizes, ground fill under every sensitive track, pour islands and what joins them, decoupling distances, copper-to-edge distances, vias in pads, and connector position against the outline.
- Renders of each layer to confirm what the numbers said.
- All coordinates are KiCad mm, y down. Nothing in `/work/boards` was changed.
- No field solver was used; impedance comments are from geometry only.
- No board folder contained a NOTES.md, so I could not compare the designers' stated intent with the result.

## Common to all three

- DRC: 0 errors, 0 unconnected, fills up to date. All three show the same `lib_footprint_mismatch` warning on U103.
- Locked switches and LEDs are unmoved, no footprints were added, removed or edited, and every placed part is on B.Cu.
- Silkscreen: 48 of 54 reference designators are hidden on every board (only the switches show). That is poor for assembly and debug but does not separate the boards.
- USB is routed as plain 0.2 mm tracks, not a 90 Ω pair. On 1.6 mm 2-layer at full speed over these lengths that is acceptable, so I judged symmetry, reference and stubs instead.
- BOOTSEL (SW101) hangs directly on `/QSPI_SS` with no series resistor in the schematic, so the length of that branch matters.

| Measure | A | B | C |
|---|---|---|---|
| Outline bounding box (mm) | 79.15 × 38.1 | 67.15 × 38.1 | 86.6 × 40.75 |
| Outline area (mm²) | 2953 | 2558 | 3232 |
| GND pour | F.Cu and B.Cu | F.Cu and B.Cu | F.Cu only |
| F.Cu / B.Cu ground coverage | 82 % / 69 % | 80 % / 60 % | 79 % / 0 % |
| GND vias / all vias | 50 / 94 | 94 / 118 | 39 / 92 |
| Vias under RP2040 ground pad | 1 (beside the pad) | 5 | 3 |
| `/USB_D+` / `/USB_D-` connector side (mm) | 9.35 / 9.29 | 23.5 / 25.7 | 10.3 / 13.5 |
| XIN track (mm) | 8.5 | 13.6 | 6.9 |
| QSPI data and clock (mm) | 11–15 | 5–24 | 3.4–13.2 |
| `/QSPI_SS` including BOOTSEL branch (mm) | 19.4 | 60.8 | 19.8 |
| Narrowest track (mm) | 0.20 | 0.15 | 0.13 |
| Closest non-GND copper to board edge (mm) | 1.50 | 0.35 | 1.68 |

---

## Board B (first)

Smallest board, with the soundest ground structure. Its faults come from squeezing into a 10 mm wing: long branches and copper on the perimeter.

### EMI: 6
- **Ground is the best of the three.** F.Cu has no large voids apart from the switch holes. The RP2040 ground pad has 5 vias (119.1–120.9, 116.0–117.8) straight into the main F.Cu plane. There are 94 GND vias, including stitching rows at y = 102, 110, 118 and 130.
- **`/QSPI_SS` is 60.8 mm long** because BOOTSEL sits at (139, 113.6) in the key area. 47 mm of it is on F.Cu, and 25.6 mm runs 0.9 mm from the top edge (y = 101, x = 116–141).
- **Other copper on the perimeter:**
  - `/QSPI_SD3`, `/QSPI_SCLK`, `/QSPI_SD0` wrap round the outside of the flash, 1.15–1.95 mm from the left edge (x = 110.25–111.05, about 12 mm).
  - `+5V` runs along the bottom edge for about 30 mm at 0.65–0.75 mm from it, and 0.35 mm from it for 3.5 mm (138.05–141.55, 137.55).
  - `/Key3/DOUT` (LED data) runs 0.85 mm from the right edge for 20 mm (x = 175.2).
  - None of these has ground between it and the edge.
- **A long slot in F.Cu.** `/LED_EN` (62.8 mm on F.Cu) runs north–south at x = 139.5 from y = 102 to 133, with `/KEY2` parallel at x = 137.4. The `+5V_LED` trunk (y = 116.8), `/Key1/DOUT`, `/KEY3`, `/KEY5` and `/KEY6` cross it on B.Cu. Stitching vias at (139, 110/118/122/130) limit the damage.
- The B.Cu pour is cut into two main bodies and 14 islands by the `+5V_LED` ring. All are tied down by vias.
- The USB tracks cross two F.Cu power tracks: `+3V3` at (118.45, 127) and `+5V` at (118.45, 129.3).

### Signal integrity: 6
- **USB:** total length is balanced (30.9 mm D+ against 31.1 mm D− including the MCU side), but the routing is not symmetric. D− changes layer twice (vias at 117.75,132.35 and 119.3,130.3); D+ does not. The pair runs 0.65 mm apart for 4 mm and then splits to opposite sides of U102. The 27 Ω resistors are 5.5–6.8 mm from the MCU pins and the ESD part is about 7 mm from the connector. Fine for full speed, not tidy.
- **QSPI:** all on B.Cu, no vias, 93–98 % over solid F.Cu. That is the cleanest reference of the three. Lengths are 5.3 mm (SD1) to 24.4 mm (SD3) and SCLK is 21.3 mm, longer than it needs to be. The unterminated 60 mm chip-select branch is the black mark.
- **Crystal:** Y101 is 8–10 mm from the MCU. XIN is 13.6 mm and XOUT 6.5 mm, both 0.15 mm wide, running side by side at 0.2 mm gap for about 8–9 mm (y = 116.5/116.85). XIN passes directly below D201's pads and comes within 0.36 mm of `+5V_LED` at (134.5, 117.1). Ground under both is unbroken.

### Power: 7
- **Widths:** `+5V` 0.4–0.5 mm, `+5V_LED` trunk 0.4 mm (109 mm; about 135 mΩ end to end, tens of mV at 360 mA), `+3V3` trunk 0.4 mm on F.Cu with 0.3 mm branches. The 0.25 mm `+5V_LED` pieces feed only U106 and D501. The LDO input is fed through 4 mm of 0.2 mm track (120.25–122.15, 131.45), which is thin for the regulator feed.
- **Decoupling is the closest of the three on 3V3:** 1.4–2.4 mm to seven of nine 3V3 pins. U103.10 is 3.9 mm from its nearest capacitor. C115 and C117 both sit at pin 23, so pin 50 relies on C116 at 3.0 mm.
- **Regulators:** LDO capacitors C102/C104 are 1.6/1.5 mm from U101; load-switch capacitors C119/C120 are 2.0/2.2 mm from U105.
- Bulk capacitor C101 is at (156.9, 134), about 36 mm from the fuse and LDO along the edge track. It is close to the LED switch, which is defensible.

### Placement: 7
- **Meets the size brief best:** 2558 mm², 13 % smaller than A and 21 % smaller than C, with a plain rectangular outline.
- **Sensible grouping:** flash beside the MCU, USB then ESD then resistors then MCU in order, LDO next to the connector, load switch among the LEDs, level shifter 3.8 mm from its MCU pin.
- **USB connector** at the lower-left corner facing left, on the footprint's "PCB Edge" line (x = 109.0).
- **Costs of the compaction:** BOOTSEL in the middle of the key area (hard to reach in a case, and the cause of the 60 mm trace); crystal further out than it should be; flash turned so three of its lines go the long way round.

### Routing and manufacturability: 6
- DRC clean. Three warnings: two silkscreen ones at C103 (117.4, 112.8 and 116.2, 111.4) and the common footprint mismatch.
- **Four ground vias sit in small solder pads:** C106.2 (127, 118), C401.2 (171, 114), D501.1 (131, 134, a locked LED pad of 1.35 × 0.82 mm) and C101.2 (159, 134). With unfilled vias these wick solder; move them off the pads before machine assembly.
- `+5V` at 0.35 mm from the edge passes the 0.2 mm rule but leaves little margin.
- One very acute junction on `+3V3` at (115.12, 121.0), about 15°.
- All vias 0.6/0.3 mm, 24 of them on signals or power, which is the fewest of the three. Narrowest track 0.15 mm.

---

## Board A (second)

The tidiest signal routing and the best USB section, but the microcontroller's ground is badly connected. That is invisible to DRC and must be fixed before ordering.

### EMI: 4
- **The RP2040's only ground goes through one via into an isolated patch of copper.**
  - Pad 57 and pin 19 leave on a 0.45 mm track to a single via at (119.8, 117.05).
  - That via lands on a 30.5 mm² F.Cu island (115.7–123.5, 109.5–117.6) that signal tracks cut off from the main plane.
  - The island reaches the rest of ground only through two more vias, at (118.8, 112.0) and (122.5, 112.41).
  - The B.Cu pour does not reach the pad either.
  - So all MCU return current, and every decoupling loop, passes through two or three vias in series. The board will very likely still run, but this is the first thing to fix: put 4–9 vias in the pad and reconnect the island.
- **Hole in F.Cu under the flash bus:** about 6 × 13 mm (111.8–118.0, 105.8–118.6), enclosed by the QSPI tracks themselves. As a result 48–71 % of each QSPI data and clock track has no ground on the other layer (`/QSPI_SCLK` 71 %).
- A second unfilled F.Cu strip follows `/KEY3` and `/KEY6` at y = 121–121.6 from x = 122 to 147.
- **Good points:** pours on both layers; no signal closer than 1.5 mm to the edge; `+5V_LED` stays on one layer; the USB section is short and compact.
- `/LED_DIN_3V3` is 28 mm long with 4 vias and 45 % of it has no ground opposite.

### Signal integrity: 6
- **USB is the best of the three.** 9.35 and 9.29 mm, all on B.Cu, no vias. The ESD part (U102) is 2.7 mm from the connector with the lines running through its pads. The 27 Ω resistors are 1.6–2.3 mm from the MCU pins.
- **QSPI is short** (11–15 mm; `/QSPI_SS` 19.4 mm including BOOTSEL), but every data and clock line has 2 vias and runs over the F.Cu hole described above.
- **Crystal:** XIN 8.5 mm, XOUT 2.7 mm. XIN runs 0.2 mm from `/LED_DIN` (5 V LED data) for about 3.5 mm near (126.2, 116.8), and crosses five F.Cu tracks between x = 121.5 and 124.4. The crystal's ground pads and load capacitors sit on their own B.Cu island with 5 vias, which is fine.

### Power: 5
- **5 V widths are generous:** `+5V` 0.5 mm, `+5V_LED` 0.5–0.6 mm with no vias, VBUS 0.5–0.55 mm.
- **`+3V3` is 0.2 mm almost everywhere** (75 of 81 mm), including the feed from the LDO. Electrically adequate (about 0.12 Ω per 50 mm) but thin for a rail.
- **Decoupling is looser than B:** about 2.0 mm at pins 1, 10 and 33, but 4.6–5.4 mm at pins 22, 48 and 49. C116 is 3.4 mm from the 1V1 regulator pin. `+1V1` goes through 6 vias and 17 mm of F.Cu under the chip.
- Every one of those capacitors returns through the single-via ground path, which is why this score is below B's.
- **Regulators:** LDO capacitors 1.8–2.5 mm, load-switch capacitors 2.3 mm, bulk C101 7 mm from the LDO. Fuse, LDO and switch form a compact group at the lower left.

### Placement: 7
- **Clean flow:** connector, ESD, resistors, MCU in a straight line at y ≈ 118–120; flash above the MCU; power group below; level shifter U106 next to the first LED; BOOTSEL in the top-left corner where a case can reach it.
- USB connector mid-height on the left edge, on the footprint's edge line (x = 97.0).
- **Not as small as it could be:** 2953 mm² with a 22 mm wing. There is unused area around SW101 (97–106, 107–113) and at the lower left. The outline has a 3.1 mm step at x ≈ 117 (y = 135 against 138.1).

### Routing and manufacturability: 7
- DRC clean, with only the common warning.
- No vias in pads, nothing under 0.2 mm, nothing near the edge, all vias 0.6/0.3 mm.
- The designer tightened the board minimums to 0.15 mm, closer to what the fab actually holds.
- 44 non-ground vias is on the high side: every QSPI line changes layer, `/KEY1`, `/KEY3` and `/LED_DIN_3V3` have 4 each.
- A few 45° tee junctions on `+5V_LED` (for example 144.55, 130.72) and a doubled-back stub on `/USB_D-` at (104.36, 119.35). Cosmetic.

---

## Board C (third)

The largest board, with a connector position that is likely to foul USB cables, and a single-sided ground with holes under the most sensitive parts.

### EMI: 3
- **No B.Cu pour at all.** Every part is on the back and returns through one via each, or through 0.2 mm ground tracks (81 mm of them).
- **The one plane (F.Cu) has large holes exactly where it matters:**
  - 8.0 × 5.4 mm under the crystal, C106, C107 and C115 (106.8–114.8, 99.3–104.8), ringed by a `+3V3` track.
  - 12 × 9 mm under the south and east sides of the MCU (106.8–119, 107.7–116.8), including the USB pins.
  - 17.6 × 13.8 mm around SW201 and D201 (115.5–133.2, 102.9–116.8).
- **The LED supply is routed through the quiet area.** `+5V_LED` (up to 360 mA, switching) runs under the flash on B.Cu (x = 103.1, y = 110.7–116.8), then on F.Cu diagonally under the USB ESD part and across both USB lines (109.5–115.1, 123.15). `+5V` runs under the flash too (x = 100.7, y = 111.8–118.5), 0.23 mm from the ends of the flash's pin 1–3 pads.
- **`/LED_DIN` (5 V data) runs on F.Cu under the MCU** (x = 108.6, y = 111–115.4), directly over `/QSPI_SCLK` for 2.2 mm with no plane between, then under the USB pins at y = 116.4.
- Good point: nothing is routed near the edge (closest signal 1.7 mm).

### Signal integrity: 4
- **USB:** 10.3 mm against 13.5 mm (3.2 mm skew, harmless at full speed). D− has two vias; D+ has none. 41–62 % of the connector-side tracks have no ground opposite, because VBUS and `+5V_LED` occupy F.Cu there. The MCU-side tracks run 87 % over a plane hole, and one of them is necked to 0.13 mm for 4.1 mm.
- **QSPI:** SD0, SCLK and SD3 are the shortest of any board (3.4–5.7 mm). SD1, SD2 and SS cross on F.Cu for 6–10 mm with two vias each and no reference.
- **Crystal:** the closest placement (2.7 mm from the XIN pin; XIN 6.9 mm). But there is no ground under it, XOUT changes layer twice and runs on F.Cu underneath the crystal body (107.8, 100.3–102.5), and XIN crosses over XOUT on opposite layers for about 1.5 mm.

### Power: 4
- **Nominal widths are good:** 0.5 mm for the 5 V rails, 0.3 mm net class for `+3V3` and `+1V1`. But there are 0.13 mm necks at the MCU pins and elsewhere (about 16 mm in total).
- **3V3 capacitors are close** (1.5–2.8 mm).
- **1V1 decoupling is poor:** C115 and C117 are 5.2 and 6.1 mm from pin 23, C116 is 5.6 mm from the regulator output pin 45, and pin 50's nearest capacitor is 7.2 mm away, all through vias.
- **Capacitor grounds travel on thin tracks to a distant via:** C104 (LDO output) 5.5 mm, ending at the USB shell pin; C106 3.9 mm; C103 3.4 mm; C102 3.4 mm.
- C120 (load-switch output) is 9.1 mm from U105.
- The LED rail takes a long detour from U105 at the far left and changes layer through four single vias.

### Placement: 3
- **Largest board:** 3232 mm², 26 % larger than B. It grows 2.65 mm above the top of the key block (y = 97.35), which makes the bounding box 40.75 mm tall. The brief asked for the opposite.
- **USB connector is a mechanical problem.**
  - It faces the front (user) edge, inside a recess.
  - It sits 0.63 mm behind the board edge: the footprint's "PCB Edge" line is at y = 132.37 and the board edge is at y = 133.0.
  - The key block sticks out 5.1 mm further, starting 5.75 mm from the connector centre (x = 116.95 against 111.2). The USB-C plug overmould may be up to 12.35 mm wide (6.18 mm each side), so wide plugs hit the board and typical ones have almost no clearance.
  - This needs a respin, not a patch.
- Level shifter U106 is at (101, 104.5), on the far side of the MCU from the first LED, which causes the 34 mm `/LED_DIN` route under the MCU.
- Load switch U105 is at the far left, away from both the 5 V source and the LEDs.
- Good: crystal, flash and the 3V3 capacitors are tight to the MCU.

### Routing and manufacturability: 5
- DRC clean; two warnings (silkscreen over C112 pad 1 at 105.66, 111.4 and the common one).
- **Five ground vias are 0.45/0.3 mm** (0.075 mm annular ring), at (108.9, 108.1), (108.9, 109.5), (109.8, 110.0), (104.61, 109.05) and (112.3, 121.9). They pass the project's rule file but are tighter than the 0.6/0.3 used everywhere else, for no visible need. I did not check them against JLCPCB's current published limits.
- One via sits in a SOT-23-6 pad (U102.2 at 112.3, 121.9).
- 0.13 mm tracks are right at the usual 0.127 mm fab minimum.
- 53 non-ground vias, the most of the three.

---

## Why this order

1. **B** has no defect that blocks an order. Its ground is continuous and well stitched, the MCU is properly grounded and decoupled, and it is the only board that takes "as small as is sensible" seriously. Before ordering I would move BOOTSEL (or accept the 60 mm chip-select branch), pull `+5V` and the QSPI lines in from the edges, and move the four vias out of pads.
2. **A** has better USB, shorter buses, wider LED power and cleaner fabrication detail than B. But its microcontroller ground through a single via into an isolated copper island, plus the plane hole under the flash bus, undermine the return path of every fast signal on the board. The fix is small; as submitted it ranks below B. It is also 13 % larger than B.
3. **C** is last by a clear margin: likely cable interference at the USB port, a single-sided ground with holes under the crystal, MCU and USB, the LED supply and LED data routed through the flash and USB area, and the largest outline.
