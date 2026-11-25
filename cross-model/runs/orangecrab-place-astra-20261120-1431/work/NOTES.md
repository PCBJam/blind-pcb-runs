# OrangeCrab layout

The six-layer board retains the Feather outline, the two castellated headers, the mounting holes and all fixed connectors. All 163 original footprints are present in the layout, 82 on the front and 81 on the back. The 19 locked footprints retain their original positions, orientations and sides.

KiCad 10.0.8 reports zero unconnected items and no new design-rule violations relative to the input. The manufacturing outputs are suitable for an HDI quotation. Production release still needs fabricator stackup approval and a memory timing check at the intended operating rate.

## Placement and routing

- U3 and U4 occupy the front side. The ECP5 is rotated so its memory bank faces the DDR3 package. U4 is rotated 180°. The DDR3 buses, differential clock and strobes were routed before most supply drops. Placing power vias first blocked several 0.5 mm BGA escape channels.
- The three buck converters U1, U2 and U7 share the reverse side with their inductors and input capacitors. Their switch-node tracks are 0.35 mm wide, approximately 1.93, 1.93 and 3.81 mm long, with no layer changes. Local power regions distribute the regulator outputs. The ferrite-filtered memory rails retain separate copper. The small bypass capacitors were placed by rail and load-pin group.
- The BQ24232 charger sits near the battery and USB end. The analog multiplexer sits near the Feather analog pins. The oscillator is on the reverse close to the FPGA. The flash was moved to the opposite end of the reverse side because its exposed pad obstructed the USB and core-supply escapes under the FPGA. This trades a longer flash bus for better access to the FPGA ball field.
- The USB-C pair from A6/A7 to the two series resistors shares an In3 corridor. Each main leg measures about 19.32 mm including its escapes, with the same number of transitions. This measurement excludes the duplicate receptacle contacts, test-point branches and FPGA-side routing. The clock runs primarily on In2 and the two DDR3 strobes primarily on In3. Supply and general I/O routing followed these connections.

## Stack and fabrication requirements

| Copper | Function | Dielectric to next copper |
| --- | --- | --- |
| F.Cu | Components, signal escapes, local power, ground fill | 0.085 mm |
| In1.Cu | Primary upper ground reference with local signal escapes | 0.120 mm |
| In2.Cu | Signals, VSYS, 1.35 V, filtered RAM VDD and residual ground | 1.028 mm |
| In3.Cu | Signals, 1.1 V, 3.3 V and filtered RAM VDDQ | 0.120 mm |
| In4.Cu | Primary lower ground reference with local signal escapes | 0.085 mm |
| B.Cu | Components, switch nodes, signals, ground fill | — |

The nominal stack is symmetric, 1.60 mm including masks, with 35 µm outer and 18 µm inner copper. The target finish is ENIG. The five ground fills and six power regions are saved in the PCB. Inner ground layers have local interruptions from escape tracks and via antipads.

Specify **six-layer 1+4+1 HDI**, plated edge castellations at both Feather headers, laser vias from L1 to L2 and from L6 to L5, and buried vias from L2 to L5. Laser vias are 0.23 mm lands with 0.10 mm openings. The signal through and buried vias use 0.28 mm lands and 0.15 mm holes. Via-in-pad locations require filling, capping and planarization for assembly. Tenting alone leaves the component soldering surface unsuitable. The fine geometries include approximately 0.09 mm tracks and 0.089 mm clearance. Have the fabricator review the 0.065 mm annular ring, small mechanical drill at this board thickness, finished hole tolerances and sequential lamination before accepting a quote.

The intended differential impedance is 90 Ω for USB and nominally 100 Ω for DDR3 clock and strobes. The actual laminate, etch compensation, nearby copper and return-plane interruptions affect impedance. Finalize the dielectric and controlled-impedance coupon with the fabricator. No field-solved end-to-end extraction or memory-controller timing sign-off is included.

## Project rules and inherited DRC findings

Keep the adjacent project and custom rule files with the board. The project assigns separate routing widths for supplies, switch nodes, USB and DDR3, with narrow escapes in the BGA field. The custom rule permits copper at the edge specifically for pads on the two castellated headers. The regular copper-to-edge requirement still applies to tracks and vias.

