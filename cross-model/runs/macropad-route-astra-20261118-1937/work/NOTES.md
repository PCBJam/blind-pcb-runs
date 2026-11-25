# Macropad top board

The layout is complete for a standard **two-layer, 1.6 mm FR-4 board with 1 oz copper and tented through vias**. The maximum board dimensions are 89.15 × 38.10 mm. The fabrication archive [macropad-top-JLCPCB.zip](macropad-top-JLCPCB.zip) contains both copper, mask and legend layers, the routed profile, and separate plated and non-plated drill files.

## Routing decisions

| Circuit | Implementation and reason |
| --- | --- |
| USB-C | The duplicate USB 2.0 contacts join at J101. Both data lines run on the front through U102 and their 27 Ω resistors to the RP2040, with zero signal vias. The ESD ground pin has a short connection to the back pour. Both orientations have a short path to the protectors. The connector, SOT-23 array and resistors set the local pair spacing. These are short full-speed USB routes with no controlled-impedance claim. |
| Clock and flash | The crystal, feedback resistor and load capacitors are connected on the front. Each load capacitor has a nearby ground via. All six QSPI nets also stay on the front. The clock is 20.10 mm, and the four data traces range from 6.99 to 23.47 mm. The SOIC pin order accounts for the spread. Chip select reaches the flash before branching to BOOTSEL. |
| Input and MCU power | Both connector VBUS lands feed the input side of the 0.5 A fuse. Wider tracks on the fused side serve the bulk capacitor, 3.3 V LDO and LED load switch. The MCU supply uses a 0.50 mm feed from the regulator area, with narrower branches to the underside bypass capacitors and 0.20 mm escapes at the 0.4 mm-pitch QFN. The 1.1 V regulator output joins its local capacitor before continuing around the bypass cluster to the opposite side of the MCU. |
| LEDs | The switched 5 V supply leaves U105 beside C120, passes around the south end of the flash and splits to two 0.80 mm row feeders. Each LED and its adjacent 100 nF capacitor share a local supply connection. The LED data chain follows the physical package order on the back, crossing between rows at the far right. This keeps the wide supply feed out from beneath the flash bus. |
| Keys | The upper-row GPIOs use the north edge. The lower-row GPIOs use the corridors between the switch bores and the LED windows. Each key input has one layer change. |
| Ground and assembly | Both sides carry connected ground pours with 0.20 mm clearance, solid SMD connections and thermal reliefs on through-hole pads. Of the 88 vias, 52 are ground vias. They connect the QFN paddle, bypass returns, crystal area, USB area and both sides of the LED windows to the fills. The two paddle vias are outside the exposed land. Every via uses a 0.30 mm drill and a 0.60–0.80 mm copper diameter. |

Track widths span 0.20–0.80 mm. The supplied net classes and design rules were sufficient. The selected dimensions fit JLCPCB’s published two-layer, 1 oz trace and through-via capabilities. [JLCPCB manufacturing capabilities](https://jlcpcb.com/capabilities/pcb-capabilities)

## Verification and remaining qualification

- KiCad 10.0.8 reported **zero DRC errors, zero unconnected items and zero schematic parity issues**. The saved fills agree with a fresh refill. The courtyard and track-end-to-via-centre checks also passed.
- The sole warning is the original U103 library-footprint mismatch. The embedded QFN pad positions, sizes and layer assignments agree with the installed library footprint. All 54 complete on-board footprint definitions match the supplied board when serialized by KiCad, including placement, rotation, side, lands and artwork.
- The Gerber profile resolves to one outer contour and six closed LED windows. The drill outputs contain 88 round plated vias, four plated connector slots and 32 non-plated holes. A separate two-sided check found more than 0.12 mm between each via drill and every SMD land’s bounding box.
- Physical bring-up is outstanding. USB enumeration in both plug orientations, boot from flash and operation at full LED load have not been bench-tested.
