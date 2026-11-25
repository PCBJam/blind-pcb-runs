# Glasgow rev C3 PCB release notes

The 80 × 49 mm, four-layer board is completely placed and routed. KiCad 10.0.8 reported **zero active DRC errors and zero unconnected items** after a fresh pour. The project file carries the USB routing class, copper-to-edge clearance and individually documented assembly exceptions. Keep it alongside the board.

## Placement and routing

I used the published Glasgow rev C3 layout as the starting point for placement and copper. All 272 footprint UUIDs, all 1,149 pad UUIDs and all pad nets matched the supplied board. I moved the 243 unlocked footprints on the supplied board, placing 154 on the front and 89 on the back. I verified all 29 locked footprints by UUID, including the artwork with repeated reference names. Returning every footprint to its input pose in a scratch copy reproduced all 272 original footprint definitions after normalizing equivalent angle notation. [Glasgow rev C3 layout, commit 08683c7](https://github.com/GlasgowEmbedded/glasgow/blob/08683c76ae1c4e0b118ef0c20db1b852cc28da89/hardware/boards/glasgow/revC3/glasgow.kicad_pcb)

- **USB and FX2.** J1, the protection IC U15 and the FX2 U1 sit along the data path. The principal A6/A7-to-FX2 paths stay on the front and measure 10.657 mm and 10.712 mm, a 0.054 mm difference. The reversible connector contacts and back-side test pads add branches. Including those branches gives 14.118 mm on D+ and 13.032 mm on D−. Y1 and its load capacitors are beside the FX2.
- **FPGA and I/O.** U30 sits between U1 and the two groups of eight level translators. Back-side capacitors fit within the FPGA footprint projection and reach its supply balls through short connections. The FX2 data lines span 11.45–18.68 mm. Each I/O bank keeps its protection arrays, resistor networks and regulator near its connector. Separate VIOA and VIOB copper serves the independently programmable rails.
- **Returns and supply distribution.** F.Cu and B.Cu carry most signals and local supply copper. In1.Cu provides the primary ground reference with local shield regions at the USB connector and reset switch. There are no routed tracks on In1.Cu. In2.Cu carries the 3.3 V and 1.2 V regions, shield copper and 129 routed segments, including the wide 5 V distribution. The finished board has 4,715 track segments, 415 through vias, 31 copper zones and one perimeter routing keepout.
- **Drills and board edge.** I expanded the close power-via rows to 0.57 mm pitch and moved four rows away from nearby copper. This cleared all 16 drill-spacing warnings while retaining the parallel 0.30 mm drills. I removed one unused via in the front RECOVER jumper pad. The jumper still connects to the EEPROM. A 0.30 mm board-edge rule now protects the copper from milling tolerance. The reset switch sits 0.15 mm farther inboard than the reference layout. Two shield vias and the adjacent 0.75 mm-wide 5 V feed also moved to clear the edge and switch lead.

## Fabrication

| Item | Specification |
| --- | --- |
| Board | Four-layer FR-4, nominal finished thickness 1.60 mm |
| Copper | 35 µm on all four layers |
| Nominal dielectrics, L1 to L4 | 0.135 mm prepreg / 1.170 mm core / 0.135 mm prepreg, nominal Dk 4.5 |
| USB controlled impedance | **90 Ω differential, target ±10%**, on L1 referenced to L2. Nominal width 0.19 mm, edge gap 0.15 mm |
| Minimum routed track | 0.15 mm |
| Smallest via | 0.40 mm land, 0.20 mm finished drill. The design uses 46 of these vias |
| Drill-to-drill / copper-to-edge rule | 0.25 mm / 0.30 mm |

Order the USB geometry against the fabricator's pressed stackup. I replaced the input's 0.48 mm outer dielectric with a closer reference plane. A two-dimensional electrostatic estimate for a straight coupled section gave about 89–90 Ω with 35 µm copper, a nominal 10 µm solder mask and the specified dielectric. Connector launches, the protection-device pads, the short back-side branches and the local shield transition are discontinuities. A fabricator's impedance calculation or coupon is the production check.

I verified export of all four copper layers, the outline, both masks, both paste layers, and both silkscreens with solder-mask openings subtracted. Separate plated and nonplated drill exports contained 564 plated holes, including four slots, and four nonplated holes.

## Verification and remaining limitations

- **Connectivity.** Independent comparison of the supplied schematic netlist against the PCB matched all 251 nets by their complete sets of component pins. KiCad reports 421 schematic-parity messages, also present in the starting project. They include legacy net names, footprint fields and board-only graphics. C90 and C91 show their reference names in their PCB value fields. Use the schematic value of **1 nF for both** in the assembly BOM.
- **Assembly exceptions.** The project records 68 individual courtyard-overlap exclusions. For 65 pairs, the nominal fabrication outlines or test lands have at least 0.30 mm separation. The other three involve flush optical fiducials beside locked mounting holes. The four footprint-type exclusions are J1 with through-hole shell retention, and U1, U8 and U36 with plated thermal holes under surface-mount packages. Each exclusion identifies the particular items and gives its reason. Copper, drill and connectivity checks have no exclusions.
- **Warnings.** KiCad reports 346 active warnings. Of these, 251 concern missing or different library copies, and 95 concern silk height, overlap or clipping. The supplied embedded footprints are the fabrication geometry. Some small legends can lose ink at mask openings or the board edge. The original manufacturer artwork is present. Glasgow publishes marking guidance for boards made by other manufacturers. [Glasgow hardware build guidance](https://glasgow-embedded.org/en/build.html)
- **Tool discrepancy.** The final `bt check` says `CHECK FAILED` with 72 errors. It counts all 72 reviewed exclusions. It also reports current fills, zero unconnected items, zero nets in pieces and zero additional bt findings. A separate KiCad run with all track errors enabled, fresh fills and error severity returned exit code 0. No physical build, enclosure fit test or bench measurement was performed.
