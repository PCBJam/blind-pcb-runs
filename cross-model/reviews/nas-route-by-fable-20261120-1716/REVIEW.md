# Layout review: RaspberryPiNVMeNAS, boards A–D

## Verdict

**Ranking: B, C, A, D.** None of the four should be ordered exactly as it is.

| Board | EMI | SI | Power | Placement | Routing / fab | Overall |
|---|---|---|---|---|---|---|
| B | 8 | 6 | 7 | n/a | 6 | 7 |
| C | 7 | 7 | 7 | n/a | 5 | 6.5 |
| A | 6 | 7 | 5 | n/a | 5 | 5.5 |
| D | 2 | 2 | 2 | n/a | 1 | 2 |

Placement is not scored: the job fixed it, and all four files have identical footprint positions and pad nets.

- **B** is the one to order after three short fixes: remove the meander on `PCIe_RX_N_3`, strengthen the +5V feed to the CM4, and pull copper back from the board edge.
- **C** is a tidy, complete board with no electrical show-stopper, but it runs PCIe pairs 0.42 mm from the wall of seven mounting holes on the bottom side.
- **A** is complete and has well-planned pair impedances, but its outer-layer power pours are cut up by signals, leaving single-via choke points and two regulators whose input loop goes through a via.
- **D** is not finished: 23 real open connections, including a regulator switch node and three feedback dividers.

## How I measured

All work was done on copies; the files in `/work/boards` are unchanged. None of the boards came with a NOTES.md, so I could not check the designers' stated intent.

- **DRC**: KiCad 10.0.8, each project's own rules, as saved and again after a zone refill. Then a second run with one common rule set (copper to edge 0.2 mm, copper to hole 0.2 mm) so the boards can be compared.
- **Reference plane**: every signal track sampled every 0.1 mm; F.Cu is checked against In1, B.Cu against In2.
- **Pairs**: length, skew, edge-to-edge gap, vias and nearest GND via for 23 pairs (15 PCIe, 4 USB, 4 Ethernet).
- **Voltage drop**: a resistive grid solve of each rail's copper (35 µm outer, 17.5 µm inner, 18 µm via barrels). Assumed loads: 6 A on 12 V, 3 A to the CM4, 3 A per M.2 slot, 1.2 A on 1V2, 0.25 A per fan. Treat the numbers as comparative.
- **Impedance**: closed-form microstrip estimates, good to about ±10 %, ignoring the effect of same-layer pours.
- **Mounting holes**: I assume a screw head or nut of about 2.25–2.5 mm radius on the bottom side of H1–H12 (2.7 mm holes, top-only pads).

Findings common to all four and not counted against any board: 17 `footprint_type_mismatch` errors, 199 silkscreen text-height warnings, 8 silk overlaps, 9 silk-over-copper, 9 courtyard overlaps and 6 silk-at-edge warnings. They come from the footprints and the fixed placement; nobody touched the silkscreen.

## Key measurements

