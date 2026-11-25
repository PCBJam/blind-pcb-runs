# Layout review: m2-pcie-adapter, boards A, B, C, D

Reviewed with KiCad 10.0.8 (`kicad-cli pcb drc`, zones refilled), `bt`, and my own `pcbnew` scripts (in `/work/tools/`). The boards in `/work/boards` were not modified; all work was on copies in `/work/scratch`.

## Result

| Rank | Board | EMI | SI | Power | Placement | Routing / fab | Overall |
|---|---|---|---|---|---|---|---|
| 1 | **C** | 7 | 8 | 8 | n/a | 8 | **8** |
| 2 | **A** | 8 | 9 | 9 | n/a | 6 | **7** |
| 3 | **D** | 9 | 7 | 5 | n/a | 7 | **7** |
| 4 | **B** | 2 | 2 | 3 | n/a | 2 | **2** |

- **Order C as it is**, or order A after adding the M.2 retention notch to the outline. A has the best copper of the four, but as delivered it cannot be screwed down in an M.2 slot.
- **D** is clean and has the best ground system, but feeds the slot's 3.3 V rail through two 0.25 mm tracks.
- **B must not be ordered**: ten ground pads are unconnected and the PCIe pairs are not routed as pairs.
- Placement is not scored: the job fixed it and all four boards have identical footprints.

## What the circuit is, and how I adapted the categories

The board is a passive M.2 Key-M 2280 card (J2, gold fingers on the left edge) carrying PCIe x4 to a Samtec straddle-mount PCIe x4 socket (J1, bottom edge).

- **Fast signals:** eight PCIe data pairs and REFCLK± (net class `Z85_PCIE`, 85 Ω). There is no USB, crystal, regulator or memory bus, so those parts of the categories do not apply.
- **Power:** +3V3 goes from nine J2 fingers to J1 A9/A10/B8 (the PCIe CEM allows 3 A there). +12V goes from J3/J4 to J1 A2/A3/B1–B3 (2.1 A for an x4 slot). +3V3_AUX goes through R1; +5V only links J3.4 to J5.
- **Stack-up (same in all four files):** 0.876 mm total, 0.12 mm prepreg (εr 4.2) outer to inner, 0.51 mm core. F.Cu references In1, B.Cu references In2.
- **Pin geometry forces the topology:** all J2 pair fingers are on B.Cu. J1 "IN" pairs land on B.Cu (2 vias), "OUT" pairs on F.Cu (1 via). All four boards have these via counts.

Impedance, from a 2D field solve of the outer microstrip (my own solver, roughly ±4%):

| Geometry (width / gap) | Used by | File stack-up (0.12 mm) | JLC04081H-3313 (0.0994 mm) |
|---|---|---|---|
| 0.185 / 0.145 mm | A, B, D | ~89 Ω | ~84 Ω |
| 0.218 / 0.147 mm | C | ~84 Ω | ~78 Ω |

Both are acceptable for an 85 Ω ±10% target.

## Findings common to all boards

- **DRC:** every board shows the same 20 `lib_footprint_issues` warnings (missing `antmicro-footprints` library). They are not layout defects.
- **Retention half-hole:** the outline's right edge is one straight segment (186.200,109.513 → 186.215,87.667). There is no notch in Edge.Cuts, although mask openings (Ø4.1 mm at 186.19,98.76 on both sides) mark where the M.2 screw goes. A plated Ø3.5 mm hole centred on the edge is the only way to get the notch without editing the outline. C and D have it; A and B do not.
- **Small drills:** every board uses 0.25 mm drills (A 91, B 155, C 96, D 47). This is within JLCPCB capability, but check the price class when ordering.
- **Order options:** 0.8 mm thickness, ENIG and finger bevel are needed. Only C records ENIG in the stack-up.
- **Vias:** no vias in SMD pads, and all ordinary vias are tented, on every board.

## Board C: rank 1, overall 8

**EMI: 7**
- In2 is one unbroken GND plane (2095 mm², 1 island). Every B.Cu pair segment runs over it.
- In1 is split three ways: GND (1286 mm², 5 pieces), +3V3 (507 mm²) and +12V (188 mm²). The +3V3/GND boundary is a diagonal that runs just beyond the staircase of signal vias, from about (118,91) to (136,109).
- All F.Cu pair segments measure over GND; only 1.1–2.2 mm per pair is off-plane, at the via antipads. The split is close to the layer transitions, though.
- Only slow nets cross the In1 split: PWRGD and WAKE# on F.Cu near (115.5,91–100).
- In1 has no copper at all under the J2 fingers (x < 110).
- No outer GND pours, so no slivers but no shielding either. 61 GND vias; every pair via has a GND via within 1.16 mm (REFCLK 1.5 mm).

