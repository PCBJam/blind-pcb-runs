# Layout review: Glasgow rev C3 base board, candidates A, B, C, D

Reviewed 2026-11-20 with KiCad 10.0.8 (`kicad-cli pcb drc`, `pcbnew` Python) and `bt`.
All measurements were made on copies; `/work/boards` is untouched.

## Verdict

| Board | EMI | SI | Power | Placement | Routing / DFM | Overall |
|---|---|---|---|---|---|---|
| **A** | 8 | 9 | 8 | n/a (fixed) | 7 | **8** |
| **B** | 8 | 7 | 8 | n/a (fixed) | 7 | **7** |
| **C** | 4 | 5 | 5 | n/a (fixed) | 4 | **4** |
| **D** | 2 | 2 | 2 | n/a (fixed) | 1 | **1** |

**Ranking: A, B, C, D.**

- **Order A**, after one fix: pull the inner planes back from the board edge (they sit 0.06 mm from it; JLCPCB wants at least 0.2 mm).
- **B is a sound fallback.** It is DRC-clean and has the tidiest power planes, but its differential pairs are not length-matched and it has 29 vias in pads.
- **C should not be ordered as it is.** There is an 88 mm² hole in the ground plane under the FPGA, and vias sit in 9 BGA ball pads and 5 QFN signal pins.
- **D is unfinished.** 153 connections on 79 nets are missing and the saved plane fills are stale.

Placement is identical on all four boards (the job fixed it), so it is not scored.

## The circuit, and what matters in it

- **USB 2.0 high speed:** J1 (USB-C) through U15 (TPD3S014 ESD and current limit) to U1 (FX2, QFN-56), with a 24 MHz crystal Y1.
- **FIFO bus:** D0-D7, RD/WR/OE/PKTEND, FLAGA-D and the 48 MHz CLKIF between U1 and U30 (iCE40HX8K, 0.8 mm BGA-121), plus CLKREF.
- **LVDS:** 13 differential pairs (Z0-Z12) from U30 to J5.
- **I/O banks:** 16 I/Os through 33 Ω arrays, SN74LVC1T45 level shifters and SP3012 TVS arrays to J2/J3.
- **Power:** VBUS, FB1, U15, +5V, then U8 (3V3), U36 (1V2) and two adjustable VIO LDOs (U14/U31) with 0.15 Ω shunts and INA233 monitors on the far side of the board.

## Measured comparison

| Metric | A | B | C | D |
|---|---|---|---|---|
| Unconnected links (KiCad DRC, refilled) | 0 | 0 | 0 | **153 (79 nets)** |
| Copper DRC items beyond the unrouted baseline | 16 hole-to-hole warnings, 1 dangling via | 0 | 0 | 45 dangling tracks, 25 dangling vias, 4 zone-intersect errors |
| Clearance errors in the file as saved | 0 | 0 | 0 | **335 clearance + 199 hole clearance (stale fill)** |
| Vias | 416 | 475 | 672 | 429 |
| Via sizes (pad/drill, mm) | 364 × 0.6/0.3, 46 × 0.4/0.2 | 384 × 0.45/0.2, 23 × 0.4/0.2 | 418 × 0.45/0.2, 252 × 0.4/0.2 | 400 × 0.45/0.2 |
| Vias centred in SMD pads | 8 (test points, DNP R40) | 29 | **40 (9 BGA balls, 5 QFN signal pins)** | 0 |
| Signal track on In1 (ground layer) | 0 mm | 0 mm | **82 mm** | 0 mm |
| Track on In2 (power layer) | 260 mm (mostly 0.45-0.75 mm power) | 51 mm | 390 mm | 125 mm |
| In1 ground cover under U30 | 79 % | 69 % | **26 %** | 87 % |
| In1 ground cover, FX2-FPGA corridor | 85 % | 89 % | 58 % | 85 % |
| +3V3 plane on In2 | 2882 mm², 1 piece | 2351 mm², 1 piece | 1351 mm², **30 pieces** | 5 overlapping zones |
| FIFO + clocks: vias / length with no plane underneath | 18 / 8 % | 18 / 10 % | **61 / 42 %** | incomplete |
| USB: layers, signal-path vias, coupled length | F only, 0, 76 % | F-B-F, 2 per line, 45 % | F only, 0, 65 % | F, 47 % |
| USB P/N length (mm) | 14.12 / 13.03 | 13.55 / 14.23 | 14.74 / 13.43 | 12.24 / 13.32 |
| LVDS pair lengths (mm) | **28.5-29.6** | 14.1-28.5 | 14.6-28.5 | broken |
| LVDS worst intra-pair skew (mm) | 0.65 (12 of 13 pairs under 0.05) | 0.99 | 1.02 | 30.9 |
| +5V trunk width | 0.75 mm | 0.5-0.8 mm plus In2 strip | **0.25 mm** | **0.25 mm** |
| Plane pull-back from board edge | **0.06 mm** | 0.41 mm | 0.26 mm | 0.31 mm |
| Closest signal track to edge | over 1 mm | /ENVB 0.42 mm for 80 mm | /SDA 0.33 mm for 22 mm | /ENVA 0.57 mm |
| GND vias | 121 | 165 | 148 | 154 |
| Outer-layer ground pour | local only | F and B | F and B | none |
| Stackup declared in the file | placeholder 3 × 0.48 mm | placeholder | 0.215 / 1.01 / 0.215 mm | placeholder |

