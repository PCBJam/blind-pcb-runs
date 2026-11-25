# M.2 PCIe x4 adapter fabrication notes

The finished KiCad 10.0.8 project has 373 track segments, 125 through vias including the retention hole, and seven filled zones. KiCad reports **zero DRC errors, zero unconnected items and zero schematic-parity differences**. All 20 footprints and all 163 pads match the supplied board in identity, position, side and net assignment. The schematic is unchanged.

## Order details

| Item | Fabrication requirement |
| --- | --- |
| Stack | Four layers, 0.876 mm nominal overall as recorded in the board. From F.Cu to B.Cu, the nominal copper and dielectric thicknesses are 18 / 120 / 35 / 510 / 35 / 120 / 18 µm. The stack also includes 10 µm of mask per face. Confirm finished thickness at the M.2 fingers and the straddle-mount socket with the fabricator. |
| Impedance | Specify **85 Ω differential, ±10%**, on both outer layers. The uniform runs use 0.218 mm finished trace width and 0.147 mm edge-to-edge gap over 0.120 mm FR-4. Have the fabricator correlate its finished copper, etch, laminate and mask to this target and verify with a coupon. |
| Finish | ENIG for the solderable lands. Specify selective wear-resistant hard gold over nickel on the J2 mating fingers on both faces. J1 is a soldered straddle-mount socket. |
| M.2 retention | Specify **one plated half-hole**. Drill and plate the 3.50 mm hole at board coordinates X 186.2073, Y 98.7598 mm before milling the right edge through its center. Keep the 4.20 mm grounded land exposed on both faces. The continuous line on Edge.Cuts is the final profile tool path through the plated hole. Call out the half-hole explicitly on the order. |
| Smallest drills | 0.25 mm finished signal/ground through holes. The signal vias are 0.50 mm in diameter and tented on both sides. |

The retention feature is a reconstruction. The supplied board had two mask rings and the project had an edge-clearance exclusion at this position, while the drill itself was missing. I used the 3.50 mm cutout diameter from KiCad’s M-key 2280 reference footprint and sized the land to the supplied rings. The custom rules permit edge intersection only for the ground via centered at this location. A test export confirms the 3.50 mm hit in the plated drill file and a flash at the same center in each mask file.

## Signal and return paths

All nine pairs leave J2 on B.Cu. Each turns toward J1 through a symmetric pair of through vias with ground stitching alongside. The four OUT pairs then land on J1’s front-side B row. The four IN pairs and REFCLK change back to B.Cu near J1’s A row. This preserves the connector pin mapping and gives both members the same number of transitions. The handedness change is absorbed at the paired vias. The pin escapes and via approaches account for the locally wider spacing.

| Center-to-center routed copper length | Lane 0 | Lane 1 | Lane 2 | Lane 3 |
| --- | ---: | ---: | ---: | ---: |
| IN, mm | 37.326 | 36.299 | 36.271 | 36.589 |
| OUT, mm | 37.345 | 36.318 | 36.290 | 36.262 |

REFCLK is 37.972 mm. Each table entry applies to both members to 0.001 mm. These are planar track lengths from pad centers. The project enforces 0.10 mm maximum intra-pair skew. The sideband reset and wake signals use a longer route around the PCIe via field, with one layer change each between J2 and their series links.

In2.Cu is a continuous ground plane apart from necessary clearances. In1.Cu provides ground under the front-side PCIe routes and carries shaped power areas elsewhere. I sampled all high-speed track centerlines at intervals of at most 25 µm against the saved adjacent ground fills. All samples outside a 0.65 mm radius of a signal via had ground underneath.

A two-dimensional odd-mode electrostatic calculation gave approximately 92 Ω for the inherited trace width and **85.2 Ω** for the final geometry. It used rectangular finished copper, the board’s outer dielectric constant of 4.2, and an assumed mask dielectric constant of 3.4. The estimate covers the uniform line section. The connectors, drilled transitions and installed system have not been characterized by TDR or a PCIe link test.

## Power and release checks

The M.2 3.3 V contacts feed a shared In1 supply area through local top copper and parallel vias. Each slot supply contact has a short, wide connection, and the bypass capacitors return to ground near their lands. R1 supplies 3.3 V AUX from the main rail. J3 pin 1, J4 and the slot 12 V contacts share broad top and inner copper. The separate 5 V path runs from J3 pin 4 to J5. The load budget depends on the host’s 3.3 V allocation, the external supply and connector ratings. A loaded temperature-rise test is still outstanding.

The saved board passes the KiCad DRC with the project settings and the bt filled-board check. All 20 warnings were present before routing and report the unavailable antmicro-footprints library. The embedded footprints plot successfully. Gerber and Excellon exports were exercised, and all copper layers, masks and the plated retention drill were checked. The numbered development record ends with a four-layer overview in [progress/010-final.png](progress/010-final.png).
