# Layout review: macropad-top, boards A–D

Reviewed 2026-11-19. Circuit: RP2040 (U103, QFN-56) + W25Q128 QSPI flash (U104) + 12 MHz crystal (Y101),
USB-C full-speed (J101, USBLC6 U102, 27 Ω R103/R104), AP2112K 3V3 LDO (U101), TPS22917 load switch (U105) and
74AHCT1G125 level shifter (U106) feeding six SK6812MINI-E LEDs, six hot-swap MX keys wired straight to GPIOs.
Board 89 × 38 mm, 2 layers, 6 LED cut-outs.

## Ranking

| Rank | Board | EMI | SI | Power | Placement | Routing/DFM | Overall |
|---|---|---|---|---|---|---|---|
| 1 | **C** | 8 | 7 | 8 | n/a | 7 | **8** |
| 2 | **D** | 7 | 7 | 6 | n/a | 7 | **7** |
| 3 | **A** | 6 | 7 | 6 | n/a | 6 | **6** |
| 4 | **B** | 4 | 4 | 4 | n/a | 4 | **4** |

**Order C or D; do not order B as it is.** A is orderable and would work, but is the least robust of the three usable boards.

Placement is scored null for all boards: the job fixed it, and I confirmed footprint positions, rotations, sides
and silkscreen text are identical on all four boards (so silkscreen is not a differentiator either).

## How I checked

- KiCad 10 DRC (with zone refill and courtyards) on copies of each project: **all four are clean** – 0 errors,
  0 unconnected, saved fills up to date. The one warning (`lib_footprint_mismatch` on U103) is common to all.
- Everything else is measured from the board files with pcbnew + shapely scripts (kept in `/work/tools/`):
  per-net widths/lengths/vias, GND fill polygons and islands, how much of each track has GND fill on the
  opposite layer, copper path length from each supply pin to its nearest capacitor (includes 1.6 mm per via),
  copper distance to board edge / cut-outs / unplated holes, via-in-pad, junction angles, and what sits under
  and beside the crystal.
- Coordinates are KiCad mm (y down). "Covered" means GND pour on the other layer directly under the track centre.

Things that are the same on every board and so do not separate them:

- USB is full-speed (12 Mbit/s), ~12 mm long, routed straight through the USBLC6 pads at 0.2 mm width with the
  two lines ~1.9 mm apart (the TVS footprint forces it). None is a controlled-impedance pair; at this speed and
  length none needs to be. Skew is 0.4–1.0 mm on all boards – irrelevant.
- QSPI is on F.Cu with no layer change (except one net on B), SCLK runs 0.2 mm from SD0/SD3 for 13–19 mm on every
  board; lengths are set by the flash orientation (SCLK 18–20 mm, SD3 21–25 mm).
- +5V to U102 pin 5 has to cross under D+ on B.Cu on every board (via near 100.6, 106.5).
- XIN ≈ 5.6–6.9 mm, XOUT ≈ 3.5 mm, both on F.Cu with no vias on all four.

---

## Board C — overall 8 (rank 1)

The most complete engineering job: proper net classes, sensible widths, the best MCU grounding and the densest
ground stitching, with no manufacturability traps.

**EMI — 8**
- F.Cu pour is effectively one piece (2291 mm² main island, 76 % of the board); the only other islands are the EP
  island and slivers.
- 100 GND vias: every GND pad has one within about 1 mm (caps 0.8 mm, LEDs 1.3–1.4 mm, U104.4 0.9 mm, U101.2 1.0 mm),
  plus perimeter stitching (e.g. row at y = 100.85, 0.55 mm copper-to-edge).
- Crystal: 100 % B.Cu ground under Y101, no foreign tracks or vias within 0.5 mm, GND vias at (117.75, 108.25) and
  (116.58, 112.5).
- B.Cu carries the key bus, so it is cut into one main piece (1918 mm²) plus four islands of 32–41 mm² between the
  LED data/power runs, each tied with a single via (e.g. island 133–151.6 × 113.2–116.8).