The silkscreen, courtyard and library warnings (about 410 per board) are identical on all four and come from the supplied placement, so they do not affect the comparison.

---

## Board A (overall 8)

Stack use: F signals, In1 solid GND, In2 +3V3 plane with power trunks routed in it, B signals.

### EMI: 8

- In1 is an unbroken ground plane with no tracks on it (3433 mm², one piece, 79 % cover under the BGA).
- 92 % of F.Cu signal length runs over ground.
- No track is within 1 mm of the board edge.
- The USB shell has its own /SHLD copper on all four layers under J1 (x 50-56.8, y 90.7-100.3), with ground kept out. The reset switch shell has the same treatment (/SWSH). This is a deliberate ESD concept; B, C and D tie the shell together with a thin trace.
- All 16 connector I/O nets pass through their TVS pads before reaching the series resistors (1.6-7.1 mm from the connector pin).
- The +3V3 plane is slotted by 260 mm of power track on In2:
  - +5V at 0.75 mm along y ≈ 118.2 from x 64 to 116, then up x ≈ 119 to U14/U31;
  - VIOA/VIOB under the level-shifter columns at x ≈ 97;
  - +1V2 from U36 to the BGA.
- 14 % of B.Cu signal length (221 mm) has no plane beneath it. The nets affected are slow (/ENVB 21.6 mm, /SDA 20.8 mm, /SCL 16.4 mm, /~{ALERT} 12 mm), so the practical risk is low.
- Both planes run to 0.06 mm from the board edge on all four sides, with no pull-back.
- There is no outer-layer pour and 121 GND vias. That is adequate with a solid In1.

### Signal integrity: 9

- **LVDS:** all 13 pairs are tuned with serpentines to 28.5-29.6 mm.
  - Intra-pair skew is 0.05 mm or less on 12 pairs; Z0 has 0.65 mm.
  - Geometry is 0.19 mm width and 0.15 mm gap, 90 % coupled, with at most 2 vias per line.
  - No other board matches pair to pair.
- **USB:** on F.Cu the whole way, over ground, straight through the U15 pads.
  - 76 % coupled at 0.19/0.15.
  - The vias only reach the B-row pins and test points (stubs of about 1.1 mm).
  - The 1.09 mm P/N skew is not compensated, which is harmless at this length.
- **Crystal:** /XTALIN 8.3 mm and /XTALOUT 6.4 mm, no vias, fully over ground.
- **FIFO:** 12 of the 20 FIFO and clock nets stay on F.Cu over ground; the rest use 2 vias each (/CLKREF 4). D0-D7 are 11.4-18.7 mm.
- **Weak spots:**
  - /CLKREF is 36 mm with 4 vias, 17 mm of it on In2.
  - 0.19/0.15 comes to roughly 104 Ω on a standard JLC 7628 stack: right for LVDS, a little high for USB.
  - The file's stackup is a placeholder, so no impedance target is documented.

### Power: 8