| | A | B | C | D |
|---|---|---|---|---|
| Unconnected items (KiCad) | 0 | 0 | 0 | 29 (23 real, 6 are USB shell pads) |
| DRC errors beyond the common ones | 0 | 19 `zones_intersect`; 40 zone clearance errors in the saved fill, gone after refill | 0 | 1 dangling via |
| Tracks / vias | 2517 / 945 | 2212 / 1049 | 2708 / 756 | 2017 / 599 |
| Via sizes | 11 sizes, 3 drills | 0.45/0.2 (1035), 0.5/0.3 (14) | 0.6/0.3 (402), 0.45/0.2 (354) | 0.45/0.2 (528), 0.6/0.3 (71) |
| GND vias | 330 | 802 | 522 | 197 |
| In1 | solid GND | solid GND | solid GND | solid GND |
| In2 | GND with a 2.4 mm × 162 mm +5V trunk and a +5V island | GND with 1V2, 3.3VA, 3.3VSTB islands | GND with 5V, 1V2, 3.3VSTB islands | power islands only, rest empty |
| Outer-layer GND pour | yes, 119 pieces on F.Cu | yes, 7 pieces on F.Cu | yes, 71 pieces on F.Cu | none |
| Signal length not over GND | 7.7 % | 9.0 % | 5.5 % | 54 % |
| PCIe length not over GND | 2.1 % | 4.8 % | 2.7 % | 66 % |
| Worst PCIe intra-pair skew | 0.03 mm | 8.79 mm (slot 3 RX) | 0.17 mm | 9.97 mm (slot 4 RX) |
| PCIe uncoupled length per pair | 0.4–11.9 mm | 0.0–2.3 mm | 0.8–9.5 mm | 0.3–38.5 mm |
| GND via next to PCIe pair vias | 0.7–1.4 mm | 0.6–0.9 mm | 0.8–5.1 mm | 0.8–11.6 mm |
| 12 V drop to worst buck | 81 mV | 33 mV | 72 mV | 32 mV |
| 5 V drop to CM4 at 3 A | 30 mV | 192 mV | 38 mV | 19 mV |
| 3.3 V drop to worst M.2 slot at 3 A | 26 mV | 16 mV | 14 mV | 17 mV |
| Highest single-via current | 4.4 A (12 V) | 3.0 A (5 V, 0.2 mm drill) | 1.05 A | 4.15 A (5 V) |
| Min copper to board edge | 0.25 mm | 0 mm (all four layers) | 0.3 mm | 0 mm (In1), track at 0.03 mm |
| Odd-angle routing (share of length) | 68 % | 0 % | 2 % | 2 % |
| B.Cu nets passing under 2.25 mm from a mounting-hole centre (hole/net cases) | 7 | 0 | 17 | 9 |

Stackups in the files: A declares 0.135 mm prepreg (εr 4.5), C declares JLC04161H-3313 with ENIG and impedance control, B and D keep KiCad's default 3 × 0.48 mm, which is not a real build.

Estimated differential impedance of the pair geometry actually drawn:

| Geometry (width / gap, mm) | On the board's own stackup | On JLC 7628 (0.21 mm) | On JLC 3313 (0.10 mm) |
|---|---|---|---|
| A PCIe 0.20 / 0.15 | 88 Ω | 101 Ω | 81 Ω |
| A refclk 0.16 / 0.19 | 102 Ω | 117 Ω | 95 Ω |
| A USB 0.19 / 0.16 | 91 Ω | 105 Ω | 85 Ω |
| B PCIe to slots 0.127 / 0.20 | not defined | 128 Ω | 107 Ω |
| B PCIe to CM4, USB, Ethernet 0.20 / 0.20 | not defined | 108 Ω | 85 Ω |
| C PCIe and USB 0.15 / 0.15 | 95 Ω | 113 Ω | 95 Ω |
| C Ethernet 0.127 / 0.20 | 107 Ω | 128 Ω | 107 Ω |
| D PCIe 0.35 / 0.25 | not defined | 87 Ω | 63 Ω |

## Board B: overall 7

### EMI: 8
- In1 is one unbroken GND plane. In2 is GND apart from three local islands (1V2 and 3.3VA around U12, 3.3VSTB around U18).
- 802 GND vias; 60 % of 5 mm board cells hold one, and 69 % of the board edge has one within 4 mm.
- Every PCIe pair layer change has GND vias 0.6–0.9 mm away and an oval plane cut-out around the pair vias.
- All seven buck regulators have VIN, switch node, output and GND as pours on the top layer. The input capacitors reach the VIN and GND pins on F.Cu, with 1–4 GND vias per capacitor.
- All four layers are voided under the RJ45 (86.2–105.2, 54.8–79.8). The Ethernet pairs therefore run 15 % of their length (3–7.7 mm each) with no reference.
- PCIe pairs on B.Cu cross from GND onto the 3.3VA island on In2: `PCIe_RX_P_4` for 6.6 mm at (176.4–182.9, 130.8), `PCIe_RX_P_3` for 4.3 mm at (163.7, 124.3–128.6), `PCIe_RX_P_2` and `PCIe_TX_P_2` for 2.4–3.4 mm near (166–173, 111.7–113.6). The 3.3VA decoupling capacitors are close, which softens this.
- The GND fills on all four layers and the 3.3VSTB island on In2 run to the board edge on the east and south sides.

