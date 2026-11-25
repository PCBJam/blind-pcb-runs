# Macropad layout review

**Select C for the first order.** It keeps a continuous back ground pour through the six-key field, carries the switched LED supply on wide trunks, and keeps through-via drills out of solder lands. Its principal electrical weakness is the last 2 mm of USB routing at the RP2040. A is the runner-up on layout merit, but the saved board has two clearance errors. D has the most compact flash routing. B gives up the most around the oscillator, core bypass and assembly lands.

| Rank | Board | EMI | Signal integrity | Power | Placement | Routing and manufacturability | Overall |
|---:|:---:|---:|---:|---:|:---:|---:|---:|
| 1 | C | 8 | 7 | 9 | null | 9 | **8** |
| 2 | A | 7 | 7 | 8 | null | 6 | **7** |
| 3 | D | 5 | 8 | 7 | null | 6 | **6** |
| 4 | B | 6 | 5 | 6 | null | 5 | **5** |

Overall scores reflect the decision to order a populated product on a standard two-layer process. A's saved-fill defect has a verified, local remedy. D's split LED returns and B's oscillator routing would take copper changes. Placement is null throughout. All 54 footprint references agree across the four submissions in position, rotation and side.

## What was measured

I opened the boards in KiCad 10.0.8, checked the top and key-sheet netlist, inspected the copper renders, and ran DRC with schematic parity and all severities on scratch copies, first as saved and then with zones refilled. The original projects were left intact. Dimensions below are in mm, using KiCad board coordinates with Y increasing downwards.

| Board | Saved DRC errors / warnings | Refilled errors / warnings | Track length F / B | Through vias, total / GND | Saved GND pour area F / B (mm²) | Separate B.Cu fill polygons |
|:---:|:---:|:---:|---:|---:|---:|---:|
| A | 2 / 1 | 0 / 1 | 359 / 589 | 128 / 100 | 2316 / 2066 | 9 |
| B | 0 / 1 | 0 / 1 | 398 / 455 | 107 / 74 | 2322 / 2067 | 1 |
| C | 0 / 1 | 0 / 1 | 570 / 338 | 88 / 52 | 2187 / 2358 | 1 |
| D | 0 / 1 | 0 / 1 | 279 / 599 | 45 / 18 | 2317 / 2020 | 6 |

All eight DRC runs reported zero unconnected items and zero schematic-parity issues. The common warning is a library mismatch at U103 (108.50, 108.00). I compared the placed pad definitions with the installed QFN library. The 57 numbered lands and four paste apertures agree in local position, size, shape, layers and corner ratio. Each board also uses an embedded 3D model. There were no silk-clearance or silk-over-pad findings. All 54 footprint references are hidden on the legend, so assembly and rework depend on the assembly drawing.

Ground coverage below is the fraction of a drawn trace centreline directly over opposite-layer GND copper, including saved fill, lands and GND tracks. I also checked whether particular return pads share contiguous same-layer copper. Vias can join distinct fill polygons electrically while still forcing current around a slot. These geometric estimates locate likely return-path detours. Radiated emissions, impedance and timing remain unverified on hardware.

## Circuit and common constraints

J101 feeds F101 (0.5 A at 88.50, 114.50). The fused rail supplies the AP2112K-3.3 linear regulator U101 and TPS22917 load switch U105. The fast load steps come from the RP2040 and the six PWM RGB LEDs. U106 is the 5 V data buffer. C101, C102 and C119 put a nominal 12 µF directly on the fused input before counting the switched loads. USB attach inrush is worth checking on the first article. The specified LED's typical channel current is 12 mA, giving about 216 mA of instantaneous LED channel load if all 18 channels conduct. The manufacturer specifies 70% grayscale for tricolour operation. This makes switched-current loops and bypass impedance more consequential here than heating of a single LED branch. [LED datasheet, pp. 3, 8](https://datasheet.lcsc.com/datasheet/pdf/0907a34a701b4aef568078003f6e9eae.pdf)

**USB.** All four route full-speed USB on F.Cu with zero data vias, through U102 and the 27 Ω resistors R104 (D+) and R103 (D−). Between U102's lands at x = 97.36 and 99.64 the traces are 0.20 wide and 1.90 apart centre-to-centre, a 1.70 copper-edge gap. They come together to 0.40 pitch at U103.46/47 (105.06, 106.60/107.00). The 1.51 mm FR-4 core separates the two 35 µm copper layers. Coupling and reference change along this short link. A 90 Ω differential impedance claim would require the actual stackup and field calculation. For this 12 Mbit/s device I would spend layout effort on the returns before adding length tuning.