- /KEY1 (F.Cu) and /KEY3 (B.Cu) run 0.92–0.95 mm from the top edge for 13 mm and 10 mm.
- The VBUS link is a 5.5 mm B.Cu jumper at x ≈ 95.7 directly under the D+/D-/CC escape, so /USB_D+ is only 64 %
  covered (D- 90 %).

**SI — 7**
- USB: D+ 11.0 mm, D- 12.0 mm total; reference gaps as above.
- Crystal nets 100 % covered.
- QSPI: no vias; /QSPI_SD1 46 % and /QSPI_SD2 57 % covered because the 0.5 mm +3V3 trunk on B.Cu (y ≈ 112.7,
  x 99–108.3) lies under them; SCLK 88 %.
- /LED_DIN_3V3 and /LED_EN run side by side at 0.2 mm for 15.9 mm on B.Cu and are only 31 % / 39 % covered – slow
  signals, cosmetic.

**Power — 8**
- Net classes Power (0.5 mm, 0.8/0.4 vias), Supply (0.3 mm), USB.
- VBUS 0.4–0.5 mm, +5V 0.4–0.8 mm (the 0.3 mm part is the U102 reference feed), +5V_LED 0.5–0.6 mm with 0.8/0.4 vias,
  +3V3 0.25–0.5 mm, +1V1 0.3 mm.
- RP2040 ground: five 0.5/0.3 vias in the exposed pad at (107.5, 107.5), (108.25, 106.75), (108.25, 107.5),
  (108.25, 108.25), (109.0, 107.5), placed *between* the back-side capacitor pads and tied to them with a 0.4 mm
  B.Cu web. This gives a short decoupling loop without via-in-pad on the 0603s.
- Every RP2040 supply pin reaches a capacitor in 1.9–4.8 mm of copper including the via; the one outlier is
  DVDD pin 45 → C116 at 5.9 mm.
- LDO: C102 2.0 mm from U101.1, C103 2.1 mm from U101.5. U106.5 → C121 1.9 mm. Each LED → its capacitor 1.8 mm.
- Minus: thermal reliefs on all pads including decoupling caps (0.4 mm spokes, 0.25 mm gap) – acceptable.

**Routing / DFM — 7**
- Nothing closer than 0.44 mm to a cut-out, 0.55 mm to the outer edge, 0.37 mm to an unplated hole.
- Via holes in SMD pads only in the QFN exposed pad.
- 128 vias (the most; free at JLCPCB). Ten are 0.5/0.3 (0.1 mm ring) – within JLCPCB's limits but the tightest
  feature on the board.
- 19 of 369 segments are off the 45° directions; two odd junction angles (66° on GND B.Cu at 104.94, 104.79; 71° on
  +3V3 F.Cu at 98.98, 113.3). No sub-0.1 mm fragments.

---

## Board D — overall 7 (rank 2)

The best layer strategy of the four (bottom layer kept as a real ground plane, everything long on top), let down
by a weak ground connection for the MCU and some copper too close to the edge.

**EMI — 7**
- B.Cu ground is a single 2358 mm² piece (78 % of the board); the largest non-ground region on B.Cu is 53 mm²
  (A and B have ~700 mm² regions).
- Key lines and the LED supply run on F.Cu above that plane: /KEY2 92 %, /KEY3 94 % covered.
- 52 GND vias, one about 0.9–1.8 mm from every GND pad.
- Crystal: 100 % B.Cu ground and a GND via in the middle of the footprint (115.4, 109.52).
- **RP2040 exposed pad has no via in it.** The chip's only ground reaches the plane through two 0.45 mm F.Cu necks
  to vias outside the pad, at (108.55, 105.81) and (110.5, 110.5). Every MCU return current goes through those two.
- /KEY1 via at (120.19, 100.67) is 0.37 mm from the top board edge; /KEY1 and /KEY2 run ~0.9 mm from that edge on
  the top layer for 18 mm and 36 mm. A GND via at (107.55, 126.72) is 0.27 mm from the edge.
- F.Cu pour is chopped by the key fan-out into seven pieces; islands of 33 mm² (130–140 × 112.6–116.3) and 22 mm²
  hang on one via each.