### SI: 6
- `PCIe_RX_N_3` is 109.97 mm and `PCIe_RX_P_3` is 101.18 mm: 8.79 mm of skew, about 55 ps or a quarter of a unit interval at 5 GT/s. The cause is a seven-bump meander on the N leg only, on B.Cu around (158–164, 128–130). Every other PCIe pair is within 0.04 mm.
- Coupling is the best of the four: 0.0–2.3 mm uncoupled per pair, two vias per pair, CM4 TX and the upstream clock with no vias.
- The 12 downstream pairs are 0.127 mm wide with a 0.2 mm gap and no stackup is defined. That is about 107 Ω on JLC 3313 and about 128 Ω on JLC's default 7628 build, against an 85–100 Ω target.
- Ethernet intra-pair skew is 1.6–3.8 mm (`ETH_P1` 39.40 / 43.17 mm). Acceptable for 1000BASE-T, but not matched.
- USB to the CM4 is 51.1 mm on F.Cu, no vias, 0.04 mm skew, all over GND. QSPI and crystal nets have no vias and sit over solid GND.

### Power: 7
- Regulator layout is the best of the four, as above. No switch-node or feedback net leaves the regulator area.
- 12 V is a 594 mm² pour on F.Cu: 33 mV worst-case drop and no current through vias.
- M.2 3.3 V rails are top-layer pours from inductor to connector: 15–16 mV at 3 A.
- **The CM4's +5V is the weak point.** It is a 0.8 mm track roughly 100 mm long that passes through two single 0.45/0.2 mm vias in series, at (122.625, 105.525) and (117.85, 110.15), to hop under the USB pair. At 3 A that is 192 mV of drop and the full current in each 0.2 mm barrel. The fans see 130 mV.
- U12 has 13 vias in its exposed pad, U3 has 5.

### Routing and manufacturability: 6
- Clean 45° routing, no odd angles, 4 acute corners, 92 % of vias on a 0.05 mm grid, buses bundled in order.
- No B.Cu track is closer than 2.45 mm to a mounting-hole centre.
- Edge clearance is set to 0 in the project, so copper reaches the routed edge on all layers, including a power island. The fab will either clip it or query it.
- 19 `zones_intersect` errors: overlapping same-net zones with equal priority (+12V, +3.3V_Mx, GND, +1V2, +3.3VA). Harmless electrically, but the DRC is not clean.
- GND fill touches 62 unplated holes and 3.3VSTB touches 2 (hole clearance is 0).
- 1035 vias use a 0.2 mm drill, which is within JLCPCB's 4-layer capability but below the usual 0.3 mm standard and may add cost.
- No net classes and no stackup; widths were chosen by hand from the project's preset list.

## Board C: overall 6.5

### EMI: 7
- In1 is solid GND. In2 is GND with +5V (483 mm², under the CM4), 1V2 and 3.3VSTB islands.
- No fast pair crosses an island. `SD_CMD` runs 8.9 mm over the +5V island at (96.7–102.9, 123.1–129.3).
- 522 GND vias on a regular 4 mm grid: 62 % cell coverage, 71 % of the edge.
- PCIe pair layer changes have no dedicated return via. The nearest GND via is typically 1.4–2.7 mm away and 4.5–5.1 mm for slot 3 TX. Both reference planes are GND, so this is a weakness, not a fault.
- Regulator GND pins and input-capacitor GND pads are not joined on the top layer; each returns through a single via to In1.
- The RJ45 pin antipads merge into one 14.0 × 5.1 mm slot in In1 at (95.6, 73.1).
- Copper is held 0.3 mm from the edge and at least 0.15 mm from every hole.