| Board | From J101.A6/A7, D+ / D− | From J101.B6/B7, D+ / D− | GND underneath connector-side /USB_D+ and /USB_D− | GND underneath MCU-side DP and DM |
|:---:|---:|---:|---:|---:|
| A | 10.26 / 12.40 | 9.26 / 9.54 | 63% / 89% | 80% / 77% |
| B | 10.05 / 12.25 | 9.25 / 9.60 | 73% / 91% | 71% / 39% |
| C | 12.07 / 10.77 | 9.25 / 9.50 | 93% / 100% | 0% / 0% |
| D | 9.98 / 11.96 | 9.52 / 9.52 | 84% / 100% | 75% / 55% |

Lengths are approximate contact-to-MCU PCB paths, following each connector branch to its resistor and then the resistor's far pad to the MCU. They include short pad-centre extensions and omit the resistor body, package and cable. The unused reversible contact contributes a short branch. Summing every segment of each branched net would give a misleading plug-orientation skew.

**QSPI and crystal.** U104 is a W25Q128 flash. The four data lengths and clock lengths below are drawn copper. All four boards also extend flash select to BOOTSEL, including a 6.30 connection between the two SW101.1 lands at (111.35, 115.85) and (117.65, 115.85). This is a real appendage to the fast select net and should be included in any ringing check. SW101 also grounds the select output directly when pressed. Its behaviour during a running flash transaction is common to the schematic. The oscillator is Y101 at (115.50, 110.00), with R105 and two 15 pF load capacitors. All its signal copper stays on F.Cu.

| Board | QSPI clock | SD0 / SD1 / SD2 / SD3 | QSPI signal vias | XIN from U103.20 to Y101.1 | U105.6 to D401.3, positive copper only |
|:---:|---:|---:|---:|---:|---:|
| A | 19.86 | 15.10 / 8.21 / 8.30 / 23.13 | 0 | 4.42 | 85.4 mm, ≈76 mΩ |
| B | 19.11 | 14.84 / 10.98 / 10.16 / 24.65 | 2 on SD1 | 4.71 | 91.9 mm, ≈113 mΩ |
| C | 20.10 | 14.62 / 6.99 / 7.31 / 23.47 | 0 | 3.84 | 88.9 mm, ≈56 mΩ |
| D | 18.08 | 14.08 / 6.83 / 6.60 / 21.20 | 0 | 3.89 | 81.1 mm, ≈65 mΩ |

The resistance comparison uses the routed path to the same top-right LED supply pad at (169.35, 115.36), summing length/width at about 0.49 mΩ per square. It excludes vias, component resistances and the ground return. The six LEDs tap the rail at different places, so multiplying that end-to-end resistance by the entire board current would overstate the drop to this LED.

## A — strong local returns, stale production copper

- **EMI · 7/10.** U102.2 has a GND via 1.04 away at (98.40, 106.50). Both crystal load-cap grounds have vias 0.80 from their pad centres. The LED-to-LED data tracks have front ground underneath their entire lengths. The underside supply and data runs divide B.Cu around the LED windows, however. C201.2 (133.03, 113.83) and D201.1 (125.80, 113.86) occupy separate back ground regions, even including GND tracks and lands. The stitches at (134.30, 113.83) and (125.80, 112.50) let that bypass current cross the front. The closest outer-edge track is the LED supply, 0.55 from the outline near (117.70, 127.90).
- **Signal integrity · 7/10.** The crystal has ground under XIN, XOUT and the R105-to-Y101 load network. Flash stays on one layer, and 88% of SCLK has back ground. Two clock crossings lose it for about 1.0 at (102.70, 112.20) and 1.2 at (103.90, 120.85). USB is symmetric on the B-contact run to the resistors, but J101.A7 doubles back at (93.50, 106.75), and the VBUS tie on B.Cu interrupts the D+ reference near x = 95.4. The A-contact path skew is about 2.15.
- **Power · 8/10.** The two LED row feeds use 0.50–0.60 tracks and only two 0.80/0.40 vias on the whole net. The 0.40 section totals 1.86. U101.1 to C102.1 is about 1.96, U101.5 to C104.1 is 2.64, and both cap ground pads have a via 0.80 away. The RP2040 regulator-output path U103.45 to C116.1 takes about 4.28 via (104.05, 104.45), over twice C's path for the same placement.
- **Routing and manufacturability · 6/10.** At (106.85, 110.50) a +3V3 via clears the saved GND fill by 0.2007 on F.Cu and 0.1539 on B.Cu against the zone's 0.2500 rule. Refill removes both errors. Hold the supplied copper until the refill is saved and the production plots regenerated. All tracks are at least 0.20 wide. The 70.6° +3V3 tee at (98.98, 113.30) is a minor detail. More important for reflow, all five 0.30 GND drills in U103.57 land under paste apertures, including (108.25, 108.25). Tenting is selected and neither filling nor capping is specified. Those holes create solder-loss and voiding risk on a standard order.