Two errors predate placement and involve fixed footprint geometry. J5's embedded courtyard has a 0.05 mm gap at its upper-right corner. When I closed it virtually for a placement check, the closest newly placed courtyard was R6 at 0.183 mm. The reconstructed courtyard overlaps the original J1, J3 and FID2 courtyard envelopes. FID2 sits inside the battery connector body outline and will be covered after J5 is fitted. Use accessible panel fiducials for assembly. The H4 mounting-hole courtyard overlaps FID6's courtyard. The two centers are approximately 2.77 mm apart. H4 has a 2.54 mm drill and the fiducial a 1.50 mm mask opening. Both findings remain visible. The input also has 111 unavailable-library warnings, 51 library-footprint comparison warnings and 39 warnings about original text height. The embedded footprint geometry is used for manufacturing output.

The In3 USB copper has a dedicated 0.30 mm zone spacing rule to control nearby coplanar copper. The board records filling and capping on 334 vias, including every laser via and mechanically drilled vias that intersect same-net SMD lands. Finish and inspect those lands to the assembly supplier’s via-in-pad flatness specification.


## Measured signal paths

I measured shortest continuous copper paths between the FPGA and DRAM pads, including travel between the actual copper layers used at each via. The numbers exclude package delays and branches to terminations. They describe geometric length and do not incorporate the propagation velocity of each trace environment.

| Group | Measured lengths | Remaining concern |
| --- | --- | --- |
| DDR3 clock | CK+ 13.476 mm, CK− 13.356 mm | Within-pair skew 0.120 mm |
| Lower-byte strobe | Both legs 14.129 mm | Within-pair skew below 0.001 mm at this measurement resolution |
| Lower data byte | D0–D6 13.972–14.134 mm, D7 9.076 mm, LDM 13.902 mm | D7 is 5.053 mm shorter than the strobe |
| Upper-byte strobe | 12.113 and 12.066 mm | Within-pair skew 0.047 mm |
| Upper data byte | D8–D15 10.070–19.662 mm, UDM 14.685 mm | D11 is about 7.57 mm longer than the mean strobe path |
| Address and bank address | 4.800–15.213 mm | A4 is about 8.62 mm shorter than the mean clock path |

Several signals exceed the 1 mm matching intent indicated by the original DDR3 class names. The memory clock class and the two data-byte classes retain their identities. A controller timing budget including FPGA and memory package delays, and bring-up testing across voltage and temperature, are outstanding. The class names alone do not establish a supported maximum DDR rate.

On the primary USB path, J3 A6/A7 to the corresponding series resistors measures 20.862/20.857 mm including layer travel. The resistor-to-FPGA paths measure 5.992/6.782 mm. The complete positive and negative paths differ by about 0.785 mm, excluding the resistor bodies. Duplicate USB-C contacts, pull-up and test-point branches are present as required by the schematic.

I sampled the filled adjacent ground layers at 0.05 mm intervals along the internal differential traces. About 97% of each internal USB leg and 90% of each positive strobe leg has ground directly below its centerline. The In2 clock copper, including terminal branches, has upper ground coverage of about 66–68%. The interruptions at escapes and vias deserve particular attention in signal-integrity review.

## Verification and ordering

- KiCad's saved-board DRC has zero unconnected items, two inherited errors and 201 inherited warnings. No new track, via, drill, short, clearance, dangling-copper or courtyard finding remains. The combined bt check also found zero nets in pieces and reported that the saved fills were current. Its generic 0.127 mm width threshold and comparison of laser holes to the through-drill minimum flag the documented HDI geometries.
- The outline primitives, 19 locked transforms, footprint and pad identifiers, pad nets, sizes, drills and normalized pad centers match the input. The 144 unlocked footprints were placed. Footprint reference visibility follows the supplied artwork.
- The board has 468 through vias, 127 front laser vias, 70 back laser vias and 30 buried vias. There are no coincident via centers. The Gerber job records six copper layers, 1.60 mm thickness and ENIG. I generated and checked all six copper files, both masks, pastes and silks, and the profile. The drill export produced separate PTH, NPTH, L1–L2, L2–L5 and L5–L6 files. An IPC-D-356 electrical-test netlist also exported successfully.
