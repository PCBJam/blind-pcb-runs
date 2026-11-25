# Raspberry Pi NVMe NAS board

**Release hold.** The placement and routing are complete against the supplied PCB netlist. KiCad 10.0.8 reports zero unconnected items, shorts, clearance violations, copper slivers, starved thermals and dangling tracks or vias. I would hold the fabrication order and first power-up until the circuit and schematic-parity issues below are resolved.

## Electrical release decisions

1. **D1, D2, R10 and R11 exceed U3’s status-output ratings.** Each 220 Ω resistor feeds an LED from protected 12 V into a TPS2420 open-drain output. At a 2 V LED drop the ideal branch current is about 45 mA and resistor dissipation is about 0.45 W in a 0402. TI rates FLT and PG for 1 mA recommended sink current and 10 mA absolute maximum. Choose resistors for the maximum input voltage, minimum LED drop and 1 mA limit, or buffer the LEDs. Update the BOM and schematic together. [TI TPS2420 datasheet, absolute maximum and recommended operating conditions](https://www.ti.com/lit/ds/symlink/tps2420.pdf)
2. **R43 and R46 apply nominally 6 V to CM4 pin 96.** Both are 52 kΩ. The PCB connects their midpoint, VMON, to AnalogIP1. Raspberry Pi identifies this as a spare MXL7704 input with 100 nF to ground. Its allowable input range, measurement range and power-off behavior need confirmation for the installed CM4 revision. Select the divider for the highest supply voltage and transients before powering a module. [Raspberry Pi Compute Module 4 datasheet, section 2.12](https://datasheets.raspberrypi.com/cm4/cm4-datasheet.pdf)
3. **Reconcile the CM4 symbol and PCB before updating from schematic.** The supplied design already had 199 net-conflict findings and 16 symbol-field mismatches. For example, the schematic netlist export lists both Module1.92 (RUN_PG) and Module1.96 (AnalogIP1) on VMON. The board has pin 96 on VMON and pin 92 on CM4_RUN. The export also lists pin 96 on CM4_RST. Verify the connector pin numbers against the official pinout, correct the schematic and compare the complete netlist. Every original PCB pad net was preserved.
4. **Review the indicator common supply.** U18 pin 5, RP2040 GPIO3, directly supplies LED_V+ and its fourteen resistor branches. Check the worst simultaneous indicator current against the GPIO and I/O-bank budgets, including startup. A buffered LED supply may be needed. The connector shields of J7 and J15 are each joined locally on their original isolated shell net. Confirm the intended chassis and ESD path.

## Placement and current paths

All 254 footprints are present. The 38 locked footprints remain on the front in their original positions and orientations. Of the 216 placed parts, 31 are on the front and 185 are on the back. A normalized comparison against the input found matching pad numbers, nets, positions within each footprint, pad shapes and sizes, drills and layer sets. The board outline and footprint graphic bounds also matched. Only board-instance reference fields were enlarged and repositioned for assembly.

- The ASM1184 sits between the CM4 and four M.2 sockets. Its series capacitors sit at the switch escapes. Bypass capacitors use the opposite surface where the front pinfield needs space.
- Each M.2 socket has its own underside buck, inductor, output capacitors and 3.3 V copper region. The 5 V, 1.2 V and auxiliary 3.3 V stages use the same arrangement. The switch-node and inductor-to-output connections use short, wide copper. Multiple vias transfer load current to the distribution copper. Fine signal-width connections on a supply include pickups and local taps. Full-load voltage drop, simultaneous SSD startup and converter temperature still need measurement.
- The input TVS and hot-swap stage sit by the DC jack. Protected 12 V spans the converter input bays on In2. The 5 V region feeds the CM4 and other distributed loads. The RP2040 and flash face the service USB-C socket. The crystal, series resistor and two load capacitors form a local group on its opposite edge. All six QSPI nets are front-side and via-free.
- Movable silkscreen references are 0.8 mm high. In the densest regulator and resistor groups some labels had to move several millimetres. Use the placement data for assembly and rework. Check underside inductor and LED clearance against the intended enclosure and standoff height.

## Copper and signal integrity

| Layer | Use |
|---|---|
| F.Cu | Connector and fine-pitch launches, differential pairs, local logic and a ground pour |
| In1.Cu | Board-wide GND reference with **zero routed signal tracks** |
| In2.Cu | Ten supply regions, background GND, priority GND strips under bottom-side differential routes, and 74 local routing segments |
| B.Cu | Converter loops, bypassing, differential channels, controls and a ground pour |

The saved stack is symmetric, nominally 1.60 mm. It uses 35 µm copper on each layer, 0.11 mm outer prepregs, a 1.22 mm core and nominal 0.01 mm solder mask per side. The model uses FR-4 with relative permittivity 4.5. Outer GND pours have 0.45 mm clearance. Return vias accompany differential transitions where space permits.

| Interface | Nominal trace width / edge gap | Estimated differential impedance | Fabricator target |
|---|---:|---:|---:|
| PCIe | 0.18 / 0.14 mm | 84 Ω | 85 Ω |
| USB 2.0 | 0.17 / 0.15 mm | 87 Ω | 90 Ω |
| Gigabit Ethernet MDI | 0.15 / 0.17 mm | 94 Ω | 100 Ω |

The estimates come from a two-dimensional electrostatic model of straight coupled outer-layer traces over a plane. Ask the fabricator to solve for its laminate, pressed thickness, etch and plating, agree tolerances, and verify a coupon. Any geometry change requires rechecking the launches, spacing and lengths. Packages, connectors, pads, tuning segments, branching and via fields are outside that model.

All 15 PCIe differential channels were routed from paired centerlines for their main runs. Both conductors of every channel have equal via counts. The following lengths are mean planar copper lengths in mm, including both PCB portions of AC-coupled channels. They exclude component and connector delay.

| Channel | TX | RX | Reference clock | Largest P/N mismatch |
|---|---:|---:|---:|---:|
| CM4 upstream | 57.33 | 65.69 | 51.21 | 0.009 mm |
| M.2 port 1 | 32.78 | 30.34 | 32.95 | <0.001 mm |
| M.2 port 2 | 22.58 | 23.88 | 21.88 | 0.032 mm |
| M.2 port 3 | 39.69 | 43.36 | 58.45 | <0.001 mm |
| M.2 port 4 | 71.33 | 60.27 | 58.90 | <0.001 mm |

The four CM4-to-magnetics Ethernet pair lengths are 60.86, 56.31, 54.49 and 51.44 mm. Their calculated intrapair mismatch is under 0.01 mm, with 1.545 mm assigned per full through-via traversal. Pair 0 required 8.79 mm of tuning on its shorter conductor. The ESD-array and magnetics fanouts include uncoupled sections. For USB, the CM4-to-L7 data tracks are both 60.416 mm on the front. R59/R60 to the primary service-connector contacts are approximately 6.7 mm on the front, with local branches joining the reversible contacts. Exercise both plug orientations on each port.

A projection of the PCIe trace centerlines onto the actual adjacent GND fills found approximately 98% coverage on F.Cu and 96% on B.Cu. Antipads, transitions and local escapes account for gaps. Endpoint matching and that geometric check do not predict eye opening. The adapter, four populated SSDs, Gigabit Ethernet and both USB ports still require prototype testing.

## Fabrication and verification record

- **Process requirements.** Minimum routed width and copper clearance are 0.127 mm. Through vias span 0.20–0.30 mm finished drill. The smallest used via is 0.41 / 0.20 mm. There are 845 through vias, 36 with centers inside SMD lands. Specify filled and copper-capped via-in-pad (VIPPO) for assembly, including the fine-pitch connector and IC lands. Check stencil and thermal-pad treatment with the assembler. No microvias or blind or buried vias are used.
- **Holes and outline.** The project specifies 0.25 mm copper-to-edge and 0.20 mm copper-to-hole. The supplied J7 and J15 footprints have 0.165 mm clearance between their own ground lands and nonplated locating holes. A local 0.16 mm rule covers pad-to-pad hole clearance within those two connectors. Keep the project, board and custom rule file together. The closed outline is 147.4 × 91.0 mm overall, with the original cutout.
- **Final KiCad DRC.** The saved board has 17 errors and 282 warnings. All 17 errors are inherited footprint-type metadata mismatches. The warnings comprise 196 library-copy mismatches, 24 footprint-library issues, 56 text-height findings and six existing silk-to-edge findings. The incoming board had the same 17 errors and 425 warnings. The separate courtyard run found zero overlaps. Original DRC severities were retained. Confirm all physical land patterns against component drawings before release.
- **Connectivity and manufacturing plots.** KiCad reports zero unconnected items. The independent board-tool check reports zero nets in pieces and zero additional routing findings. Final Gerber plotting succeeded for all four copper layers, both masks, both paste layers, both silkscreens and Edge.Cuts. Excellon export produced 917 plated and 27 nonplated holes. These were verification exports. No order was submitted.

The numbered images and notes record placement, discarded routing trials, the service-USB redesign, tuning and the final clearance and plot checks. [Progress log](progress/)
