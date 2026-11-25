# Layout review: Arduino Mega 2560 (USB-C), boards A–D

**Verdict:** order none of them untouched, but A is the closest: it needs two small fixes. C is orderable but has a fragmented ground. D needs a zone refill and a DRC clean-up first. B is unfinished and cannot work.

**Ranking:** A > C > D > B

| Board | EMI | SI | Power | Placement | Routing / mfg | Overall |
|---|---|---|---|---|---|---|
| A | 7 | 7 | 6 | n/a | 8 | **7** |
| C | 5 | 5 | 7 | n/a | 7 | **6** |
| D | 6 | 6 | 6 | n/a | 5 | **5.5** |
| B | 1 | 2 | 1 | n/a | 1 | **1** |

Placement is not scored: the job fixed it, and `bt same` confirms all four boards have identical parts, positions and pad nets.

## How I measured

All work was on copies; `/work/boards` is untouched. Coordinates are KiCad mm, y down.

- **DRC three ways:** on the file as saved (each board's own rules), after a zone refill, and on copies with one uniform JLCPCB rule set (0.127 mm clearance and track, 0.25 mm hole clearance, 0.3 mm edge, 0.45 mm hole-to-hole).
- **Copper path lengths:** I rasterised each net's copper (tracks, pads, zone fills, vias) at 0.05 mm and ran a shortest-path search between pads. "Copper path" below means that length; "×n" is the ratio to the straight-line distance.
- **Ground network quality:** the same search from 7 ground pads (U3.11, U3.62, U3.81, U4.33, J4.2, J1.A1, J5.35) to every other GND pad, 359 pairs per board.
- **Power bottlenecks:** widest-path search over the track graph, giving the narrowest track between source and load.
- **Edge proximity:** non-GND track length with less than 1.0 mm of board left between copper and an edge or hole.

Baseline items common to all four boards are not scored against anyone. These are 12 courtyard overlaps, 37 silk overlaps, 8 silk-over-copper and 5 silk-at-edge warnings, and 51 library mismatches. They come from the fixed placement and footprints, and no designer changed the silkscreen. The J1 footprint's own GND pads sit 0.194 mm from its NPTH pegs on every board.

USB here is full speed (12 Mbit/s into an ATmega16U2), so a few millimetres of skew is irrelevant. I judged the USB pair mainly on reference plane and return path.

### Key numbers

| Measure | A | B | C | D |
|---|---|---|---|---|
| Unconnected items (KiCad DRC) | 0 | 88 (41 nets) | 0 | 0 |
| DRC errors on saved file, beyond baseline | 0 | 0 | 0 | 515 |
| Same, after refill | 0 | 0 | 0 | 4 (+1 dangling-end warning) |
| Real spacings under 0.127 mm | 0 | 0 | 0 | 10 (0.119 mm) |
| GND fill F.Cu / B.Cu (mm²) | 2102 / 3547 | none / 2930 | 2793 / 3314 | 2221 / 2942 |
| GND fill pieces F.Cu / B.Cu | 28 / 1 | – / 4 | 42 / 23 | 19 / 3 |
| Vias total / GND / signal | 221 / 134 / 68 | 169 / 8 / 159 | 200 / 98 / 88 | 154 / 53 / 74 |
| Ground path detour, median / p90 / worst | ×1.25 / ×1.86 / ×5.4 | open | ×1.68 / ×2.86 / ×27.5 | ×1.44 / ×2.67 / ×10 |
| Ground pairs with more than ×2 detour | 8% | – | 31% | 20% |
| GND fill directly under J1 (F / B) | 70% / 35% | – | 73% / 73% | 0% / 0% |
| Non-GND track within 1 mm of an edge | 154 mm | 47 mm | 209 mm | 47 mm |

---

## Board A — overall 7

The most disciplined board: clean DRC, the best-connected ground, sensible widths. It has two real flaws, both cheap to fix.

### EMI: 7
- **Ground is the best of the four.** B.Cu GND is one piece (3547 mm²), F.Cu is also poured, and 134 GND vias stitch them on a roughly 3 mm grid. Only 8% of ground pairs detour more than ×2.
- **U4 and USB are well grounded.** B.Cu GND covers 99% of the area under U4, which has 4 vias in its exposed pad. J1.A1 to U4.33 is 16.3 mm of copper for 14.0 mm straight.
- **AVCC return is broken by a +5V trunk.** A 0.8 mm +5V track on B.Cu runs at y = 95.6 from x = 140.1 to 153.2, directly under U3 pins 82–100. C18.2 (141.36, 95.57) drops to the south side of it and U3.99 goes to a via on the north side, so the cap-to-pin ground path is 38.6 mm for a 1.7 mm gap.
- **U3.62 sits on a ground peninsula.** The ADC8–15 and TXD/RXD bundles on B.Cu wall off the area east of U3. U3.62 to U3.11 is 53.4 mm (×3.5) and U3.62 to U3.81 is 40.8 mm.
- **Input ground is cut between jack and regulator.** RESET on B.Cu along y ≈ 118 (x 99 → 118) and VCC on F.Cu along y ≈ 119.9 separate J4 from U1. J4.2 to U1.1 is 32.5 mm for 9.6 mm straight.
- **Edge runs.** SCL has 68 mm on F.Cu outside the header row at y ≈ 79.1, and Net-(D6-A) has 50 mm on B.Cu along the same edge; neither has ground between it and the edge. VCC has 20 mm along the bottom edge.

### Signal integrity: 7
- **USB:** D+ stays on F.Cu (9.1 mm including the A6/B6 link). D− crosses over through 2 vias (5.0 mm on B.Cu). RD+ is 7.3 mm and RD− 5.5 mm, a parallel 0.25 mm pair entirely over B.Cu ground.
- **Main resonator Y1:** XTAL1 15.6 mm and XTAL2 14.3 mm, routed as a tight pair with a dedicated GND guard track from Y1.2 back to U3.32 (16.3 mm). This is the best crystal treatment of the four. A +5V trunk and PB1–3 cross underneath on B.Cu.
- **Y2 (U4 crystal):** 8.2 mm each, 88% over ground; load-cap grounds reach U4.3 in about 9 mm.
- **Analog:** the AVCC loop above and the +5V trunk under the ADC pin row will cost ADC noise performance. The ADC bus runs as one bundle on B.Cu from vias inside the U3 footprint.
- **Long nets:** SCL 145.5 mm and SDA 131.1 mm with 2 vias each; RESET 129 mm with 4 vias, the shortest of the three complete boards.

### Power: 6
- **Input:** Net-(D4-A) is 1.2 mm; VCC is 1.0–1.2 mm. But VCC leaves C1, loops west round U1 and enters U1.3 from the top: 31.1 mm from C1.1 to U1.3 for 10.7 mm straight. C4 (100 nF) is 3.4 mm from the pin, so the regulator is still decoupled.
- **Regulator output:** U1.2 to C2.1 is 18 mm with a 0.6 mm minimum. That is fine.
- **Distribution:** trunks are 0.5–1.0 mm; J5.1 is reached through at least 0.5 mm over a 117 mm path; pin stubs are 0.25 mm.
- **U1 has no heat-spreading copper.** The tab pad has 3 vias (103.2, 112.7 / 113.9 / 115.1) to a 1.0 mm B.Cu track and nothing else. With a 9–12 V input this SOT-223 will run hot. C and D both pour copper here.
- **Decoupling:** C8 is good (2.5 mm supply, 5.7 mm ground). C7 is 6.3 mm and 12.3 mm. C18 is poor (2.4 mm supply, 38.6 mm ground). U3.61 is fed by a 0.8 mm track under the chip from the C8 side.
- **USB power:** XVCC goes down to B.Cu at 0.5 mm through 2 + 2 vias, 27 mm in all. USBVCC is 0.8 mm.

### Routing and manufacturability: 8
- 0 DRC errors beyond the baseline on its own rules (0.2 mm clearance, 0.25 mm signal tracks), 0 unconnected, fills current. Also clean at the uniform JLCPCB limits.
- Vias are 0.6/0.3 and 0.8/0.4 mm. The designer added a `.kicad_dru` rule holding routed copper 0.25 mm from holes, with the reason written in the file.
- Nits: 7 open vias in pads (U1 tab ×3, U4 exposed pad ×4) can wick solder; 4 duplicated zero-length GND segments; 221 vias is the highest count, though 134 are stitching.

**Fix before ordering:** move the +5V trunk out from under U3's top pin row (or tie C18.2 to U3.99 on F.Cu), and add a +5V pour with more vias on the U1 tab.

---

## Board C — overall 6

Orderable as it stands, with the tightest local decoupling, but the ground is chopped up and the main resonator is the worst routed of the three complete boards.

### EMI: 5
- **Ground is poured but fragmented.** F.Cu GND is in 42 pieces and B.Cu in 23, held together by 98 vias. 31% of ground pairs detour more than ×2, and B.Cu carries 1960 mm of mostly north–south signal track.
- **J12.6 is almost orphaned.** The ICSP ground pin is 222 mm of copper from U3.62, 8.1 mm away (×27.5). The ICSP return loop is therefore most of the board.
- **U3 ground pins are poorly tied together:** U3.62 to U3.11 is 81.8 mm (×5.3) and U3.81 to U3.32 is 68 mm.
- **U4 corner:** C17.2 and C13.1 reach U4.3 only through about 32–34 mm. A 0.65 mm +5V trunk on B.Cu runs diagonally under U4's exposed pad (117.2, 96.8 → 111.0, 103.0), and the exposed pad has no vias.
- **Edge runs are the worst of the complete boards:** +5V has 77 mm on B.Cu along the top edge at y ≈ 79.1, and SCL and SDA have about 60 mm each on F.Cu outside the header row.
- Good: USB connector ground is short (J1.A12 to U4.33 is 15.8 mm), and the jack-to-regulator ground is direct (9.8 mm).

### Signal integrity: 5
- **USB:** same topology as A at 0.22 mm. RD+ 7.1 mm and RD− 5.7 mm are fully over ground; D− has 2 vias. CC1 takes an unnecessary 2-via detour on B.Cu (7.4 mm against 2.1 mm on the other boards).
- **Main resonator Y1 is weak.** XTAL1 (14.4 mm) and XTAL2 (13.2 mm) are only 26–30% over ground. They cross ADC0–3 and PB0/PB3 on B.Cu around x 143–147, y 112–116, which puts 16 MHz directly over analog inputs. Y1.2's ground is one via, 28.5 mm from U3.32.
- **Y2:** 8.2 mm each and 86% over ground, but C17's ground return is 31.5 mm.
- **Analog:** AVCC is tight (2.1 mm supply, 2.8 mm ground at C18), the best of the four. AREF stays on F.Cu (31.3 mm), 73% over ground.
- RESET is 190 mm; PB3 is 110 mm.

### Power: 7
- **Input:** Net-(D4-A) 1.05 mm; VCC 0.85 mm and direct (D4.1 to U1.3 in 23 mm, C1.1 to U1.3 in 11.6 mm).
- **Regulator:** U1.2 to C2.1 is 16.5 mm at 0.85 mm. Small +5V pours sit on both sides of the tab (70 and 59 mm²) with 4 vias: adequate, not generous.
- **Distribution is thin.** U3 is fed through 0.35 mm for 38–57 mm. J12.2 hangs on 133 mm of 0.35 mm (147 mm path). J5.1 has a 0.45 mm minimum over 125 mm. AVCC and USHIELD are 0.2 mm. All of this works electrically, but it is not what I would draw for a rail that also feeds shields.
- **Decoupling loops are the best of the four**, with explicit GND tracks from cap to pin: C8 2.5 / 4.3 mm, C7 5.3 / 8.0 mm, C18 2.1 / 2.8 mm (supply / ground). C6's ground is 36.6 mm from U3.32.
- XVCC is 0.6 mm; USBVCC 0.8 mm.

### Routing and manufacturability: 7
- 0 DRC errors beyond the baseline on its own rules (0.15 mm clearance, 0.2 mm tracks), 0 unconnected, fills current.
- At the uniform JLCPCB limits there is one flag: two GND vias almost on top of each other at (106.31, 89.27), with 0.427 mm between holes.
- Three net classes, but 17 different track widths (0.42, 0.55, 0.65, 0.85, 1.05, 1.3 mm and others) and three via sizes: not tidy.
- 81 right-angle joints and 12 acute joints, mostly 45° tees on power; 88 signal vias.

---

## Board D — overall 5.5

The most "designed" power and ground structure around the MCU, but the file as saved fails its own DRC, the USB corner has no ground, and the regulator's output capacitor is 75 mm away.

### EMI: 6
- **Best ground around the MCU.** F.Cu GND covers 65% of the area under U3 and the four GND pins are tied closely (U3.62 to U3.11 is 16.3 mm, ×1.1). Only 20% of ground pairs detour more than ×2. Only 47 mm of track runs within 1 mm of an edge.
- **No ground at all under the USB connector.** In the box x 98.5–104.3, y 88.5–101 there is 0% GND on either layer; the F.Cu copper there is an XVCC pour. J1.A1 to U4.33 is 36.3 mm for 14.0 mm straight (×2.6).
- **USB shield and ESD path is long.** J1.A1 to FB1.1 is 46 mm of ground for 5.5 mm straight. J1.A1 and J1.B12 hang on single-spoke thermals (DRC `starved_thermal`).
- **+5V wraps the USB corner.** The 1.27 mm trunk on B.Cu runs from the via at (108.3, 102.6) up past the connector to J2.2, crossing under the D+/D− pads.
- **U4 corner ground is fragmented:** U4.33 to J2.6 is 82 mm (11 mm straight), and from U4.33 the median detour is ×2.5.
- **RESET hugs the left edge** for 31 mm on B.Cu at x ≈ 98.6, about 0.9 mm from the edge beside the USB and DC jacks. That is an ESD exposure.
- Sixteen ADC tracks run on B.Cu under the whole length of U3 (x 146–155).

### Signal integrity: 6
- **USB:** RD+ 7.1 mm and RD− 5.5 mm are fully over ground. D− is only 46% over ground with 2 vias, and the connector end has no reference plane. D+/D− widths step between 0.2 and 0.4 mm.
- **Main resonator Y1:** XTAL1 15.7 mm and XTAL2 13.9 mm, a clean parallel pair, 72–74% over ground and surrounded by pour. Y1.2 is 15.3 mm from U3.32.
- **Y2:** only 59–74% over ground; C16.2's ground is 17.9 mm from U4.3.
- **ADC inputs take the long way.** They go north to a staggered via farm (x 145–155, y 88–93), then south under the MCU on B.Cu, about 15 mm longer than A or C and under the digital core.
- AVCC is tight (2.4 mm supply, 3.2 mm ground). SCL is 167 mm and SDA 159 mm with 4 vias each; RESET is 201 mm with 5 vias.

### Power: 6
- **Input:** Net-(D4-A) 1.0 mm; VCC 0.8–1.0 mm and direct (C1.1 to U1.3 in 12 mm).
- **Best regulator thermal design:** +5V pours of 134 mm² (F.Cu) and 166 mm² (B.Cu) round the U1 tab with 8 vias.
- **The output capacitor is electrically remote.** U1.2 to C2.1 is 75 mm of copper for 15 mm straight. +5V leaves the pour at Q1, goes round the USB connector on B.Cu, necks to two parallel 0.4 mm tracks between the J2/J3 pins (114.5, 90.5 → 121.2, 90.5, about 6 mm), then runs down past U6 before it reaches C2 and J11. The 5 V header pin J11.4 is 87 mm from the regulator.
- **Two MCU decoupling caps are largely bypassed:** C6.1 to U3.31 is 92 mm of +5V, and C8.2 to U3.11 is 31 mm of ground for 4 mm straight. C7 (8.4 / 10.9 mm) and C18 are fine.
- A 1.27 mm +5V ring under U3 joins all four VCC pins (0.2 mm pin stubs).
- All zone connections are thermal reliefs with 0.25 mm spokes, including the bulk-capacitor grounds.
- Generous elsewhere: XVCC is 0.81 mm plus a pour, USHIELD 0.8–1.27 mm, +3.3V 0.6 mm.

### Routing and manufacturability: 5
- **The saved file fails its own DRC with 515 errors beyond the baseline.**
  - 499 are zone clearance errors: the stored fill sits 0.25 mm from tracks while the zones ask for 0.30 mm. The fills are stale (F.Cu GND is 2221 mm² as saved and 2083 mm² after refill). Physically 0.25 mm is harmless.
  - 6 are hole clearance errors, including the XVCC pour 0.026 mm from J1's NPTH pegs at (104.14, 90.67) and (104.14, 96.45).
  - 4 are solder-mask bridges where pours enter the fiducial openings (FID1, FID3, FID4).
  - 5 are edge-clearance errors, plus 1 starved thermal.
- **After a refill, 4 errors and 1 warning remain:** 3 starved thermals (U3.99, J1.A1, J1.B12), RESET on F.Cu 0.41 mm from the mounting hole at (163.77, 124.04), and a 0.0003 mm dangling SCL stub at (129.22, 92.29).
- **The rules were loosened:** board minimum clearance and track width are 0 and the class clearance is 0.1 mm, so DRC cannot catch fab-limit problems. Against 0.127 mm there are 10 real spacings of 0.119 mm, for example PH3/PE5 at (144.69, 82.16), PB1/PB3 at (162.43, 113.36) and AREF/AVCC at (143.53, 94.76).
- Good: large, robust vias (0.914/0.406 and 1.118/0.61 mm) and the lowest via count (154). There are 22 segments shorter than 0.05 mm and seven 0.15 mm segments.

**Fix before ordering:** refill and re-run DRC, restore real minimums, open the ten 0.119 mm gaps, and give C2 a direct connection to the U1 output pour.

---

## Board B — overall 1

Not a finished layout. It cannot be ordered.

### EMI: 1
- **Ground is not connected.** GND is in 36 separate pieces. The B.Cu pour (2930 mm²) exists but only 8 GND vias reach it, so U3, U4, U1, U7, J1 and every decoupling cap have floating ground pads. There is no F.Cu ground.
- Only 20% of routed track has ground on the other layer; B.Cu track has 0%.

### Signal integrity: 2
- **24 signal nets are open:** ADC0, 1, 3, 4, 9; PB0, 2, 3, 4, 5; PH4, 5, 6; PE1, PE3; TXD2/3, RXD2/3; PC1, PG0, PG1; Net-(D6-A). PB2 is in three pieces.
- What is routed is via-heavy: 159 signal vias (RESET 11, ADC13 9, PC2 8).
- RD+/RD− were length-matched to 6.811 mm each with serpentines around (110–112, 96–98). That is pointless on a 7 mm full-speed link, and with no ground connection there is no return path anyway.
- The crystal nets are routed (about 8.2 mm and 13–14 mm), but their load capacitors have no ground.

### Power: 1
- **+5V is in 30 pieces.** Only a 268 mm² pour round U1 exists; nothing connects it to U3, U4, U6, the headers or C2's load side.
- VCC (1.0 mm) and Net-(D4-A) (1.0 mm) are routed properly.
- USBVCC from F1 to Q1 is 0.2 mm on a 500 mA path; +3.3V is 0.15 mm; XVCC is 0.3 mm.

### Routing and manufacturability: 1
- 88 unconnected items across 41 nets, with 1144 mm of ratsnest left.
- At the uniform JLCPCB limits: two XVCC tracks 0.213 mm from J1's NPTH at (103.80, 91.87) and (104.63, 91.16), and via holes 0.436 mm apart at (125.14, 102.96) and (150.69, 93.22).
- Four 0.127 mm segments; 48 segments off the 45° angles.

---

## Ranking

1. **A (7).** Clean on every DRC pass, the only single-piece ground plane, the lowest ground detours, a guarded resonator pair and sensible power widths. Its two defects (AVCC return, no copper on the regulator tab) are local.
2. **C (6).** Also clean and orderable, with the best decoupling loops and a direct supply entry. It ranks below A because the ground is in 65 pieces with detours up to ×27, the 16 MHz resonator crosses ADC lines, and the +5V feeds are thin.
3. **D (5.5).** The MCU ground and supply ring and the regulator copper are the best engineering on any board. It ranks below C because it cannot be ordered as saved (stale fills, loosened rules, sub-minimum gaps), has no ground under the USB connector, and its regulator output capacitor is 75 mm away through 0.4 mm necks. C against D is close; D would pass C after an hour of clean-up.
4. **B (1).** Unfinished: ground and +5V are open and 24 signal nets are unrouted.

## Which board is the human's

**D, about 88% confident.** This guess did not influence the scores (D is ranked third).

- **Legacy imperial dimensions.** Tracks of 0.254, 0.813 and 1.27 mm and vias of 0.914/0.406 and 1.118/0.61 mm are 10/32/50 mil and 36/16, 44/24 mil: the signature of a design carried over from an older imperial-unit tool. A, B and C use round metric widths and 0.6/0.3 mm vias almost throughout.
- **Hand-drawn zones.** D's GND zone outlines run past the board edge (out to x = 200.1 against an edge at 199.3) and it has purpose-drawn pours: XVCC under the USB connector and +5V round the regulator on both layers.
- **Layout idioms.** A wide +5V ring under the MCU, a staggered via farm for the ADC escape, thermal reliefs on everything, and wide shield copper are habits, not optimiser output.
- **Human-style mess.** Stale fills, minimum clearance set to 0, a 0.0003 mm leftover stub, and 22 near-zero-length segments are what a long-lived, converted project accumulates.
- **The others look machine-made.** A has a regular stitching grid and a custom rule with a written justification. C has many algorithmic widths (0.42, 0.55, 0.85, 1.05 mm). B is abandoned mid-route with precisely length-tuned serpentines on a 7 mm USB stub.

The remaining doubt is that B shares D's Power class definition (1 mm track, 0.9144/0.4064 via). I read that as the starting project's setting, which both left untouched.
