# Layout review: Arduino Mega 2560 (USB-C), boards A, B, C, D

**Ranking, best first: B, C, A, D.**
**Recommendation: order none of them unchanged. B is the closest to orderable; D is not a working board.**

| Board | EMI | SI | Power | Placement | Routing / DFM | Overall |
|---|---|---|---|---|---|---|
| A | 5 | 6 | 5 | 7 | 5 | 5 |
| B | 6 | 7 | 7 | 8 | 6 | 7 |
| C | 7 | 6 | 6 | 6 | 7 | 6 |
| D | 2 | 2 | 2 | 3 | 1 | 2 |

## How I measured

- I worked on copies in `/tmp/rev`; nothing in `/work/boards` was changed.
- DRC is KiCad 10.0.8 (`kicad-cli pcb drc`) on each file as saved, then again after a zone refill. A second pass used JLCPCB-style minimums: 0.127 mm track and gap, 0.3 mm drill, 0.13 mm annular ring.
- "GND-referenced" means the share of signal track length that has GND pour directly beneath it on the other layer, sampled every 0.25 mm.
- "Copper path" lengths are shortest paths through the real copper of a net (pours, tracks, pads, vias) on a 0.2 mm raster, so they are good to about ±1 mm. A decoupling loop is supply pin → capacitor → ground pin.
- Coordinates are KiCad mm, y down.
- None of the board folders contains a NOTES.md, so I could not check any designer's stated intent.
- My power-path bottleneck script did not resolve every path; I only quote the ones it did.

The circuit: barrel jack J4 → D4 → VCC → U1 (NCP1117-5.0) → +5V. USB-C J1 → F1 → Q1 (P-FET switched by comparator U7) → +5V. U6 makes 3.3 V. U4 (ATmega16U2, crystal Y2) is the USB bridge; U3 (ATmega2560, resonator Y1) is the MCU. USB is full speed (12 Mb/s) and nothing else is faster than 16 MHz, so decoupling, return paths and the regulator matter more here than impedance control.

## Figures side by side

| Measure | A | B | C | D |
|---|---|---|---|---|
| DRC errors as saved | 527 | 4 | 4 | 4 |
| DRC errors after refill | 16 | 4 | 4 | 4 |
| Unconnected items | 0 | 0 | 0 | 58 (45 nets) |
| Tracks / vias | 1469 / 154 | 2091 / 287 | 986 / 216 | 962 / 214 |
| Vias on signal nets | 74 | 160 | 60 | 143 |
| Signal nets with no via (of 103) | 60 | 23 | 60 | 21 |
| GND pour share of board, F.Cu / B.Cu | 40% / 54% | 17% / 50% | 52% / 63% | 0% / 75% |
| Signal length GND-referenced | 49% | 22% (41% counting the +5V pour) | 52% | 28% |
| GND vias | 53 | 69 | 132 | 31 |
| U3 decoupling loops, pins 10 / 31 / 61 / 80 (mm) | 43 / 78 / 50 / 21 | 6.6 / 6.8 / 5.5 / 5.5 | 6.3 / 5.3 / 5.0 / 4.9 | open / open / open / 114 |
| USB ground return, J1.A1 → U4.28 (mm, straight) | 40 (11.8) | 15 (10.6) | 21 (12.2) | open |
| D+ / D− length, connector to RN2 (mm) | 9.0 / 9.8 | 12.0 / 11.8 | 16.0 / 11.1 | 12.9 / 12.8 |
| Y1 to U3 crystal pins (mm) | 11.1 / 12.7 | 2.8 / 3.2 | 3.8 / 6.1 | 12.1 / 11.2, unrouted |
| +5V pour on U1 tab | 129 mm² F + 162 mm² B, 10 vias | 84 mm² F + 55 mm² B, 8 vias, joined to the F.Cu +5V pour | none, 1 via | about 530 mm² F, 0 vias |
| Silk-over-pad warnings | 8 | 7 | 69 | 92 |