- VBUS runs on B.Cu under the connector (0.65 mm, x ≈ 91.4, y 105–111.9), breaking the plane under J101.

**SI — 7**
- USB main run is the best covered of the four (D+ 93 %, D- 100 %); the last 2.1–2.3 mm into U103.46/47 pass over
  the C116/C117 pads with no ground (0 %).
- Crystal clean. QSPI no vias, 47–80 % covered (SCLK 80 %); bus pitch 0.5 mm in the vertical run.
- /Key1/DOUT 61 % covered (crosses the F.Cu key tracks).

**Power — 6**
- Generous copper: +5V_LED 0.8 mm trunk on F.Cu (132 mm) dropping through 0.8/0.3 vias at each LED capacitor,
  VBUS 0.65 mm, +5V 0.55–0.72 mm, +3V3 0.35–0.5 mm with 0.2 mm necks only at the pins, +1V1 0.4 mm.
- Supply-pin-to-capacitor paths are as short as C's (1.9–5.2 mm).
- The ground half of those loops is the problem: back-side capacitor GND pads return through a 0.36 mm B.Cu ring to
  the single via at (108.55, 105.81); C106.2 is 4.6 mm, C110.2 and C114.2 2.6 mm from any GND via. Expect more
  ground bounce than A or C. It will work, but this is the one place D is clearly worse than the boards around it.
- U101.2 ground pin 3.7 mm from the nearest via (solid pour connection, fine for an LDO).

**Routing / DFM — 7**
- No via hole in any SMD pad (the only board that manages this). 88 vias. SMD pads connect solid, THT with reliefs.
- Edge issues above (0.37 mm signal via, 0.27 mm GND via); +5V_LED on F.Cu passes 0.26 mm from the 4 mm centre holes
  of SW501 and SW601 (y = 131.23) and 0.41 mm from the LED cut-outs; /KEY6 0.32 mm from a cut-out (y = 116.65).
- 19 distinct track widths (0.22, 0.27, 0.28, 0.32, 0.36, 0.42, 0.48, 0.72 …) and four via sizes with no net classes
  behind them – harmless to the fab, awkward to maintain. 20 segments under 0.1 mm long.

---

## Board A — overall 6 (rank 3)

A tidy, economical route with the cleanest USB entry and the shortest decoupling loops, but thin supply tracks,
very little ground stitching, and several via-in-pad choices.

**EMI — 6**
- F.Cu is nearly unbroken over the whole key area and the key bus runs on B.Cu underneath it, so overall reference
  coverage is the highest of the four (82.5 %; /KEY1–6 82–94 %, LED chain 100 %).
- Crystal: 100 % B.Cu ground, nothing foreign nearby.
- Only **18 GND vias on the whole board** (C has 100, D 52), five of them in/at the QFN pad.
- B.Cu is split into two large pieces (1427 and 461 mm²) plus four islands of 27–39 mm² on one via each.
- The top-side ground around USB/regulator is a separate 162 mm² island (87–109 × 100–119) joined to the rest by
  one via plus the J101 shell pins.
- Top-side ground pads are far from the plane: C118.2 9.6 mm from the nearest GND via, C101.2 8.4 mm, C104.2 7.6 mm,
  U104.4 (flash ground) 6.6 mm, C113.2 6.1 mm, C112.2 5.5 mm – all through thermal spokes.
- /KEY3 runs on B.Cu 0.9 mm from the top edge for ~54 mm; no perimeter stitching.

**SI — 7**
- USB: the two VBUS pins are linked on F.Cu under the connector (x ≈ 93), so there is no jumper under the pair.
  Main run D+ 84 %, D- 96 % covered.
- Crystal nets 100 % covered. QSPI no vias; /QSPI_SD3 63 %, SCLK 76 % covered.
- /LED_DIN_3V3 and /LED_EN at 0.2 mm spacing for 13.7 mm, ~50 % covered (slow nets).