**SI: 8**
- Nine pairs at 0.218/0.147 mm. Intra-pair skew is 0.000 mm on every pair.
- Coupled for 77–83% of the length; the 5.5–8.1 mm uncoupled is connector fan-out.
- Lane lengths are 36.26–37.97 mm. Neighbouring pairs are 0.70 mm centre to centre (0.48 mm edge gap, about 2.2 trace widths), the tightest of the three good boards.
- Solid plane under the 0.7 × 4.2 mm J1 signal pads (about 0.9 pF per pad by parallel-plate estimate) with no relief.
- A `.kicad_dru` enforces width 0.218 mm and skew ≤ 0.1 mm for the class.

**Power: 8**
- +3V3: nine 0.34 mm finger stubs (2.6 mm) into two small F.Cu pours, then 10 vias (0.65/0.3) into the In1 plane, then 6 vias (0.74/0.35) at (139.2–141.2, 114.8/115.7) and 0.68 mm tracks into J1 A9/A10/B8.
- +12V: stacked F.Cu and In1 pours (188 mm² each), 4 vias at J4, 6 vias (0.75/0.35) at J1, 0.68 mm into each pin.
- +5V is 1.4 mm; +3V3_AUX is 0.46–0.55 mm.
- Decoupling: most cap pads reach a via within 0.63–0.96 mm; C8.1, C9.1 and C5.1 are at 1.46–2.61 mm.

**Routing / fab: 8**
- DRC: 0 errors, 0 unconnected.
- The half-hole is present: a GND via 4.2/3.5 mm at (186.207,98.760), waived by a custom edge-clearance rule. Its annular ring is only 0.35 mm inside a Ø4.1 mm mask opening, so the screw head gets little copper to land on. A larger land (D uses Ø5.5 mm) would be better.
- 125 vias in eight sizes (0.5/0.25, 0.56/0.25, 0.6/0.3, 0.65/0.3, 0.7/0.3, 0.74/0.35, 0.75/0.35, 4.2/3.5) and many odd track widths (0.32–0.68 mm). This is harmless for the fab but needlessly varied.
- No acute angles. The plated half-hole must be called out when ordering.

## Board A: rank 2, overall 7

**EMI: 8**
- In1 is a full GND plane (2051 mm², 1 island).
- In2 is GND (1378 mm²) plus a +3V3 island (156 mm², x 136.3–143.6) and a +12V island (479 mm², x 144.4–181.8). Both islands are clear of every pair.
- GND pours on F.Cu and B.Cu with 0.5 mm clearance, and 115 GND vias. There are via rows between the F.Cu vertical pairs at y ≈ 106.3, 110.2 and 112.7.
- GND return via within 0.95–1.43 mm of each data pair via (REFCLK 1.8 mm).
- The F.Cu GND pour is cut into 25 pieces by the pairs. DRC shows all connected, but the narrow strips between pairs depend on their stitching.

**SI: 9**
- Nine pairs at 0.185/0.145 mm, skew 0.000 mm, coupled for 76–83%.
- Each pair is 0.6 mm longer on one leg on F.Cu and 0.6 mm shorter on B.Cu. The skew is corrected on the other layer rather than where it arises (about 4 ps mid-route).
- Neighbouring pairs are 0.73 mm centre to centre (0.55 mm edge gap, about 3 widths).
- Lane lengths 34.66–40.08 mm, not matched across lanes; PCIe does not need that.
- The only board that relieves the connector pads: plane cut-outs of 1.9 × 5 mm under each data pair's J1 pads (In1 for the F.Cu-side pads, In2 for the B.Cu-side pads) and an In2 cut-out under the J2 fingers (x 106.0–108.85, y 89.95–103.1). The other boards leave about 0.9 pF per J1 pad. The sizes are not backed by a simulation, and REFCLK's pads have no cut-out.