The 4 errors on B, C and D are courtyard overlaps between locked parts (J3/J2, J6/J2, FID3/J1, J4/FID2). They came with the job and I did not count them against anyone.

---

## Board A — overall 5

A sound, conventional arrangement with heavy power copper, but the MCU is badly decoupled and the file is not clean as delivered.

**EMI: 5**
- GND is poured on both layers (F.Cu 2083 mm² in 19 islands, B.Cu 2819 mm²) with 53 GND vias; 49% of signal length is GND-referenced.
- Two of the four U3 supply pairs have no local capacitor. Loops are 43 mm at pins 10/11 (C8 is 2.4 mm from the pin, but its ground comes back over 41 mm), 78 mm at 31/32, 50 mm at 61/62 and 21 mm at 80/81. C6 sits at the J11 header (136.3, 124.5), 16.5 mm from the nearest U3 supply pin.
- The USB ground return is long: J1.A1 → U4.28 is 40 mm of copper for 11.8 mm straight, and J1.A12 → U4.33 is 34 mm for 12.4 mm.
- The ground between the two processors is 75 mm for 23.8 mm straight (U4.33 → U3.11). The 16 ADC lines run as a B.Cu bus under U3 and cut the back pour.
- RESET runs about 30 mm along the left edge on B.Cu, 0.54 mm from the outline at (98.9, 88.5).

**Signal integrity: 6**
- USB: D+ is 9.0 mm on F.Cu only; D− is 9.8 mm with two vias and a 2 mm hop on B.Cu at (106.4, 93.9)–(108.0, 95.3). RD+ / RD− are 7.1 / 5.5 mm. Total skew is under 1 mm.
- Y2: 8.2 / 8.1 mm, matched, load capacitors 3.3 mm from the crystal. C16's ground returns over 19.5 mm for 5.6 mm straight.
- Y1 is 11–13 mm from U3, with 15.7 / 13.9 mm traces. That is long for a 16 MHz resonator, though there is nothing under it on B.Cu except a GND via.
- The AREF capacitor C5 is at the header (125.7, 87.2), 20.5 mm from U3.98; its loop is 88 mm.

**Power: 5**
- Track widths are generous: +5V trunk 1.27 mm (169 mm of it), VCC 0.8–1.27 mm, D4 anode 1.0 mm, USBVCC 0.6 mm, 3.3 V 0.6 mm to the header.
- The regulator has the best heat spreading of the four.
- The 47 µF output capacitor C2 is 79 mm of copper from the U1 tab (21 mm straight). The +5V trunk leaves U1, goes round the USB connector on B.Cu to J2, then comes back down to C2.
- U4.32 → C13 is a 28 mm loop.

**Placement: 7**
- Functional grouping is clear: USB and 16U2 top left, power bottom left, MCU central with a short fan-out to all headers.
- LEDs, the reset switch and JP2 sit at their printed legends (L, TX, RX, ON, RESET, RESET-EN).
- Decoupling placement is the weak point (above).
- U3 sits on top of fiducial FID4 (148.5, 103.3), so that fiducial is hidden after assembly.
- Eight extra courtyard overlaps: C16, C11, C17, R2 and C13 against Y2 (about 0.25 mm each), C18/U3, D3/J2 and FID4/U3.

**Routing and manufacturability: 5**
- As saved, the zone fills are stale: 499 clearance errors (fill at 0.25 mm where the zones ask for 0.3–0.4 mm).
- The stale fill also puts XVCC copper 0.026 mm from J1's NPTH holes at (104.14, 90.67) and (104.14, 96.45), and bridges the mask openings of FID1–FID4. A refill clears these; the board must be refilled before plotting.
- After refill, 16 errors remain: 12 courtyard overlaps, 3 starved thermals (U3.99, J1.A1, J1.B12) and RESET on F.Cu 0.41 mm from the mounting hole at (163.8, 124.0), against the board's own 0.5 mm rule.
- The net-class clearance is 0.1 mm. Ten gaps are between 0.10 and 0.12 mm, for example U3.1 to PE0 at (140.9, 97.3) and PB1 to PB3 at (162.4, 113.4). That is at JLCPCB's limit and below the usual 0.127 mm.
- Vias are large and robust (0.91/0.41 and 1.12/0.61 mm). Bus routing is tidy; only RESET has 5 vias.
- One 0.0003 mm dangling SCL stub at (129.22, 92.29).