## B — continuous back ground, poor use of it around Y101

- **EMI · 6/10.** B.Cu is one filled GND polygon, including the region around the six LED cutouts. C201.2 and D201.1 share same-layer ground. The U102.2 return via is only 0.61 from its pad centre at (96.75, 106.50). But /KEY3 and /KEY6 cross under XOUT, and /KEY4 crosses the oscillator load leg by R105/Y101. That leg has no back GND directly below its 3.26 of track. C113.2's nearest GND via is 4.19 away. In the key field, /KEY5 passes just 0.208 from the D201 routed opening at (126.40, 115.67).
- **Signal integrity · 5/10.** /QSPI_SD1 drops at (104.085, 110.413), travels 5.50 on the back, and rises at (104.085, 115.913). It is the only QSPI data line in the four designs that changes layers. SD3 takes 24.65. XIN is the longest of the four and the oscillator output loses more than half its direct back-ground reference. USB has short, via-free routes, but only 39% of the driver-side DM trace is over GND near C116.1 (103.28, 105.75). Its close match from J101's B contacts does little for those discontinuities.
- **Power · 6/10.** The 0.50 VBUS-to-fuse routing is suitable. U105.6 connects to C120.1 in about 1.94. The LED rail is 0.40 throughout and takes eight vias, including three near (100.70, 118.23), (101.95, 119.43) and (102.60, 121.63). It gives the highest positive-path resistance to D401. At the MCU, U103.45 to C116.1 is a good 1.91, but U103.50 (105.06, 108.20) to the physically adjacent C117.1 (103.28, 108.00) takes about 10.56 around the front and back through the shared +1V1 via at (104.10, 105.98). That bypass loop is a larger concern than DC heating.
- **Routing and manufacturability · 5/10.** Saved DRC passes electrically. Two 0.40/0.30 vias leave just 0.05 radial annulus, at U102.2 and on C108.1 (110.90, 107.90). This meets JLCPCB's listed minimum diameter difference, with little process margin. The stitch grid puts 0.30 drills in several solder lands, including D301.1 (145.00, 114.00), D701.1 (169.00, 134.00) and C201.2 (133.00, 114.00). Four more occupy the QFN exposed pad. /LED_EN uses 0.127 width for 12.61, including an 11.17 back-layer segment ending near (101.90, 120.30). A 45° +5V junction at (93.10, 115.90) matters less than the drills in LED and capacitor lands.

## C — best standard-process implementation