- **Input:** /xVBUS 0.45 mm; +5V 0.75 mm from U15.4 to C87 (6.2 mm) and on to the LDOs.
- **Regulators:** hand-drawn pours around U8/U36 for 5V, 3V3, 1V2 and GND (37 mm² on F, 109 mm² on B) spread heat and shorten the cap loops.
- **Shunt chains:** U14/U31 to R7/R56 to R48/R49 are all local pours.
- **+1V2:** 0.75 mm on In2 for 20 mm into an 18 mm² island under the BGA.
- **VIOA/VIOB:** 0.75 and 0.45 mm trunks.
- **Decoupling:** median pad-to-via distance is 0.83 mm (power) and 0.95 mm (ground). The FX2 caps return through the exposed-pad copper on B.
- **Weak spots:**
  - The far LDOs get +5V through a single 0.75 mm trace 80-90 mm long (about 60 mΩ, fine at 0.3 A).
  - C1 and C19 (4.7 µF) have vias 1.7-2.3 mm away.

### Routing and manufacturability: 7

- Clean 45° hand routing: 1 off-angle segment out of 2609.
- Fewest vias (416), mostly 0.6/0.3, with 0.4/0.2 only under the BGA.
- No vias in component pads.
- **Must fix:** the In1 GND and In2 +3V3 fills stop 0.06 mm from the outline (for example x = 50.06 at y = 85, y = 71.06 at x = 90). JLCPCB requires at least 0.2 mm to a routed edge, and the router can expose or smear GND and 3V3 copper.
- 16 hole-to-hole warnings at 0.2002 mm against the board's own 0.25 mm rule, for example at (69.55, 115.95), (93.2, 85.2) and (97.05, 106.95). That is exactly JLCPCB's 0.2 mm minimum.
- One dangling via at (70.61, 113.31) on Net-(R40-Pad1).

---

## Board B (overall 7)

Stack use: F signals plus GND pour, In1 solid GND, In2 split into rail polygons, B signals plus GND pour.

### EMI: 8

- In1 is a solid ground plane (3385 mm², one piece, no tracks).
- In2 is cleanly partitioned with only 51 mm of track on it:
  - +3V3: 2351 mm², one piece;
  - VIOA 167 mm² and VIOB 180 mm² under the shifters and connectors;
  - +5V strip along the bottom;
  - +1V2 from regulator to BGA;
  - a 130 mm² ground island under the USB area, stitched with 9 vias, so the B.Cu part of the USB route sees ground.
- F and B ground pours carry 165 GND vias, including a perimeter row.
- 10 % of signal length is over voids on both outer layers.
- **Ground plane under the BGA is perforated.** 0.45 mm vias with 0.2 mm plane clearance give 0.85 mm antipads on a 0.8 mm grid, so they merge into chains (for example 5.8 × 4.2 mm at 82-87.8, 91.4-95.6). Cover under U30 is 69 %.
- /ENVB runs on B.Cu 0.42 mm from the top edge for about 80 mm (y ≈ 71.5, x 66-114), with /~{ALERT} beside it at 0.73 mm. Both are slow, but they sit at the rim of the planes.
- The USB shell is tied with 0.4 mm traces only (25.8 mm).
- Two I/O nets (bank B Z1 and Z3) reach their TVS on a branch instead of passing through it.
- B.Cu signals cross the 3V3/VIO gaps on In2 (about 60 crossings). The local decoupling caps bridge them, and most are direction lines.

### Signal integrity: 7

- **USB:** each line changes layer twice in its main path.
  - Vias are at (55.75, 95.25) and (62.15, 96.35) for P, and (57.65, 94.75) and (63.9, 97.3) for N.
  - 7.7 mm runs on B.Cu; only 45 % of the length is coupled.
  - The nearest ground via to each signal via is 1.7-2.7 mm away.
  - It will work at 14 mm, but it is the least clean USB route of the three finished boards.
- **LVDS:** good geometry (0.19/0.15, 89 % coupled), but 9 of 13 pairs carry about 1 mm of uncompensated skew, and pair lengths range from 14.1 to 28.5 mm with no matching.
- **FIFO and crystal:** equivalent to A (18 vias, same layer split; crystal nets 7.1 and 6.0 mm, no vias).
- The F ground pour sits 0.2 mm from the pairs, which lowers their impedance a few percent. No stackup is declared.