---

## Board B — overall 7

The only board that gets decoupling, regulator copper and the printed legends all right; it pays for it with a chopped-up back ground and untidy routing.

**EMI: 6**
- U3 decoupling loops are 5.5–6.8 mm on all four supply pairs and 5.7 mm on AVCC.
- The USB ground return is the shortest of the four: 15 mm and 14 mm for about 10.5 mm straight.
- The stack-up idea is +5V poured on F.Cu (1977 mm², but in 16 islands) and GND on B.Cu (2682 mm², 11 islands). B.Cu also carries 2829 mm of track, so GND covers only 50% of the back.
- Only 22% of signal length is GND-referenced (41% if the +5V pour counts as a reference).
- Long ground detours: J6.4 → U3.99 is 149 mm for 43 mm straight; U4.33 → U3.11 is 97 mm for 36 mm.
- The +5V pour is so fragmented that U1 tab → U3.10 is 159 mm of copper for 29 mm straight.
- SCL runs about 65 mm along the top edge on F.Cu, 0.86 mm from the outline at (181.6, 79.3).

**Signal integrity: 7**
- USB: D+ 12.0 mm, D− 11.8 mm with two vias and a 1.5 mm B.Cu hop at (106.3, 92.55)–(106.3, 94.05). RN2 is next to U4, so RD+ / RD− are 1.9 / 3.0 mm.
- Y1 is 2.8–3.2 mm from U3, traces 5.8 / 5.3 mm, 81% GND-referenced. This is the best resonator layout of the four.
- Y2: 12.3 / 13.6 mm, load capacitors 9–10 mm from U4. Acceptable.
- AREF is 57 mm long with 3 vias and 14% GND-referenced, but C5 is 4.8 mm from the pin.
- TXD3 has 13 vias and PL5 has 11 (107 mm routed for 55 mm Manhattan). Harmless at these speeds, but it is why the back ground is in pieces.

**Power: 7**
- A 100 nF sits 2.6–3.4 mm from every U3 supply pin; C18 is 2.4 mm from AVCC.
- U1 tab → C2 is 6.5 mm; C4 is 2.5 mm from U1's input pin.
- VCC is 0.7–1.0 mm, the D4 anode 1.0 mm, USB power path F1 → Q1 0.55 mm.
- Weak points: 3.3 V to the header pin J11.5 necks to 0.22 mm; U4's two supply pins share C13 at 5–7 mm (loops 23 and 27 mm); the U6 output capacitor's ground return is 26 mm.

**Placement: 8**
- L, TX, RX, ON LEDs, the reset switch and JP2 are at their legends. No part sits on a printed label (7 silk-over-pad warnings, the same as the baseline).
- U3 at (149, 115), rotated, is central to the headers. Y1, the decoupling capacitors and FB2/C18 are tight to it.
- The USB protection parts are at the connector and the series resistors at U4.
- D4's pad is 0.81 mm from the edge of the mounting hole at (111.7, 129.1); a 5.5 mm screw head would land on it.

**Routing and manufacturability: 6**
- DRC is clean apart from the 4 inherited overlaps, and the fills are current.
- 287 vias, the most of any board, with 160 on signal nets.
- 23 different track widths (0.15, 0.17, 0.18, 0.185 … 1.0 mm) and 5 via sizes.
- Four zero-degree fold-backs: GND at (112.96, 97.55) and (114.65, 100.24), +5V at (158.05, 93.9), AREF at (156.66, 110.0).
- 29 vias are 0.56–0.58 mm on a 0.3 mm drill, a 0.13–0.14 mm ring: at JLCPCB's minimum.
- +5V on F.Cu passes 0.53–0.55 mm from two mounting holes, at (163.8, 96.1) and (187.9, 80.9).
- Minimum track 0.15 mm and gap 0.15 mm: fine for a standard order.

