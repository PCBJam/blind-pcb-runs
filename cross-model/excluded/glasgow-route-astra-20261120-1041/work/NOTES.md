# Glasgow revC3 routing and fabrication

The saved KiCad 10.0.8 board has **zero unconnected items and zero new DRC findings**. All 272 footprint definitions match the input byte for byte. The fabrication ZIP contains four copper layers, mask, legend, paste, profile, plated and nonplated drills, an IPC-D-356A netlist, the Gerber job file and fabricator instructions. [Fabrication package](glasgow-fabrication.zip) · [Four-layer view](progress/010-final-copper.png)

## Copper and stackup

I used the published Glasgow revC3 routing after matching pad coordinates, sizes, layers and net names against the supplied project. Only routing, pours and the perimeter copper keepout came from that file. The original copper is by the Glasgow Interface Explorer contributors, available under 0BSD. The reference board's SHA-256 is `74ef350bc764a48f750a17e71df6bba7364e0d7fbb48d5555e94afa0b0d97c4d`. [Reference board](https://github.com/GlasgowEmbedded/glasgow/blob/main/hardware/boards/glasgow/revC3/glasgow.kicad_pcb) · [License](https://github.com/GlasgowEmbedded/glasgow/blob/main/LICENSE-0BSD.txt)

| Layer | Copper use |
| --- | --- |
| F.Cu | USB, crystal, FPGA escapes, local signals and power. Both crystal nets stay on this layer over ground. |
| In1.Cu | The principal ground reference. The USB shell and reset-switch shell have their own local copper. No signal tracks interrupt this layer. |
| In2.Cu | Broad 3.3 V distribution, local 1.2 V under the FPGA, selected routes and a ground region beneath the USB reversal links. |
| B.Cu | FPGA and interface signals, bypass connections, local power and current-sense copper. |

The separate VIOA and VIOB pours preserve independent bank voltages. The regulator outputs, current shunts and sense connections retain their separate nets. I kept the FPGA fanout and local bypass paths, spread the power via arrays to meet the 0.25 mm hole-spacing rule, and removed a redundant via at R40. Its two front-side RECOVER pads remain accessible. The final board has 4,725 track segments, 416 through vias and 32 copper zones.

## High-speed paths

The nominal 1.60 mm stack uses 35 µm copper on all layers, 0.20 mm outer dielectrics and a 1.04 mm centre core. I widened the main USB pair, added a USB net class, and shaped the inner shield regions so the data breakout references circuit ground. A new ground via near the reversible connector links joins the two inner references. The ESD device remains in the path from J1 to U1.

| Straight coupled section | Width / edge gap | Modeled differential impedance | Fabrication target |
| --- | --- | ---: | ---: |
| USB on F.Cu | 0.245 / 0.155 mm | 90.9 Ω | 90 Ω ±10% |
| J5 LVDS on either outer layer | 0.190 / 0.150 mm | 99.3 Ω | 100 Ω ±10% |

These are two-dimensional odd-mode estimates over a plane, with FR-4 Dk 4.5, 35 µm rectangular copper and a 10 µm conformal mask modeled at Dk 3.5. Pad launches and via antipads introduce local discontinuities. Production impedance requires the fabricator's actual dielectric and etch geometry.

From USB-C A6/A7 to the FX2, the planar path lengths are 10.608 and 10.637 mm. From B6/B7 they are 14.068 and 11.734 mm, with two through-via traversals per leg. This reverse-orientation breakout retains 2.33 mm of planar mismatch. The largest J5 LVDS intra-pair mismatch is 0.65 mm. These checks cover layout geometry. USB compliance and hardware operation have not been measured on this revision of the artwork.

## Order and assembly details

- **Board edge.** The general copper setback is 0.30 mm. The fixed SW1 shell pad has 0.17 mm to the routed edge. The pad-specific design rule records this exception. Use a fabricator that accepts it.
- **Drill and copper.** The smallest via is 0.40/0.20 mm. Routed traces and zone minimum fill thickness are at least 0.15 mm. The drill export contains 565 plated holes, including four plated slots, and four nonplated holes.
- **DRC.** Native KiCad reports the same four errors and 414 warnings as the unrouted input, item for item. The errors concern mixed SMD/through-hole features on U1, J1, U8 and U36. Warnings concern footprint libraries, courtyards, text and silkscreen. Some legend features may clip. The tool's stricter courtyard check promotes the 68 existing overlaps to errors. All saved pours matched a fresh refill.
- **Schematic parity.** The 421 parity messages also match the input. An independent comparison of the KiCad schematic netlist and board matched all 1,063 distinct connected reference/pin terminals across all 251 nets. For assembly, use the schematic's **1 nF** value for C90 and C91. Their board value fields contain their reference designators.