### Power: 8

- Every rail has a plane or wide trunk:
  - +5V at 0.8 mm to C87, 0.5-0.6 mm to the LDOs, then the In2 strip and 0.6 mm on B to U14/U31 (bottleneck 0.4 mm);
  - +1V2 on an In2 polygon all the way to the BGA;
  - VIO islands directly under their loads.
- Decoupling is the tightest of the four. Every cap ground pad sits in the pour with a via; the median power-pad via distance is 0.66 mm; no BGA power ball is more than 0.6 mm from its via.
- **Weak spots:**
  - /VIO_AUX is 49 mm long (0.3 mm on B, necking to 0.15 mm at the ball).
  - C32, C17 and C54 have their nearest supply via 4.5-6.8 mm away, on 0.3 mm track.

### Routing and manufacturability: 7

- No DRC findings beyond the baseline, saved and refilled.
- All copper is at least 0.4 mm from the edge.
- 29 vias in SMD pads:
  - 0402 decoupling pads under the BGA (C18, C23, C24 and C33 have two each);
  - TSSOP pins U5.2, U5.15 and U19.15 (0.4 mm via in a 0.4 mm wide pad);
  - R7, R56, C87 and LED pads.
  - Unfilled, these wick solder. Acceptable for a prototype; not what I would release.
- 349 of 2300 segments are off the 45° grid. This is cosmetic.
- 407 vias use a 0.2 mm drill. JLCPCB accepts that, but it is tighter than the board needs away from the BGA.

---

## Board C (overall 4)

Stack use: all four layers carry signals; In1 is mostly ground, In2 is a mix of rail polygons and signals; F and B have ground pours.

### EMI: 4

- **There is no ground plane under the FPGA.** 82 mm of signal and power track on In1 encloses the area under U30, and the fill there has dropped out.
  - The hole is 88 mm² (x 77.2-90.8, y 89.6-102.4).
  - In1 ground cover under the BGA is 26 %; In2 cover there is 23 %.
- 42 % of FIFO and clock length and 30 % of FPGA-to-shifter length has no plane on the adjacent layer. Examples: /WR 11.5 mm, /CLKIF 7.7 mm, /CLKREF 15.9 mm across all four layers with 5 vias.
- The +3V3 "plane" is 30 separate pieces (479, 459 and 317 mm² plus fragments), joined only through 0.25 mm tracks.
- A +1V2 branch runs about 90 mm round the board (up x ≈ 59, along y ≈ 75.5 under J5, down x ≈ 88) just to feed PLL filter resistor R32. That is a large loop on a PLL supply.
- /SDA runs 0.33 mm from the bottom edge for 22 mm (x 90-110, y ≈ 119.6).
- By my path trace, about 7 of the 16 connector I/O nets reach their TVS on a branch.
- Credit: F and B pours with 148 GND vias, and a custom rule holding the pour 0.55 mm away from the differential pairs.

### Signal integrity: 5

- **USB:** well done. It stays on F.Cu, and 0.3/0.2 comes to about 90 Ω on the stackup the file declares. 65 % coupled, 1.3 mm skew.
- **LVDS:** 0.22/0.18 comes to about 100 Ω. Intra-pair skew reaches 1.0 mm, pairs are not matched to each other (14.6-28.5 mm), and several lose their reference for 2-3.5 mm near y = 90 on B.
- **FIFO bus:** poor. 61 vias against 18 on A and B; /D0 is 38 mm with 9 vias over four layers; D0-D7 range from 12 to 38 mm.
- C is the only board with a realistic stackup and impedance classes in the project. That intent is undone by the plane damage.

### Power: 5

- Almost every power track is 0.25-0.28 mm, including VBUS (0.28 mm) and +5V to the VIO LDOs (43-54 mm of 0.25 mm through about 6 vias, roughly 90 mΩ). Only the shunt links are wider (0.5-0.55 mm).
- +1V2 reaches the FPGA core through about 25 mm of 0.25 mm track hopping across all four layers.
- The fragmented +3V3 plane and missing ground under U30 raise supply impedance exactly where the fastest part sits.
- Local decoupling is good: median power-pad via distance 0.60 mm, ground pads in the pour.

