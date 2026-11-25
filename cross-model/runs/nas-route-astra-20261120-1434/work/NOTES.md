# Raspberry Pi NVMe NAS — routing and fabrication notes

**Routing is complete. Production release is on hold for the supplied schematic and mechanical discrepancies described below.** KiCad 10.0.8 reports zero unconnected items. Against the unrouted starting board, the final check adds zero DRC errors, zero warnings and zero schematic-parity findings.

## Layer stack and impedance

The specified 1.60 mm stack uses 35 µm copper on all four layers, 0.135 mm outer dielectrics, a 1.17 mm central core and nominal FR-4 Dk of 4.5. F.Cu carries component breakouts, converter loops, signals and power pours. In1.Cu is uninterrupted ground apart from hole clearances. In2.Cu is principally ground. It also carries the CM4 5 V feed, a 2.4 mm connection to the fan supply, and several short power and controller connections. B.Cu carries signal spans and supply copper. The In2 routing reserves ground beneath the long backside differential spans.

| Differential interface | Nominal outer trace / gap | Estimated differential impedance |
|---|---:|---:|
| PCIe data | 0.20 / 0.15 mm | 88 Ω |
| PCIe reference clock | 0.16 / 0.19 mm | 101 Ω |
| Gigabit Ethernet MDI | 0.16 / 0.18 mm | 100 Ω |
| Main CM4 USB 2.0 link | 0.19 / 0.16 mm | 91 Ω |

These estimates use a two-dimensional odd-mode electrostatic cross-section with the specified dielectric, rectangular copper and a nominal 10 µm solder mask. For fabrication, request controlled impedance and have the fabricator confirm the finished geometry on its laminate. Pad launches, vias, capacitor bodies, connector models and local coplanar copper are outside that estimate.

## Signal routing

The CM4-to-ASM1184 upstream link and all four M.2 downstream links have paired data and clock routes. The long spans follow offset traces on the same layer. Backside spans use paired transitions, with nearby ground vias for the return. Each transmitter routes through its placed AC-coupling capacitors. I tuned within each pair after making the connections.

Across the 15 named PCIe data and clock pairs, the largest planar length difference is **0.028 mm**. Each P/N pair has equal via counts. The five short switch-to-capacitor pair sections differ by at most 0.017 mm. Some launches require additional transitions, particularly the port 3 transmitter and port 2 receiver. The longest named span is about 100 mm. These are layout measurements. Channel performance still depends on the actual stack, module, connectors and SSD.

The Ethernet links pass through the two ESD arrays. The long CM4 USB span is matched at 47.833 mm per conductor. The flash clock is 3.777 mm on F.Cu. The microSD clock is 37.169 mm and the command/data paths span 28.103–38.096 mm. No hardware link-margin or timing test has been performed.

## Power and return currents

Each of the seven buck regulators has a short 0.42 mm F.Cu switch-pin-to-inductor connection. The bootstrap capacitor uses a separate branch. Each SSD supply has its own stitched copper region serving its output capacitors and the socket's two groups of power contacts. The ASM1184 and RP2040 have local bypass connections. The eFuse and switch exposed pads have thermal via arrays.

The 12 V and 5 V buses use copper on both faces with parallel transfer vias. A first resistance estimate exposed a narrow effective path between the 5 V inductor and the CM4. A dedicated inner feed and a bank of module-side vias reduced the estimate from approximately 66 mΩ to 6 mΩ. Two additional 1.6 mm paths support the far 12 V converters.

| Final supply path | Approximate copper resistance |
|---|---:|
| DC jack to eFuse inputs | 1.3 mΩ |
| eFuse outputs to furthest 12 V buck input, U13 | 35 mΩ |
| 5 V inductor to CM4 input contacts | 6 mΩ |
| 5 V inductor to the three remote fan headers | 24–25 mΩ |
| Each SSD output inductor to its socket's grouped supply contacts | 2.4–6.1 mΩ |

The estimates use a 0.1 mm copper mesh, 35 µm copper, nominal 25 µm barrel plating and a separate 1 A test load for each destination. They exclude the ground return, connector contact resistance, regulator response and heating. Simultaneous SSD startup, CM4 transients, fan loading and converter temperature remain bench-validation items.

## Fabrication requirements

- The board has 2,517 track segments, 945 through vias and 26 filled zones. The minimum routed track and design clearance are 0.127 mm. The project copper-to-edge minimum is 0.25 mm.
- Routing via drills are 0.20, 0.25 and 0.30 mm. The smallest routing via land is 0.43 mm. Existing component and mechanical holes use their footprint sizes.
- **Use resin-filled, planarized, copper-capped vias at the marked lands.** The board marks 20 vias for filling and capping, including those on the U12 and U3 exposed pads and those at or immediately beside U10.1, U17.7, J7.A6, C3.1, C85.1 and TP_VIN1.1. U18 also has nine 0.35 mm plated holes built into exposed pad 57. Include those footprint holes in the assembly/fabricator review for solder wicking and pad planarity.

## Verification and release holds

- KiCad opened the saved board and exported four copper Gerbers, the outline, mask and paste layers, and separate plated and non-plated drills. A fresh refill reproduced the saved fill geometry of all 26 zones. The final connectivity check found zero opens, shorts, clearance violations, dangling tracks or dangling vias. All 254 footprints retained their UUIDs, positions, rotations, sides, pad locations and net assignments.
- With courtyard checking enabled, the original and final boards have the same **26 errors and 425 warnings**, compared by finding and affected item. The errors comprise 17 footprint-type declarations and nine courtyard overlaps. The warnings comprise 199 text heights, 196 installed-library footprint mismatches, 24 library configuration issues and six silkscreen edge clips.
- Check physical assembly clearance at J6 with D1, D2 and R10, and at J15 with D13. The other courtyard pairs are C9/C13, C12/TP_1V2, IC1/TP_VIN1, C5/TP_VIN1 and C70/TP_3V3. The fixed placement prevents correcting these by repositioning parts. A courtyard overlap alone does not establish whether the actual bodies collide.
- **Reconcile the schematic before ordering.** KiCad warns of schematic annotation errors and reports 215 parity findings, including 199 pad-net conflicts and 16 field differences. Some conflicts are generated net names, but others concern real pin assignments. For example, the exported schematic puts Module1 pin 74 on both GND and +3V3, and pins 84 and 86 on both +1V8 and +3V3. The routed board follows the supplied PCB, where 74 is GND and 84/86 are +3V3. Updating the PCB from the current schematic requires resolving those conflicts first.