### SI: 7
- Every PCIe, Ethernet and CM4 USB pair is matched within 0.17 mm.
- Pair geometry follows the declared JLC 3313 stackup: about 95 Ω for PCIe and USB, 107 Ω for Ethernet. PCIe is a little high against 85 Ω but in tolerance for a 5 GT/s link.
- Two vias per pair at most; 5–9.5 mm of each PCIe pair is uncoupled around the AC capacitors and fan-outs.
- Each slot's RX pair passes mounting holes on B.Cu with the N leg over the In2 antipad for 1.7–1.8 mm, twice per pair, for example `PCIe_RX_N_3` at (141.8, 90.9–92.6) and (141.8, 102.9–104.6).
- SD lines differ by 23 mm (`SD_CLK` 53.0 mm, `SD_CMD` 29.8 mm). Fine at 50 MHz, but nothing was matched.

### Power: 7
- No choke points: the highest via current is 1.05 A, on the CM4's +5V, which enters through three 0.6/0.3 vias from the In2 island (38 mV at 3 A).
- 12 V is a pour on F.Cu plus 0.4–0.8 mm links: 72 mV worst case.
- M.2 rails 14 mV, 1V2 7 mV, 3.3VA 4 mV.
- Fans and the standby LDO are fed by a 0.6 mm track about 100 mm long: 84–95 mV at the assumed load.
- Regulators: VIN reaches the input capacitors on top copper (0.2–0.3 mm neck), the switch node is a 0.3 mm track for 2.5 mm, feedback nets are 2.5–3.4 mm with no vias.
- U3 (the 12 V hot-swap switch) has no vias in its exposed pad. U12 has 9.

### Routing and manufacturability: 5
- DRC is clean against rules stricter than the other boards use (0.15 mm clearance, 0.3 mm edge, 0.15 mm hole).
- Stackup, ENIG finish and controlled impedance are recorded in the file, and net classes exist for PCIe, USB, Ethernet and power.
- **Tracks under mounting hardware.** On B.Cu, `PCIe_RX_N_1..4` pass 1.77 mm and `PCIe_RX_P_1..4` 2.07 mm from the centres of H5, H7, H8, H9, H10, H11 and H12. That is 0.42 mm from the hole wall. `TSENSE_2` is 1.70 mm from H10, `CM4_EN` 1.85 mm and `CM4_BOOT` 2.16 mm from H3. A screw head or nut would sit on these traces with only solder mask between them.
- Vias inside 0402 pads at C83.2 and R70.2, and inside C1.2 and C2.2.
- 44 acute corners, mostly GND stubs into pads.

## Board A: overall 5.5

### EMI: 6
- In1 is solid GND. Every fast pair stays over GND, and each pair via has a GND via 0.7–1.4 mm away.
- In2 carries a 2.4 mm +5V trunk for 162 mm (from about (113, 90) round to (215, 88)), which slots the In2 GND plane along its whole length. Only slow nets cross it: `CM4_BOOT`, `CM4_RST`, `M2PWR_EN`, `TSENSE_0/2/3`, `PICO_PWM4`.
- SD lines run 5.3–5.6 mm over the +5V island on In2 near (88–94, 124–130).
- Power is distributed as pours on F.Cu and B.Cu, and the signals cut them up. F.Cu GND is in 119 pieces: 17 of them over 2 mm² hang on one via or none, and 42 are slivers under 1 mm².
- Stitching is the sparsest of the complete boards: 330 GND vias, 33 % cell coverage, 20 % of the edge.
- U10 and U14 have their input loop routed through vias (see Power).

