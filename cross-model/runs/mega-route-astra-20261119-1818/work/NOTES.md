# Arduino Mega 2560 routing and fabrication

The saved KiCad 10.0.8 board has **zero unconnected items and zero new DRC errors or warnings** against the supplied placement. All 66 footprint blocks and all board-level drawing blocks compare byte-for-byte with the input. A separate check matched the identities, locations, orientations, sides, pad geometry and net assignments of all 410 pads.

## Ordering the bare board

Upload **Arduino_Mega_2560-JLCPCB.zip** for a standard two-layer FR-4 board. The intended build is 1.6 mm thick with 1 oz outer copper and tented through vias. The outline is 101.60 × 53.34 mm. The archive contains front and back copper, mask and silkscreen, the routed profile, and separate plated and non-plated Excellon files. The six 3.20 mm mounting cutouts are in the profile. The two 0.65 mm USB locating holes are in the NPTH file.

I plotted with KiCad’s zone check enabled and subtracted mask openings from the silkscreen. I reopened the outputs independently, verified that the profile closes into one perimeter and six cutouts, and matched every via to a plated drill hit of the correct diameter. The fabrication preview in the progress log uses these outputs. The archive has been checked locally. JLCPCB has not reviewed it.

## Routing decisions

| Circuit | Implementation and reason |
| --- | --- |
| USB-C to ATmega16U2 | The primary paths through RN2 stay on the front using 0.22 mm traces. The duplicate D− contact uses a short back-layer crossover and two vias. The resistor and protection connections are local. I reserved back-layer return copper under the resistor-to-MCU run. The fixed lands spread the pair at RN2. This is a short full-speed USB interface without a controlled-impedance qualification. |
| Clock and analog supply | Both clock networks, their associated passives, U4’s UCAP, and the FB2/C18 filtered AVCC branch are front-layer routes with no vias. The Mega resonator’s two complete trace networks measure 14.38 and 13.17 mm including the resistor branches. The USB bridge’s two crystal networks each total about 8.2 mm. Fixed component spacing sets the loop sizes. |
| Analog header bank | All 16 ADC channels fan inward from the north side of U3 through two staggered via rows under the package. They run south in order on the back, with one via per channel. The two approaches near the lower mounting hole bend around it. Keeping the bank together leaves the front available for ground and digital crossovers. |
| Input and regulator | The jack-to-diode feed is 1.05 mm. The main protected input paths are 0.85 mm. U1 has a 1.30 mm tab-to-output link. The regulator output has higher-priority 5 V copper on both faces, joined by four 0.75/0.35 mm thermal vias outside the tab land. USB fuse and high-current header branches are wider than the logic supplies. |
| 5 V distribution | The regulator-to-J2 feed is 0.65 mm on the back. J5 has a dedicated 0.55 mm run along the upper edge, with a short 0.45 mm approach at J2 and a 0.60 mm approach at J5. This gives the far shield header a parallel supply path independent of the MCU fanout. Local supply branches generally use 0.35 mm. U3 pin 31 takes its feed through C6. |
| Ground and returns | GND pours on both faces join SMD lands solidly. Through-hole ground pads use thermal relief. J12 pin 6 also has a 0.42 mm front connection to a nearby ground via. I added local ground drops at bypass components, connected overlapping top and bottom ground regions, and added return vias near signal transitions. The final ground has 98 vias. The connector shield remains on USHIELD and connects to GND through FB1 as assigned in the board. |
| Digital signals | Ordinary signals use 0.20 mm tracks. Both sides carry signals where connector order requires crossings. Freerouting handled the bulk digital routes with the clock, USB, analog bank and primary power copper protected. I shortened two LED connections and gave the far-header supply its own corridor during review. |

The project uses 0.15 mm minimum copper clearance, a 0.15 mm track minimum, 0.60 mm minimum via diameter, 0.30 mm minimum drill, and 0.50 mm edge clearance. The narrowest **actual** trace is 0.20 mm. All 200 vias are ordinary through vias. The board has 1,163 track segments and four filled zones. The project changes are confined to routing classes and board minimums.

## Remaining findings and limits

- **The fixed placement still has 12 courtyard overlaps.** Y2 overlaps C11, C13, C16, C17 and R2. Other pairs are J2/J3, J2/J6, J2/D3, J1/FID3, J4/FID2, U3/FID4 and U3/C18. The Y2 body clearance in particular merits an assembly-fit check against the purchased crystal. The two covered fiducials also limit their usefulness after assembly.
- The original 101 warnings remain. They comprise 51 footprint-library mismatches, 37 silkscreen overlaps, eight silk-to-mask clips and five silk-to-edge clips. The full unfiltered check therefore reports **CHECK FAILED**. The baseline comparison reports zero new findings, and a separate refill agrees with the saved copper.
- The project inherited four disabled checks covering footprint type, missing courtyards, and plated or non-plated holes inside courtyards. I kept the original severities and enabled courtyard-overlap checking during verification.
- The board netlist assigns both sides of JP1 to GND and both sides of JP2 to RESET. Opening either jumper cannot isolate those nets on this board. The routing follows those assignments. There is no schematic for an independent circuit comparison.
- The fixed placement makes some bypass paths longer than desirable and the two-layer fanout interrupts the reference copper in places. The layout has not been tested for USB eye margin, ADC noise, regulator temperature or loaded shield-header voltage drop on hardware. Assembly and electrical bring-up remain unverified.
