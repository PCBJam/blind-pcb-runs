# OrangeCrab r0.2.1 routing and fabrication notes

The board is fully routed. KiCad 10.0.8 reports **zero unconnected items, shorts, copper-clearance violations, drill-spacing violations, starved thermals or dangling copper**. The saved board contains 3,756 track segments, 858 vias and 22 filled zones. A fresh fill reproduced all 22 saved polygon sets. I compared the original and delivered boards by UUID and verified all 163 footprint placements, all 1,097 pads and their nets, and all eight outline primitives.

**Order this as a six-layer, 2+2+2 sequential-lamination HDI board with filled and capped vias and Feather castellations.** The physical stack, fine features and stacked drills need approval from the selected fabricator. I verified manufacturing export from the saved board. Vendor acceptance, electrical simulation and prototype testing are outstanding.

## Fabrication drawing information

| Copper layer | Finished copper in nominal stack | Use |
|---|---:|---|
| L1 · F.Cu | 35 µm | Components, short switch nodes, local rail pours, BGA escapes, DDR and other signals, ground |
| L2 · In1.Cu | 18 µm | Primary top-side ground reference, with signal escapes concentrated around dense packages |
| L3 · In2.Cu | 18 µm | USB and DDR clock trunks, signals, and ground fill with 0.35 mm clearance |
| L4 · In3.Cu | 18 µm | Both DDR strobe trunks, other signals and split power distribution |
| L5 · In4.Cu | 18 µm | Primary bottom-side ground reference, with some local signal escapes |
| L6 · B.Cu | 35 µm | Back-side decoupling, component connections, signals and ground |

The nominal finished thickness is 1.60 mm with ENIG. Dielectric thicknesses from top to bottom are 0.090, 0.090, 1.078, 0.090 and 0.090 mm. The board records nominal FR-4 Dk 4.1. The 0.089 mm minimum track and copper clearance, 0.065 mm minimum via annular ring, 0.15 mm hole-to-copper clearance and 0.25 mm drill-edge spacing are fabrication requirements. Fine routing extends beyond the ball escapes. There are 751 segments narrower than 0.127 mm.

| Drill operation | Count | Finished hole / copper land |
|---|---:|---|
| Adjacent build-up lasers, L1–L2 / L2–L3 / L4–L5 / L5–L6 | 166 / 93 / 39 / 87 | 0.10 / 0.25 mm |
| Buried mechanical, L3–L4 / L2–L5 | 86 / 28 | 0.15 / 0.28 mm |
| Through vias | 359 | 0.15 / 0.28 or 0.32 mm, plus thirteen 0.20 / 0.42 mm |

Fill and planarize the laser and buried landings before the next build-up. Provide filled, plated-over via-in-pad surfaces for assembly. There are 62 two-stage and 55 three-stage coaxial stacks. Each stage meets its neighbour on a single common layer. The 0.15 mm through drill requires about a 10.7:1 finished-board thickness-to-hole ratio. Fabricate J1 and J2 as plated half holes with their lands reaching the routed edge. J3 also has plated shield slots. The export check produced six copper Gerbers, both masks, pastes and silkscreens, the outline, a Gerber job file, and eight Excellon files covering all seven plated spans plus NPTH.

## Routing decisions

The ECP5's 0.5 mm ball pitch, back-side capacitors and fixed header placement compete for the same escape channels. The north bank exits in pin order on three layers. Blind and buried spans preserve routing space on the opposite face. L2 and L5 carry the main returns. Ground transfers near USB and the DDR launches join the references, including one 0.72 mm from the connector-side USB transition. Some ground-plane slots and via antipads remain under the interfaces, particularly near the BGAs and the back-side clock termination. Return-path continuity and impedance deserve review with the fabricator's stack.

The three TLV62569 switch-to-inductor links are 0.36 mm wide, 1.30–1.65 mm long and via-free on L1. Local pours serve the converter outputs and input capacitors. VBUS, battery and VSYS feeds widen to 0.50 mm where clearance permits. L4 distributes VSYS, 3.3 V, 1.1 V, 1.35 V and the two downstream DDR supplies. The memory core and I/O supplies remain separate after their ferrite beads. Local tracks bridge interruptions in the split pours. The 2.5 mm reference-clock route stays on one layer. No DC-drop or transient power-integrity simulation was performed.

The USB connector-to-resistor pair uses a coupled L3 trunk with 0.150 mm width and 0.130 mm nominal edge gap. The connector's duplicate contacts and the back-side test pads form branches. The FPGA-side runs beyond the series resistors are approximately 3.2 and 3.4 mm. The DDR clock and both strobes use 0.127 mm traces with a nominal 0.153 mm edge gap on their coupled trunks. Ask the fabricator to model the **90 Ω differential USB and 100 Ω differential DDR** geometries on the actual laminate and plating. These are design targets.

## DDR timing review

I traced the DRAM ball functions in the cached schematic symbol. U4 F3/G3 are the physical lower strobe and carry the board nets named RAM_UDQS+/−. U4 C7/B7 are the upper strobe and carry RAM_LDQS+/−. The project net classes use the physical byte groups.

| Path or group | Pad-to-pad length or range | Estimated flight time |
|---|---:|---:|
| RAM_CK+ / CK−, FPGA to DRAM | 15.751 / 15.748 mm | 104.63 / 104.73 ps |
| Physical lower strobe + / − | 14.791 / 14.800 mm | 97.96 / 98.38 ps |
| DQ0–7 and LDM | 13.28–19.87 mm | 88.69–120.07 ps |
| Physical upper strobe + / − | 15.358 / 15.359 mm | 102.21 / 102.49 ps |
| DQ8–15 and UDM | 13.84–19.87 mm | 89.12–128.92 ps |
| Address, bank and synchronous controls | 14.42–19.97 mm | 86.38–133.23 ps |

The estimates follow the copper from FPGA pad to DRAM pad, include vertical travel and exclude the onward clock-termination branches. They assume 5.85 ps/mm on the surfaces and 6.7 ps/mm on internal copper and vertical transitions. The three differential pairs each have under 0.01 mm physical mismatch. The largest synchronous command offset from mean CK is about 29 ps. The largest data or mask offset from its mean strobe is about 27 ps. The inherited net-class names contain “LM1.0”. The byte and command groups do exceed a 1 mm physical matching window. These values are layout estimates. Package delays, actual propagation, FPGA controller settings, training margin and maximum operating rate require separate validation.

## Remaining DRC and assembly findings

Native DRC reports **69 errors and 201 warnings**, all present on the incoming board. The errors are 68 courtyard overlaps and the open J5 courtyard. The warnings are 111 unavailable-library findings, 51 library-footprint mismatches and 39 text-height findings. I compared the available closed Fab body outlines for 57 of the 68 courtyard pairs and found zero positive-area overlaps. For J3, the installed HRO shell outline aligns with the supplied contact pattern. The eight neighbouring passive bodies checked against it clear by at least 0.70 mm. The two custom LEDs and H4/FID6 lack equivalent closed-body comparisons. Assembly clearance and component tolerances still need review with the selected parts.

The edge-clearance exception is restricted to pads of J1 and J2. The project also records 31 specific co-located-hole markers for verified adjacent, filled drill stages. Removing those exclusions reproduces the stacked-drill warnings. Global hole spacing and copper spacing remain enforced. Keep the board, project and custom-rule files together.