### SI: 7
- All PCIe pairs are matched within 0.03 mm, Ethernet and CM4 USB within 0.01 mm.
- Pair geometry is set per class and is consistent with the declared stackup: PCIe 88 Ω, reference clocks 102 Ω, USB 91 Ω, Ethernet 101 Ω. The 0.135 mm prepreg is not one of JLCPCB's stock values as far as I know, so the build needs confirming with the fab.
- Reference clocks for slots 1–3 and from the CM4 run on F.Cu with no vias.
- Slot 2 RX and slot 3 TX have four vias per net; `ETH_P1` and `ETH_P3` have up to four vias and 11–12 mm uncoupled.
- `/QSPI_SD3` uses four vias and an In2 segment for a 7 mm connection.
- `PCIe_TX_P_1` on B.Cu is 1.73 mm from the centre of H7 and 2.15 mm from H11.

### Power: 5
- Voltage drops are fine: 12 V 81 mV, CM4 30 mV, M.2 rails 8–26 mV.
- **12 V choke point.** Signals split the +12V pours on both outer layers near (147, 82). All current for the eastern loads, 4.4 A in my model, passes through two vias at (146.91, 81.22) and (147.74, 81.44) and then one 0.62/0.3 via at (147.35, 82.85).
- **U10 input loop.** `M2PWR_EN` runs at y = 77.15 between U10 and its input capacitors C18 and C20, cutting the +12V pour. U10 pin 1 is fed by a 0.135 mm stub from a 0.43/0.2 via placed in the pin pad at (194.495, 76.65). U14 pin 1 is similarly fed through one 0.47/0.25 via at (149.3, 76.66), and C47 has no top-layer path to it.
- Other single-via feeds: 1V2 carries its full 1.2 A through one 0.47/0.25 via at (165.14, 99.1); 3.3VA passes 0.6 A through four single vias in series; +3.3V_M1 passes 2 A through one via at (195.45, 65.18).
- Each regulator GND pin and each input-capacitor GND pad has one via and no top-layer GND connection.
- U12 has 10 vias in its exposed pad, U3 has 4.

### Routing and manufacturability: 5
- DRC clean, nothing unconnected, edge clearance 0.25 mm.
- 68 % of routed length is at arbitrary angles, with 47 acute corners. This works electrically but is hard to review and to edit.
- Eleven via sizes on three drills.
- Vias in fine-pitch pads: U10.1 (0.43 mm via on a 0.30 mm pad), J7.A6 (USB-C D+), C85.1.
- Zone copper touches 78 unplated holes, including +5V and all four +3.3V_Mx rails at the M.2 connector pegs.
- GND zones connect solidly to through-hole pads on all four layers (DC jack, fan and sensor headers), which makes hand soldering and rework hard.
- B.Cu tracks under mounting hardware: `TSENSE_3` 1.70 mm from H11, `TSENSE_0` 1.68 mm from H6, `PCIESWPWR_EN` 1.70 mm from H7, `M2PWR_EN` 2.02 mm from H12.

## Board D: overall 2

### EMI: 2
- In1 is a solid GND plane; that is the only return-path provision. There are no GND pours on the outer layers and no GND at all on In2.
- In2 holds rectangular power islands. B.Cu signals therefore run over 12 V, 5 V, 1V2, 3.3 V or nothing: 54 % of all signal length and 66 % of PCIe length has no adjacent GND. Examples: `PCIe_CLK_P` 28.1 mm over bare In2 at (127–155, 113.2); the Ethernet pairs 23–25 mm over the +5V island at (95–100, 82–107).
- 197 GND vias; pair vias are up to 11.6 mm from the nearest one.