- **EMI · 8/10.** Moving the long key runs and LED row trunks mainly to F.Cu leaves the largest continuous B.Cu GND fill. The LED and its local capacitor at D201/C201 share back ground around the cutout. J101's shell is stitched nearby at (95.50, 102.10) and (95.55, 110.72), and U102.2 has its own return at (96.38, 106.50). A local exception is /Key1/DOUT on B.Cu. From (132.80, 112.56) to (138.70, 112.56) it runs alongside the projection of /KEY5 with a front GND gap. /KEY1 comes within 0.55 of the outer edge at (120.19, 100.67).
- **Signal integrity · 7/10.** About 93% of connector-side D+ and all of D− have back ground. Both short MCU-side sections then lose that reference completely between R103/R104 and U103 at x ≈ 103.1–105.1, over the +1V1 routing and C116 area. This is C's first SI improvement. The crystal fares much better. XIN is 3.84 to Y101.1 and all three oscillator nets have continuous underlying GND. QSPI stays on F.Cu, although SD1 and SD3 differ by 16.48 and the clock crosses a 1.81 back-ground gap near (102.64, 114.6). These lengths warrant checking at the intended flash clock and slew rate.
- **Power · 9/10.** Of the LED rail, 132.1 is 0.80 wide. From the row split near (119.45, 123.20) it runs to the LED capacitor feeds, with regular drops such as (152.075, 117.50). Eight vias here serve trunk transitions and distributed taps. The far right LED has the lowest estimated feed resistance. U101.1–C102.1 and U101.5–C104.1 are about 1.96 and 2.61. Their capacitor return vias are within 0.95 of the respective GND pad centres. U103.45–C116.1 and U103.50–C117.1 use separate +1V1 transitions and measure 1.99 and 1.90. The exposed-pad ground travels a little farther than A's direct vias, with the nearest GND via 2.19 from its centre at (108.55, 105.81).
- **Routing and manufacturability · 9/10.** No saved copper errors. The minimum track is 0.20, drills are 0.30, and via diameters range from 0.60 to 0.80. A geometric check found no via drill intersecting a same-net solder land, including U103.57 and the backside capacitors. /KEY6 clears the D301 cutout by 0.318 near (148.84, 116.65). There are 45° branch junctions, for example the USB contact tie at (95.25, 105.75), but ample annular rings and clear solder lands give this board the best assembly margin of the four.

## D — economical signal routing, fragmented LED returns

- **EMI · 5/10.** About 599 of 879 total track length is on B.Cu. The two largest back GND fill regions are 1427 and 461 mm², with four smaller pockets. The 18 GND vias are concentrated at the MCU or in the key field. D201.1 (125.80, 113.86) and C201.2 (133.03, 113.83) lie on different back copper regions. The closest GND via on D201.1's own back region is nearly 13 away at (113.00, 111.75), forcing a large interlayer bypass return. In contrast, the inter-LED data runs have continuous front ground underneath. Input VBUS also has back ground along its entire trace, including the part 0.78 from the outer edge at (88.18, 109.83).
- **Signal integrity · 8/10.** D has the shortest QSPI clock (18.08) and the shortest worst-case data route (SD3 at 21.20). All six QSPI nets stay on F.Cu. The clock does cross back-ground gaps, including 1.20 near (103.13, 120.45). Both crystal pins and the load-cap network stay over GND. The USB B-contact paths match to within 0.02, though the A-contact paths differ by about 1.98. The shared wide gap at U102 and the MCU-side break in DM's back reference remain.
- **Power · 7/10.** VBUS reaches F101 on the front with no via, using 0.35 at the connector and 0.80 on the wider run. Most +5V_LED distribution is 0.60 with only three vias. Several 0.20 sections are local taps, including about 1.75 between D301.3 and its capacitor near (151.2, 115.36). U101.1–C102.1 is 1.96, and the two local +1V1 bypass paths are about 2.0 each. +3V3 is 0.20 throughout all 64.66 of its routing, including the regulator output distribution. C104.2 has same-layer ground back to U101.2, but its nearest interlayer ground via is 7.58 away. The narrow logic supply and the split LED ground loops cost margin under load steps.
- **Routing and manufacturability · 6/10.** Saved DRC passes electrically, and all 45 vias use a standard 0.60/0.30 geometry. However, four GND drills pierce both U103.57 and a backside 100 nF land. For example, (109.00, 108.225) also centres on C111.2. All four align with QFN paste apertures. This saves inductance and via count at the cost of solder wicking on both assembly sides. There are 45° supply tees at (148.75, 117.50) and (121.63, 131.38), and the LED rail clears the D201 slot by only 0.212 near (130.56, 116.44).

The routed-slot and routed-edge capability used here is 0.20. JLCPCB gives a minimum via land diameter 0.10 larger than the drill, with 0.15 preferred. B's two small lands and B/D's closest slot tracks sit at or near these limits. A dedicated filled-and-capped via-in-pad process would change the assembly assessment for A, B and D. [JLCPCB manufacturing capabilities](https://jlcpcb.com/capabilities/pcb-capabilities)

## Human-layout inference

**D, 85% confidence.** The six key signals leave U103 through a tight, individually staggered fan-out into long back runs. VBUS takes a front-only path through the available connector space, the LED trunk changes width at its taps, and several capacitor grounds share the exact drill through the opposite QFN pad. That combination of locally economical decisions and sparse stitching looks like an interactive layout session. C's deliberately repeated row geometry is also plausible human work. Authorship is an inference from the copper and played no part in the scores.
