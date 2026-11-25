# Six-key macropad fabrication notes

The bare-board order file is `macropad-top-JLCPCB.zip`. It contains both copper layers, both solder masks, both silkscreens, the routed outline with all six LED windows, and separate plated and non-plated metric drill files. The intended order is a single 79.15 × 38.10 mm board in standard two-layer FR-4, 1.6 mm thick, with 1 oz copper and tented vias. The plated drill file includes the USB shell slots.

## Placement and mechanical fit

The USB-C receptacle opens to the left. Its footprint’s PCB-edge line coincides with the straight board edge. The electronics occupy the space between the connector and the first key column and extend below the connector into the power section. The rounded, stepped perimeter reduces the original width by 10 mm. The six switch positions, six reverse LEDs, switch holes and optical windows retain the supplied geometry. All 42 relocated footprints are on B.Cu. BOOTSEL is accessible from the back and has a printed label.

## Routing decisions

- **USB.** Each polarity joins its two reversible receptacle contacts locally, passes through the USBLC6 ESD footprint and its 27 Ω series resistor, then reaches the RP2040 without a layer change. Copper totals on the connector side are 9.35 mm for D+ and 9.29 mm for D−, including the reversible-contact branches. The resistor-to-MCU runs are 1.61 and 2.32 mm respectively. This is a short full-speed USB layout. Controlled differential impedance was not verified.
- **Clock and flash.** The crystal, series resistor and load capacitors form a back-side loop with local ground returns. KEY3 takes a longer route to keep it out of the crystal body. The flash clock measures 12.96 mm. The four data routes span 10.96–14.73 mm. A staggered fanout gives them clearance at the 0.4 mm QFN pitch. BOOTSEL shares flash chip select as drawn in the schematic.
- **Power.** VBUS feeds the fuse, then the regulator and LED load switch. The 5 V class uses 0.50 mm nominal tracks. The two LED rows have 0.60 mm distribution runs and individual local bypass capacitors. The switched rail also supplies the AHCT level shifter. Its output reaches the first pixel in 12 mm on B.Cu. The RP2040 bypass capacitors connect locally before the longer rail connections. Some inner QFN supply pins need a layer change to reach their capacitors.
- **Ground and fabrication geometry.** Both faces have ground pours with solid SMD connections and thermal reliefs on through-hole pads. Ground vias serve the protection device, decouplers, crystal and exposed-pad region. Stitching connects the two faces across the board. Signal routing uses 0.20 mm nominal tracks and 0.16 mm class clearance. The project minimum trace width and clearance are both 0.15 mm. Vias use 0.60 mm copper and 0.30 mm drills. The order assumptions use JLCPCB’s published two-layer, 1 oz process. [JLCPCB capabilities](https://jlcpcb.com/capabilities/Capabilities)

## Verification and limits

KiCad 10.0.8 checked the saved layout with schematic parity and all track errors enabled. The project’s supplied QFN footprint differs from the installed library copy. That warning was present on the original unrouted board. The layout retains the supplied footprint and pad numbering. The fabrication checks cover layout geometry and connectivity. USB enumeration in both plug orientations, crystal startup, flash boot and LED current under firmware control still require an assembled prototype.

The final reports contain zero DRC errors, zero unconnected items, zero schematic-parity differences and one inherited library warning. The saved fills passed the fresh-fill check. All 12 locked footprints retained their original placement and pad nets. The fabrication ZIP contains nine files and passed an archive integrity check.