### SI: 2
- Most pairs are not routed as pairs. Median gap is 17.1 mm on slot 2 RX, 16.2 mm on slot 2 CLK, 6.5 mm on slot 4 TX.
- Skew: 9.97 mm on slot 4 RX, 4.90 mm on slot 1 TX, 9.89 mm on `ETH_P1`.
- PCIe is drawn 0.35 mm wide, about 87 Ω only on a 0.21 mm prepreg, with no stackup defined.
- The RP2040 USB D− is open (`USBpico_DN` at J15.A7 and `Net-(R60-Pad2)` between U18.46 and R60.2), as is `Net-(J7-PadA7)` at J7.
- A foreign net (`PCIESWPWR_EN`) runs 3.5 mm under the crystal on F.Cu, and the crystal net has two vias.

### Power: 2
- U2's switch node (`Net-(C10-Pad2)`: U2.2, L2.1, C10.2) is not routed, so there is no 1V2 rail.
- The GND pads of R6, R32 and R35, the lower feedback resistors of U2, U10 and U11, are open.
- The other switch nodes are 0.15 mm tracks carrying inductor current.
- +12P from the DC jack to U3 is a single 0.6 mm track, 15.7 mm long, for the whole board's input current (39 mV at 6 A).
- Single-via feeds: 4.15 A of +5V at (119.4, 81.05), 3.0 A each on +3.3V_M2/M3/M4 through 0.45/0.2 vias, 3.35 A of +12V at (126.15, 72.17).
- +3.3VA does not reach U12 pins 1, 10, 32, 38 and 56; +1V2 does not reach U12 pin 64. There are no thermal vias under U12 or U3.

### Routing and manufacturability: 1
- 29 unconnected items. Besides those above: `CM4_RUN`, `PICO_PWM1`, `TSENSE_2`, `Net-(R24-Pad2)`, a +3V3 link, +3.3V_M1 at R20.1, and a GND link between U8 and U9.
- A +12V track on B.Cu is 0.03 mm from the J6 slot edge at (120.2, 60.1), and the In1 GND plane runs to the board edge.
- Tracks 0.02–0.07 mm from unplated holes, for example `PCIe_RST_M2` and +3.3V_M1 at the J2/J3 pegs.
- One dangling via on `CM4_BOOT` at (165.0, 130.65).

## Ranking and reasons

1. **B.** The best ground system, the best regulator layout and the most disciplined routing. Its faults are few, specific and quick to fix: one meander, one supply trunk, the edge clearance, and a stackup that must be chosen so the 0.127 mm pairs land near 100 Ω (JLC 3313, not the default 7628).
2. **C.** Complete, DRC-clean and electrically sound everywhere I measured, with matched pairs and a documented stackup. It loses to B on return-path detail (no return vias at pair transitions, single-via regulator grounds) and on the traces under the mounting hardware, which affect all four slots.
3. **A.** The most careful impedance planning and perfectly matched pairs, but power is carried on outer-layer pours that the signals fragment. That produces the 4.4 A single-via choke point, the compromised U10 and U14 input loops and a weakly tied ground pour. Any-angle routing and via-in-pad on fine-pitch pins add fab and review risk.
4. **D.** Unfinished and would not power up.

## Which board is the human's

**B, about 85 % confident.** This did not influence the scores.

- B uses only the track widths and the one via size already preset in the project file (0.127 / 0.2 / 0.25 / 0.35 / 0.4 / 0.8 mm tracks, 0.45/0.2 via). Its net classes, design rules and stackup are untouched from the starting project. A, C and D all added net classes and changed rules.
- B has 84 arc segments, all in rounded length-tuning meanders of the kind KiCad's interactive tuner draws. The other boards have none.
- 92 % of B's vias sit on a 0.05 mm grid and none of its routing is off 0°/45°/90°.
- Its mistakes look like a person's: a meander left on one leg of a pair, overlapping same-net zones with equal priority, edge clearance never set. Its strengths do too: no tracks near mounting hardware, the void under the RJ45, hand-placed keep-outs between inductor pads.
- The others carry tool signatures: A's 68 % any-angle routing and eleven via sizes, C's uniform 4 mm stitching grid, D's unfinished state.