**Power: 9**
- +3V3: F.Cu pour of 537 mm² runs directly from J2 to J1, plus In2 (156 mm²) and B.Cu (20 mm²) pours and 13 vias. Each J2 finger gets a 0.30–0.35 mm stub about 1.85 mm long.
- +12V: F.Cu 478 mm², In2 479 mm², B.Cu 56 mm², 28 vias.
- +5V 1.0 mm; +3V3_AUX 0.4 mm.
- Decoupling: caps sit in the pours with vias at 0.85–1.5 mm (C8.1 2.1 mm, C5.1 2.95 mm).

**Routing / fab: 6**
- DRC: 0 errors, 0 unconnected. 189 vias (0.6/0.3 × 98, 0.5/0.25 × 91). One 76° junction on GND at (144.0,115.05).
- **Must fix before ordering: there is no retention half-hole.** There is neither a notch nor a hole at (186.2,98.76), only exposed GND pour in the mask opening. As fabricated, a 2280 card with a flat end cannot take the M.2 screw.
- The fix is a Ø3.5 mm notch or plated hole on the edge. It does not disturb any signal copper.

A is ranked below C only because of this blocker. With the notch added it is my first choice.

## Board D: rank 3, overall 7

**EMI: 9**
- In1 and In2 are both complete GND planes (2100 mm² each, 1 island each, no splits).
- Every pair segment on both outer layers is over GND; only 1.2–2.5 mm per pair is off-plane, at the via antipads.
- A GND via sits within 0.84–1.38 mm of every signal via, in a neat staircase.
- Power is on F.Cu pours directly over the In1 plane.
- The retention half-hole is a Ø5.5 mm GND land tied to J3's GND pin with a 1.5 mm B.Cu track.
- Only 52 GND vias and no outer pours, which is fine with two solid planes.

**SI: 7**
- Best basic pair work: 0.185/0.145 mm, coupled 78–85%, skew 0.000 mm, per-layer mismatch at most 0.28 mm. Neighbouring pairs are at least 0.79 mm centre to centre (0.61 mm gap).
- All IN lanes and REFCLK are tuned to 44.431 mm and all OUT lanes to 45.27 mm using tight serpentines on F.Cu (x 118–133, y 100.4–107.4). There are 216 arcs, inner radius 0.15–0.18 mm, lobe pitch about 0.65 mm.
- PCIe tolerates nanoseconds of lane-to-lane skew, so this matching buys nothing. It adds 6–10 mm per lane and puts each trace's own legs about as close together as the pair gap.
- Solid plane under the J1 pads, no relief.

**Power: 5**
- +3V3: the F.Cu pour (248 mm²) ends at about (141,103.7). From there the whole slot rail goes through three vias onto 0.25 mm B.Cu tracks.
  - 139.21,103.14 → J1.A10: 15.7 mm.
  - 140.20,103.14 → C4 → C8 → C3 → J1.A9: about 15 mm. J1.B8 hangs off this chain through one 0.55/0.25 via at (140.84,114.98).
- That is two 0.25 mm tracks in parallel for up to 3 A: about 31 mΩ each, and roughly 1.8 A total for a 10 °C rise by IPC-2221. The +3V3 decoupling caps sit on the same thin chain.
- +12V: F.Cu pour of 217 mm², then one 0.4 mm × 8.6 mm track per J1 pin (five in total). Adequate at 0.42 A per pin, but lean.
- +3V3_AUX 0.25 mm; +5V and the J3 feed 1.5 mm.
- The +3V3 pour uses thermal reliefs (0.508 mm spokes) on SMD pads.

**Routing / fab: 7**
- DRC: 1 error, `copper_edge_clearance` at the half-hole via (186.190,98.760, 5.5/3.5). It is intentional, but the exclusion in the project file no longer matches, so the report is not clean.
- Fewest vias (92).
- Leftovers: two zero-length segments (+3V3 at 139.21,103.14 and +12V at 146.21,110.22), seven overlapping duplicate segments, and two tracks that double back on themselves (+12V at 146.01,110.17 and GND at 137.05,113.59).
- A GND track on B.Cu ends 0.23 mm from the edge at (185.23,98.76); it is part of the half-hole connection.
- The plated half-hole must be called out when ordering.

## Board B: rank 4, overall 2

**EMI: 2**
- Ten GND pads are not connected (`kicad-cli`: 9 unconnected items):
  - J2 fingers 9, 21, 27, 33, 39, 45, 51 — the ground fingers between the PCIe pairs.
  - J1 A15, A27, A28.