---

## Board C — overall 6

The cleanest routing and the best ground, but the regulator has no heat-spreading copper and the placement ignores the printed legends.

**EMI: 7**
- GND on both layers (52% / 63% of the board, 40% on both at once) with 132 GND vias on a 4 mm grid; 52% of signal length is GND-referenced.
- U3 decoupling loops are 4.9–6.3 mm; AVCC is 4.8 mm.
- SCL and SDA run about 65 mm outside the top header row on F.Cu, 0.62 mm from the edge at (183.7, 79.0). AREF runs 57 mm on B.Cu at the same edge, 0.62 mm from the outline at (175.2, 79.4).
- The +5V feed to J5.1/J5.2 goes round the perimeter: along y ≈ 127.5 and up x ≈ 197.5, about 117 mm, 0.61 mm from the edge at (195.8, 81.3). That is a large supply loop.
- The U4 ground return is 9–11 mm; the USB ground return is 21 / 26 mm for 12 mm straight.

**Signal integrity: 6**
- USB has no vias, but the pair splits. D+ is 16.0 mm and D− 11.1 mm. D+ runs past RN2, comes back up between RN2's pad columns at x = 111.0 (y 98.95 → 95.73), and has a 1.35 mm stub to RV2. Tolerable at 12 Mb/s; not how a pair should look.
- Y1's traces (9.1 / 5.3 mm) and Y1 itself at (177.1, 108.6) sit directly over the ADC1–ADC14 bus on B.Cu (x = 175.1–180.3). The crystal nets are 0–2% GND-referenced. A 16 MHz oscillator over the analog inputs is a real ADC noise risk.
- Y2: 10.9 / 10.9 mm, matched, 77% GND-referenced, nothing under the crystal.
- AREF is 64 mm, 61 mm of it at the board edge; C5 is 2.5 mm from the pin.

**Power: 6**
- Decoupling is the best of the four: 2.1–3.6 mm at every U3 supply pin, C11 1.7 mm from U4.4, C1 5.5 mm and C4 2.7 mm from U1's input.
- The U1 tab has no pour and one via. Its only copper is the pad and 0.9–1.2 mm tracks. At roughly 160 °C/W for a bare SOT-223 footprint the regulator is limited to about 0.5 W: fine for the bare board on 9 V, thermal shutdown with a shield load on 12 V.
- +5V is distributed by tracks. The branch to U4 necks to 0.25 mm, the perimeter run to J5.1 to 0.6 mm, and the VIN header feed is 0.6–0.7 mm.
- USHIELD, the ESD return for RV1/RV2, is 0.2 mm (A uses 0.8–1.27 mm).

**Placement: 6**
- Grouping and decoupling are good, and the power chain J4 → D4 → C1 → U1 → C2 is in a line.
- U3 is at (179, 96) beside J5. That shortens the J5 fan-out but puts it 54 mm from U4.
- The printed legends were not followed:
  - D5 (L) is at (134.5, 89.3); its legend is at (122.4, 90.2).
  - D6 (ON) is at (134.5, 91.5); its legend at (172.6, 97.2) is now under U3.
  - D1 (TX) is at (127, 100.5), below the RX LED, while the TX legend is at y = 95.7.
  - JP2 is at (129.6, 95.6); "RESET-EN" is at (121.1, 118.1).
- RN1, FB2, C18, C5, C7 and C4 sit on the header pin labels, so "20", "21", "SDA", "SCL", "RX1", "TX1", "RX2", "AREF", "IOREF" and "COMMUNICATION" are clipped (69 silk-over-pad warnings against 7–8 on A and B).