### Routing and manufacturability: 4

- No DRC findings beyond the baseline, and edge clearance is 0.25 mm.
- **40 vias in SMD pads, including 9 BGA balls and 5 FX2 signal pins.**
  - U30 balls: B4, B8, B9, D9, F9, G6, H10, J7, K4. A 0.4 mm via sits in a 0.35 mm ball pad, often off-centre (for example the via at 81.35, 96.35 in J7 at 81.30, 96.30).
  - U1 signal pins: 21, 23, 24, 35, 37. A 0.4 mm via sits in a 0.28 mm wide pin.
  - This needs filled and capped vias, which JLCPCB only includes by default from 6 layers up. On a standard 4-layer order these joints are a yield risk.
- 672 vias, the most of the four, and many 0.05-0.07 mm jog segments.

---

## Board D (overall 1)

D is not a finished layout and cannot be ordered.

### EMI: 2

- Half-routed nets end in open stubs: 45 dangling tracks and 25 dangling vias.
- LVDS halves are split across layers, and some run up to 19 mm with no plane beneath (/IO_Banks/Z9_N on B at y ≈ 72).
- /ENVA runs 0.57 mm from the top edge for 58 mm.
- In1 itself is the most intact ground plane of the four (3479 mm²), but that does not rescue the board.

### Signal integrity: 2

- /USB_P is not joined to TP15, and /CC2 (J1.B5 to R52) is unrouted, so one plug orientation is not detected.
- FIFO nets /D1, /D5, /D6, /D7, /RD, /WR and /CLKIF are open.
- LVDS intra-pair skew reaches 30.9 mm: /IO_Banks/Z7_P has no track at all, and Z6 and Z8 are only 1-2 mm stubs.

### Power: 2

- Both shunt nets (ISNS_H) and Net-(R6-Pad1) are unrouted, so the VIO rails cannot reach their loads.
- /VIO_AUX does not reach the FPGA.
- +5V, +1V2, VIOA and VIOB are 0.25 mm tracks with no planes; +5V runs about 100 mm at 0.25 mm.

### Routing and manufacturability: 1

- 153 unconnected links on 79 nets. /SCL and /SDA are essentially unrouted (12 links each).
- The plane fills in the saved file are older than the copper. Plotted as saved, there are 335 clearance and 199 hole-clearance violations, which are vias shorted into the GND and +3V3 planes.
- The five +3V3 zones on In2 overlap at the same priority (4 zone-intersect errors).

---

## Which board is the human's

**Board A, about 93 % confident.** This guess was made after scoring and did not change the scores.

- All 13 LVDS pairs are tuned to one target length with serpentines. The other three boards leave pairs at whatever length the route gave.
- The two I/O banks are mirror copies with identical net lengths (the INA233 sense nets are 3.535 and 4.743 mm in both banks).
- Small hand-drawn pours with idiosyncratic settings sit around the regulators and shunts, and there is dedicated shell copper for J1 and SW1.
- 53 tracks are locked; no other board has any.
- 1 of 2609 segments is off the 45° grid, against 139-349 on the others.
- Via sizes are chosen by context (0.6/0.3 generally, 0.4/0.2 under the BGA). B, C and D use near-uniform 0.45/0.2.
- It carries the leftovers of an evolved design: a dangling via beside DNP R40, hole-to-hole warnings, planes drawn to the outline.

The remaining doubt is that an agent could reproduce a published layout.

## Method and limits

- Each board got KiCad DRC with schematic parity twice: on the file as saved and after a zone refill. `bt drc` crashed on B and C, so `kicad-cli` was used directly.
- Plane cover is from rasterising the fills at 0.2 mm; thermal-relief gaps make through-hole rows look slightly worse than they are.
- "No plane underneath" means no zone fill on the adjacent layer (In1 for F, In2 for B), sampled every 0.05-0.1 mm along each track.
- The TVS flow-through counts come from my own connectivity trace. It is reliable for A and B and approximate for C.
- Impedance figures are closed-form microstrip estimates, not field-solver results.
- No board came with its NOTES.md, so the designers' stated intent was not available.