- The J2 ground fingers that are connected are 4.35–10 mm from the nearest GND via.
- In1 has no plane left of x ≈ 111.5 and is cut up by signal tracks.
- Pairs run over voids for long stretches: Data_0_IN has 24.8 mm of B.Cu with no In2 copper beneath; Data_1_OUT has 29.2 mm of F.Cu over void.
- Signal vias are up to 8.2 mm from a GND via.
- The 155 stitching vias on a 3 mm grid are in the empty right half of the board, not where the signals change layer.

**SI: 2**
- The pairs are not routed as pairs. Nearly every pair is uncoupled for its full length (Data_0_OUT 33.9 of 33.9 mm with gap > 0.25 mm; REFCLK 34.7 of 34.7 mm).
- Pair halves are on different layers: Data_1_IN_P on B.Cu + In1, Data_1_IN_N on B.Cu + In2. Data_1_OUT_N has an extra via and an In1 detour that _P does not; Data_2_OUT_P has 19.9 mm on In2 against 11.0 mm for _N.
- "Skew ≈ 0" is achieved with single-ended serpentines, for example on In1 at x ≈ 117.5–118.5, y 109–114.
- Data_3_IN and Data_3_OUT run 0.33 mm centre to centre on In1 (0.145 mm edge gap). The receive and transmit pairs of one lane are coupled to each other.
- Only the two lane-3 pairs are partly coupled, at 37% and 33% of their length.

**Power: 3**
- No power planes.
- +3V3: the top finger group enters through one 0.6/0.3 via at (111.41,89.21), then runs as a single 0.6 mm B.Cu track of about 37 mm to J1 ((113.61,89.31) → (121.86,97.56) → (130.77,106.47) → (138.00,106.47) …). That is about 30 mΩ and roughly a 39 °C rise at 3 A.
- The lower finger group takes three more single vias and an In1 hop. Some fingers are chained with 0.18 mm links.
- +12V: one 0.8 mm × 36 mm B.Cu track (about 2 A for a 10 °C rise) and one via at (146.51,115.66) feeding J1 B1–B3.
- +5V is 0.5 mm.
- Cap power pads are 1.7–4.6 mm from a via.

**Routing / fab: 2**
- Fails connectivity. 199 vias.
- Five acute junctions, including 18° on GND at (122.97,115.81).
- Pours on all four layers run 0.2 mm from the edge; F.Cu +3V3 copper is 0.24 mm from the edge at (109.81,89.21).
- No retention half-hole.

## Ranking reasons

1. **C** — the only board with no blocking defect: clean DRC, pairs correct, plane-fed power, retention hole present. Its weaknesses are second-order: three-way In1 split near the transitions, no pad relief, thin half-hole land, a zoo of via sizes.
2. **A** — best signal, power and stitching work, and the only one with connector pad cut-outs. It is held back only by the missing retention notch, which is a blocker as delivered but a one-shape fix.
3. **D** — best ground system and tidiest pair routing, but the 3.3 V neck is the one real electrical under-design among the three good boards, and the serpentines add loss for no benefit. It ties A on score; I put A ahead because its copper is better and both need one fix.
4. **B** — open ground pins, uncoupled and layer-split pairs, single-track power. Not orderable.

## Which board is the human's

**D, about 90% confident.** This guess did not influence the scores.

- D's half-hole via carries a legacy-format UUID (`00000000-0000-0000-0000-00005e6a5dd9`) and sits at an off-grid position (186.190009, 98.759778).
- The project's old DRC exclusion marker (186.207332, 98.759790) is exactly the perpendicular foot of that via onto the slightly slanted board edge. So D's via is the one the exclusion was originally written for.
- C has a via with the same UUID placed exactly on the marker coordinate, plus a custom rule to waive it. That looks reverse-engineered from the project file.
- D's pours use KiCad's GUI default values (0.508 mm clearance, 0.254 mm minimum width, 0.508 mm thermals), and it has one zone spanning In1 and In2.
- The serpentines with arcs look like the interactive length tuner.
- None of D's 92 vias is on a 0.01 mm grid (A: 123 of 189; B and C have a few).
- The zero-length and duplicate segments are typical hand-editing leftovers.
- A, B and C look scripted in different ways: round-number coordinates, uniform parametric via fences, or generated size variety.
