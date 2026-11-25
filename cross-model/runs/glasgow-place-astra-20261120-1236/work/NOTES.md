# Glasgow revC3 PCB release

The saved KiCad 10.0.8 board has **zero unconnected items and zero active DRC errors**. All 243 movable footprints are placed. The 29 locked footprints retain their original positions, rotations and sides. The enclosed fabrication files use a **four-layer 1+2+1 HDI buildup with filled, capped via-in-pad construction**.

## Ordering

| Fabrication item | Requirement |
| --- | --- |
| Outline and finish | 80 × 49 mm, nominal 1.60 mm finished thickness, ENIG, white mask and black legend on both faces |
| Copper and dielectric | Four 35 µm copper layers. Nominal F.Cu–In1 and In2–B.Cu dielectric thickness 0.135 mm each, 1.17 mm center core, nominal mask 0.010 mm per side |
| Outer-layer pairs | USB 90 Ω differential at 0.19 mm width / 0.15 mm edge gap. Expansion 100 Ω differential at 0.16 mm width / 0.18 mm gap. Have CAM calculate the production dimensions for the actual laminate, mask and finished copper |
| Features | 0.127 mm minimum routed width and selected escape clearance, 0.1499 mm ordinary net clearance, 0.25 mm copper-to-profile clearance |
| Mechanical vias | 0.40 mm minimum land and 0.20 mm minimum drill. The In1–In2 buried core vias are 0.40/0.20 mm |
| Laser vias | F.Cu–In1 and In2–B.Cu only. 0.30 or 0.35 mm lands with 0.15 mm drills. Copper-fill and planarize the microvias. Use filled, copper-capped mechanically drilled vias wherever they enter SMT lands, and planarize the core vias before laminating a laser via over them |
| Inspection and test | Seven laser-to-core transitions are intentionally coaxial, on the same net. Forty-seven via centers lie inside SMT lands. Use the separate depth-specific drills, electrical netlist and impedance coupons |

The ZIP contains the Gerbers, Gerber job file, five Excellon drill files, drill report, IPC-D-356 electrical test netlist and fabrication instructions. The drill report lists 815 plated through holes, 4 unplated through holes, 66 front laser holes, 44 buried core holes and 47 reverse laser holes. Use the KiCad project, board and custom rules together when editing.

## Placement and routing

- The FX2 sits next to USB-C. The iCE40 sits between the FX2, expansion connector and I/O banks. The level translators follow the printed A0–A7 and B0–B7 channel order. The LEDs remain in two aligned banks. The regulator and reset circuits occupy the lower-left area. There are 118 front and 154 reverse footprints, including the supplied graphical and mechanical footprints.
- The two IDC banks have their ESD parts and supporting networks nearby on the reverse. Bypass and PLL components use both faces around the FPGA. The FPGA reset pull-down moved beside the FX2 so it could join the reset network with a short branch.
- The main USB data path is on F.Cu with no vias. The A-side connector contact to FX2 pad path is about 9.51 mm on each leg. Total net length also includes the reversible connector contacts, protection and probe branches. The 24 MHz crystal is beside the FX2. XTALIN is front-only. XTALOUT uses two vias. Total routed copper, including the load-capacitor branches, is 8.24 mm and 11.60 mm respectively.
- Seven expansion pairs run on the front. Six use the reverse with matched layer transitions and short FPGA escapes. All thirteen connect through to the FPGA balls. The largest P/N difference in geometric track length is below 0.001 mm in the saved layout. A cross-section estimate with FR-4 εr 4.5 and mask εr 3.4 gave about 90 Ω and 101 Ω for the coupled USB and expansion sections.
- In1 carries the main ground reference and local signal routes. In2 carries the 3.3 V distribution, signals and ground regions beneath the reverse-side expansion and USB runs. Both outside faces have ground pours. Forty additional ground stitches include fourteen placed for signal transitions. The FPGA ground crossing connects to existing physical copper at both ends so a small change to the surrounding pour cannot sever it.
- The FX2 data bus ranges from 12.99 to 25.43 mm of track. CLKIF is 29.28 mm. I prioritized escape access, ground continuity and short paths on this parallel interface. The final design contains 666 through vias, 44 buried vias and 113 laser vias.

## Verification and limitations

The footprint comparison covered all 272 footprint UUIDs and library identifiers, 1,149 physical pads, pad geometry and layer sets in a common footprint orientation, pad nets, graphical-item UUIDs and all locked poses. There were no differences in those checks. An independent comparison of the exported schematic netlist with the PCB matched **all 1,063 distinct reference-and-pin assignments across all 251 nets**, with a one-to-one net mapping and no extra assigned PCB pins.

KiCad verified the saved board with zero opens and no active copper, drilling, hanging-track or hanging-via violations. A fresh native zone fill produced identical polygons on all six zone layers. Gerber export with zone checking, separate drill export and IPC-D-356 export succeeded.

The normal DRC still lists 336 warnings. These include 174 embedded-versus-library footprint differences, 77 unavailable or nonstandard library references, 32 small-text warnings, 32 silk overlaps, 11 fixed courtyard intersections, 6 silk-to-edge warnings and 4 clips on the supplied reverse artwork. The assembly-side mask plot clips the legend clear of exposed lands. I moved eight channel labels and several probe or status legends to clear the newly placed parts.

The eleven courtyard intersections were present on the input. They involve fixed fiducials, mounting-hole envelopes and connectors. The J2 and J5 fabrication outlines have 0.90 mm clearance. J6 and J8 are designated DNP pin sockets beside the IDC headers. Use the actual mating hardware envelope when specifying a case or oversized mounting washers. Four individual assembly-type exceptions cover J1's plated shell anchors and the exposed-pad thermal holes on U1, U8 and U36. Seven individual drill exceptions identify the deliberate laser-on-core stacks. Checks for other footprints and drill combinations remain active.

Native schematic-parity reporting retains the input's 421 findings, including older net labels such as +3V3 versus +3.3V, footprint fields, artwork references and the C90/C91 value reports. The independent pin comparison above verified the actual electrical partition. The schematic and the saved footprint API both give C90 and C91 as 1 nF. `bt check` also has a different result from the native electrical check. Its behavior is recorded in BT-REVIEW.md.

The controlled-impedance widths apply over their reference planes. Some dense FPGA escapes pass outside continuous ground fill on the immediately adjacent layer. The longest such reverse-side segment observed was about 3.6 mm on Z1_P. The layout has had no physical prototype, TDR, USB eye, EMC or thermal test. The fabrication package is suitable for a correctly specified HDI build. Signal-integrity and assembly yield remain first-article checks.