**Routing and manufacturability: 7**
- DRC is clean apart from the 4 inherited overlaps; fills are current.
- 986 tracks, 60 signal vias, 60 of 103 signal nets with no via. Widths are consistent (0.2 mm signal, 0.25–1.5 mm power).
- 52 segments are off the 45° grid (53 mm in total) and there are 4 acute junctions.
- PH6 on F.Cu is 0.52 mm from the mounting hole at (163.8, 96.1).
- The silk damage above would need fixing before a production order.

---

## Board D — overall 2

Unfinished and not functional.

**Routing and manufacturability: 1**
- 58 unconnected items on 45 nets, 1149 mm of ratsnest and 50 dangling vias.
- GND and +5V are each in 8 pieces. U3's ground pins 11, 32, 62 and supply pins 10, 31, 61 are open; U4's ground (pins 3, 28 and the exposed pad) is isolated.
- Also open: XTAL1 and XTAL2 (Y1 is not connected), RESET (11 pieces), ADC0–ADC15, SCL, PB5–PB7, and PE0/PE1, the UART link between the two processors.
- 92 silk-over-pad warnings.

**EMI: 2**
- No GND on F.Cu at all; a 782 mm² +5V island on F.Cu and a GND pour on B.Cu that the open nets above never reach.

**Signal integrity: 2**
- U4 is 19 mm from the USB connector. RD+ / RD− are 13.0 / 13.5 mm with 2–3 vias and about 10 mm on B.Cu, 11–12% GND-referenced.
- Y2's traces are 16.8 / 18.3 mm with a via hop.
- D+ and D− from the connector are matched (12.9 / 12.8 mm), the one good point.

**Power: 2**
- Power tracks are 0.5 mm throughout, including the D4 anode.
- U4's nearest +5V capacitor is 18 mm away. C18 is 7.4 mm from AVCC; C8 and C11 are 7.7 and 6.2 mm from their pins.
- The regulator block itself (C4 and C13 2 mm from U1, on a pour) is reasonable.

**Placement: 3**
- The rough zoning is sensible, but the reset switch S1 was moved to (119.5, 122.5) in the middle of the power section, away from its "RESET" legend, and F1/FB1 took its place.
- Y1 is 11–12 mm from U3.

---

## Why this order

1. **B** is complete, DRC-clean, thermally sound, tightly decoupled, and the only AI-style layout that respects the printed legends. Its faults (fragmented back ground, 287 vias, inconsistent widths, a 0.22 mm 3.3 V neck) cost EMC margin and neatness, not function.
2. **C** routes more cleanly and has a better ground than B, but the regulator will overheat under load, the resonator sits over the ADC bus, and the silkscreen mislabels the LEDs and clips pin names. Each is a short fix, but they are faults a customer would see.
3. **A** has a workable overall arrangement, but the worst decoupling of the three complete boards, a regulator output capacitor 79 mm away, 0.10 mm gaps, and a file that fails DRC until it is refilled. C and A are close; C leads on measured ground and decoupling quality and on a clean DRC.
4. **D** cannot work as saved.

## Which board is the human's

**Board A, about 95% confident.** This did not influence the scores.

- No footprint in A is locked. B, C and D each have exactly the 17 locked parts the job describes, so A did not start from the job's input file.
- A's geometry is on an imperial grid: vias 0.9144/0.4064 and 1.1176/0.6096 mm, tracks 0.254, 0.8128 and 1.27 mm, parts at coordinates like (109.792, 94.577). B, C and D use round metric values.
- The board's printed legends (L, TX, RX, ON, RESET-EN) match A's part positions exactly.
- A's MCU sits on fiducial FID4, a spot the job locked and the other three therefore could not use.
- A's zone fills are stale, as from an older file that was converted and never refilled, and it has a dedicated XVCC pour and hand-drawn 45° bus fan-outs.
- B, C and D show agent habits instead: stitching vias on an exact 4 mm grid (C), widths like 0.185 mm with 13 vias on one net (B), and an abandoned route with 50 dangling vias (D).