**Power — 6**
- Input side is good: VBUS 0.8 mm (0.35 mm links at the pins), +5V 0.8 mm, +5V_LED 0.6 mm trunk.
- **+3V3 is 0.2 mm everywhere (64.7 mm)**, including the ~14 mm B.Cu feed from the LDO to the MCU and the branch to
  the flash; +1V1 also 0.2 mm (21.6 mm). The DC drop is small, but it is not what the brief asked for.
- RP2040 decoupling geometry is the tightest of the four: GND vias at (107.5, 106.78), (108.97, 106.75),
  (107.5, 108.22), (109.0, 108.22) go straight from the exposed pad into the GND pads of C105/C107/C114/C111
  (clearly what the placement was designed for). Supply pins reach a capacitor in 2.0–4.5 mm; pin 1 is the outlier
  at 6.9 mm.
- U103.49 (+3V3) has no track: it is connected only by the annular ring of the via at (105.65, 107.56) overlapping
  the pad tip by ~0.1 mm. Connected and DRC-clean, but marginal.
- U106.5 → C121 1.9 mm, LDO caps 1.8–2.0 mm. Thermal reliefs (0.5/0.5 mm) on every pad including decoupling caps.

**Routing / DFM — 6**
- 45 vias, four widths (0.2 / 0.35 / 0.6 / 0.8), all segments on 45° directions – clean and cheap.
- Via holes in five 0603 pads (C105.2, C107.2, C111.2, C114.2, C108.2 at 110.25, 109.5) and at the tips of QFN
  pads 48/49. Unplugged 0.3 mm holes in pads wick solder; assemblable, but a known yield risk.
- VBUS tracks 0.21 mm from the J101 locating-peg holes at (93.4, 103.6) and (93.4, 109.4).
- +5V_LED 0.21 mm from the D201 cut-out (segment 129.5, 117.5 → 131.25, 115.75) and 0.35–0.36 mm from others – at
  JLCPCB's 0.2 mm routed-edge minimum.
- 30 segments under 0.1 mm and vias sitting off the track ends (e.g. via 109.495, 110.621 vs track end
  109.45, 110.7); the project has `track_not_centered_on_via` switched off, as have the others.

---

## Board B — overall 4 (rank 4)

Passes DRC but has real engineering faults around the crystal, the decoupling, and clearances to unplated holes.

**EMI — 4**
- **Crystal:** only 49 % of the Y101 footprint has ground on B.Cu, and /KEY3 runs on B.Cu straight under it
  (123.94, 110.78 → 116.54, 110.78 → 108.74, 102.98). /KEY6 vias at (117.84, 110.14) and (117.84, 111.44) and
  /KEY4 vias at (117.84, 109.24) and (117.89, 112.34) sit ~0.5 mm from the crystal pads. Five-centimetre GPIO tracks
  coupled to the oscillator are an emissions and start-up-margin risk.
- Lowest reference coverage (74 %): /KEY1 40 %, /KEY5 47 %, /KEY4 66 %, /KEY2 69 %. Keys are split across both
  layers (/KEY2 and /KEY5 cross the board diagonally on F.Cu, the rest on B.Cu), and island removal has left large
  holes in the B.Cu pour (e.g. x 108–122, y 102–110).
- 74 GND vias on a 4 mm grid do tie the two pours together; B.Cu is one piece (2067 mm²).
- /LED_DIN_3V3 takes a 38.9 mm loop around SW101 (others 19.5–27 mm) and then runs 0.2 mm beside /LED_DIN for 11–12 mm.

**SI — 4**
- Crystal: XOUT 46 % covered, the C113/R105 node 0 %, plus the foreign tracks above. A 49° junction on XIN at
  (112.8, 110.85).
- /QSPI_SD1 changes layer twice (two vias, 5.5 mm on B.Cu, 51 % covered) while the rest of the bus stays on F.Cu.
- USB itself is fine (11.8 / 12.2 mm, D+ 74 %, D- 91 % covered; VBUS jumper on B.Cu at x = 95.55 under the escape).

**Power — 4**
- Back-side decoupling caps are daisy-chained on 0.2 mm B.Cu track with very few vias up to the pins.
  Copper path from pin to nearest capacitor: U103.10 10.6 mm, U103.48 10.1 mm, U103.49 9.9 mm, U103.26 9.3 mm,
  U103.33 7.3 mm, DVDD U103.50 10.6 mm. C106 and C110 sit directly under pins 48/49 but are not connected there.
- U106.5 reaches its own capacitor C121 (1.9 mm away) only after 16 mm and four vias; nearest by copper is C120 at
  13.3 mm.
- Net classes are defined (Power3V3 0.3, Power5V 0.5) but not followed: +3V3 is 0.2 mm for 63 of 67 mm, +5V is
  0.3 mm for 23 of 33 mm. +5V_LED 0.4 mm – the thinnest LED trunk of the four.
- Good points: VBUS 0.5 mm, four GND vias in the exposed pad, LDO caps 1.9–2.3 mm from their pins, solid SMD pour
  connections.

**Routing / DFM — 4**
- 20 pieces of copper within 0.3 mm of unplated holes, 10 under 0.25 mm: /KEY3 0.20 mm from the SW301 pin hole
  (143.8, 107.0); /Key3/DOUT 0.20–0.22 mm from SW701's centre and pin holes; the **+5V_LED trunk for the whole
  bottom row threads between three SW701 holes** (x = 164.75 → 164.4, y 120.7–127.6) with 0.22–0.24 mm each side.
- Four runs 0.21 mm from LED cut-outs: /KEY5 F.Cu (126.4, 114.26–116.46), /KEY6 B.Cu (y = 116.53),
  +5V_LED B.Cu (y = 131.62, twice).
- /LED_EN necked to 0.127 mm for 12.6 mm with no obstacle requiring it.
- Two 0.4/0.3 vias (0.05 mm ring): in U102.2 at (96.75, 106.5) and in C108.1 at (110.9, 107.9). Within the project
  rules and JLCPCB's published minimum, but the weakest features on any of the boards.
- Grid stitching vias dropped into component pads: D301.1 (145, 114), D701.1 (169, 134), C201.2 (133, 114),
  edge of D201.1 (125, 114).
- Untidy joints (C102's track only overlaps its neighbour near 93.06, 114.28 rather than ending on it), 26 segments
  under 0.1 mm, 10 off-angle segments, 107 vias.

---

## Why this order

- **C over D:** both have real ground strategies and adequate copper. C grounds the MCU properly (5 vias in the pad,
  short loops on both the supply and return side) and keeps copper away from edges and holes; D's MCU ground goes
  through two vias outside the pad and it has a signal via 0.37 mm from the board edge. D's bottom plane is better
  than C's, which is why it is close.
- **D over A:** D has three times the ground stitching, a continuous plane, and supply tracks sized for the job;
  A has 0.2 mm +3V3 throughout, ground pads up to 9.6 mm from a via, and via-in-pad on five capacitors. A's
  advantages (decoupling geometry, USB entry, simplicity) are real but smaller.
- **A over B:** A has no functional risk I could find; B has the key lines under and beside the crystal, supply pins
  ~10 mm from their capacitors, and power copper 0.2 mm from unplated switch holes.

## Which board is the human's

**Board A, about 85 % confident.** (Decided after scoring; it did not change the scores.)

- Its zones are two plain 4-point rectangles named `GND_F` / `GND_B`, drawn past the board (x from 80.0 while the
  board starts at 87.0). B, C and D all use the identical 63-point polygon traced from the board outline, unnamed –
  the mark of the same tool.
- Its GND vias sit on a 0.25 mm hand grid (135.25, 115.0; 143.75, 112.25; 140.5, 133.75), while its track corners
  have push-and-shove coordinates (95.305, 106.518; 105.704, 112.175) and vias dragged slightly off the track ends.
- It uses the placement as evidently intended – vias through the exposed pad into the capacitor pads – with only 45
  vias, four track widths, one net class and no systematic stitching. B, C and D each show a scripted pattern:
  a via a fixed ~0.8–1.0 mm from every GND pad (C, D), a 4 mm stitching grid that lands in LED pads (B), invented
  net classes (B, C), or 19 computed-looking widths (D).
- The remaining doubt: A's all-45° geometry and economy could also come from a careful agent.
