# Arduino Mega 2560 (USB-C) – placement and routing notes

Board: `Arduino_Mega_2560.kicad_pcb`, 2 layers, KiCad 10.0.8. Every net is fully routed.

## State of the board

- `kicad-cli pcb drc --severity-all --refill-zones`: **0 unconnected items, 0 clearance / short / edge / hole errors.**
- What DRC still lists, and why I left it:
  - 4 × `courtyards_overlap` – all between locked parts that came that way (J2/J3, J2/J6, J1/FID3, J4/FID2).
  - 51 × `lib_footprint_mismatch`, 43 × `silk_overlap`, 7 × `silk_over_copper`, 5 × `silk_edge_clearance` – warnings that were in the file before I started (board artwork, header silk, library differences). Three or four of the silk overlaps are mine: the D1/D2 outlines touch the "TX"/"RX" text boxes, D7's outline touches the end of "RESET-EN", R1's outline touches the silk line under "POWER".
- Locked footprints, outline and mounting holes are untouched. No footprints added or removed. Only JP1 is on the back (it was already a back-side part).
- 196 vias (0.6/0.3 mm, ten 0.8/0.4 mm on power), 92 of them ground (67 stitching). Tracks: 3.46 m top, 2.03 m bottom. Minimum track 0.2 mm, minimum gap 0.15 mm.
- I did not generate Gerbers/drill files.

## Design rules I changed (project file)

- Default class: 0.2 mm track, 0.15 mm clearance, 0.6/0.3 via. Power class (VCC, +5V, +3.3V, USBVCC, XVCC, AVCC, GND, USHIELD, barrel input): 0.15 mm clearance, widths set by hand per segment (0.25–1.4 mm).
- Board minimums set to JLCPCB standard 2-layer values: clearance 0.127, track 0.15, via 0.5, drill 0.3, hole-to-hole 0.5.
- **Copper-to-edge reduced from 0.5 to 0.3 mm.** Five tracks pass 0.3–0.45 mm from the edge of a mounting hole (ADC6 on the back next to the lower-middle hole, port-A lanes above the upper-middle hole, SCL/SDA next to the top-left hole). Tracks stay at least 0.6 mm from the outer board edge; the ground pours come to 0.3 mm from it. A metal screw head or standoff on those holes sits over masked tracks – use nylon hardware or washers.
- Zone minimum spokes set to 1 (five 0603 ground pads in tight spots only get one spoke; each also has a direct track or via).

## Placement

- **U3 (ATmega2560)** at (138.0, 106.0), 0°. Chosen so that port A/C/G/L pins on its right and bottom sides face the double-row header J5 directly, the ADC pins (top side) drop straight to the analog headers through vias under the package, and the left-side pins wrap to the top headers. It sits as far right as the centre fiducial FID4 allows.
- **U4 (ATmega16U2)** at 90° between the USB-C connector and its crystal: USB pins face the connector, crystal pins face Y2, ICSP pins face J2/J3, UART/LED pins face the MCU.
- USB support parts (CC resistors R3/R4, series resistors RN2, varistors RV1/RV2, UCAP C12, UVCC cap C10, shield bead FB1, polyfuse F1) are between J1 and U4 or directly below J1.
- Power input bottom-left: barrel jack → D4 → C1 → U1 (NCP1117), C4 at U1's input pin, C2 (47 µF) on the output. Q1/U7/RN5/C14 (USB-vs-barrel switch-over) sit next to F1. U6 (3.3 V LDO) and C15 are next to U1's output tab.
- Decoupling: C6 at U3 pins 31/32, C7 at 61/62, C8 at 80/81, C18 (AVCC) + C5 (AREF) + FB2 at pins 98–100, C13 at U4 VCC, C11 at U7. Resonator Y1 and R1 are directly below U3's XTAL pins (traces 2–3 mm).
- LEDs follow the silkscreen labels: D5 right of "L", D1/D2 right of "TX"/"RX", D6 left of "ON". RN3/RN4 (LED and UART series resistors) are beside them. S1 is above the "RESET" label, JP2 above "RESET-EN".
- I kept parts off the existing silkscreen artwork (labels, "MEGA 2560" block, logo outline).

## Routing

Scripted by hand (coordinates in Python via `pcbnew`), except four short nets (GATE_CMD, M8RXD, M8TXD, Net-(D5-A)) that are Freerouting output I kept after checking them. I ran Freerouting several times for the remaining small nets and discarded the rest of its output because it produced long detours.

- **ADC0–15**: short top stubs to vias under U3, then a 0.4 mm-pitch bus on the bottom to J10/J9 in pin order. This is the one large cut in the bottom ground plane.
- **Ports A, C, G, L, PD7, PB0–3 → J5**: top layer, straight lanes and 45° fans, one track between header pin rows. PG2 and PD7 need one via each because their header order differs from the MCU pin order.
- **Top headers**: PH3–6 and PB4–7 run up a top-layer corridor west of the LEDs; PE0/1/4/5, PG5, PE3, RXD2/TXD2 run as a second top-layer group between the LEDs and U3. PG5, PE3, RXD2, TXD2 finish on the bottom (one via each); RXD3/TXD3 need two.
- **SCL/SDA, RXD1/TXD1**: top layer to vias south-east of U3, then straight up the bottom to J8. SCL/SDA continue along the top board edge to J6 and the pull-ups RN1.
- **ICSP (J12)**: SPI runs on the top layer under U3 to three vias, then on the bottom. RESET reaches J12 on a bottom lane under U3's top pin row.
- **USB**: D+/D− at 0.2 mm, under 10 mm from connector to the 22 Ω array, the two connector pad pairs joined right at the connector (D− crosses on the bottom with two vias). No impedance control – full-speed USB over this length does not need it. VBUS pads are joined on the bottom under the connector, then fuse → Q1.
- **Power**: barrel/VCC path 1.0–1.4 mm; +5 V from the regulator: 1.0 mm top to C2, 0.8 mm bottom trunk to the power header, 0.6 mm bottom trunk along the south and east edges to the J5 5 V pins.
- **Ground**: pours on both layers, stitched; explicit vias at the regulator, bulk caps, USB connector, U4 pad, crystal parts and the decoupling caps.

## Things that are not as good as I would like

- **U3's 5 V feed is thin.** The MCU's four VCC pins are joined by a 0.3 mm top-layer link under the package, fed from the bottom trunk through a 0.4 mm spur and one via. Fine for the MCU's own current; the ICSP 5 V pin and FB2/AVCC also hang off this link through pin pads, so do not power a large load from the ICSP header.
- **U3 pins 10/11 have no capacitor of their own** – blocked by the pin fan-out. They share C6/C7/C8 through the internal link (≤ 12 mm).
- **J5 5 V pins** are fed by ~125 mm of 0.6 mm track (≈ 0.1 Ω). Acceptable for a few hundred mA, not more.
- **Bottom ground plane west of U3 is cut up** by the hops between U4, the LED/resistor cluster and U3, and by long RESET runs (west edge, between J2 and J3, under U3). A few ground pads there (RN3, D5, C17, C16, C13, J2 pin 6, U6 pin 2) connect through a dedicated via and short track rather than a wide pour.
- **Vias in pads**: two in U1's tab and two in U4's exposed pad (intended, for current/heat and ground), and the XVCC via overlaps the edge of F1's pad.
- **Y2's load capacitors** connect to the crystal pins through one via each on the bottom, to keep a top-layer lane free south of the crystal can.
- U7 (LMV358) ended up in the power corner, so PB7 and the buffered "L" LED signal each run 15–35 mm; the L signal uses two vias.
- About 75 very short pad-entry segments (< 1 mm) are not at 45°/90°.
- Reference designators are hidden on silk for most parts, as they were in the source file; I did not change that.

## Netlist oddities I routed as given

- JP2 has both pads on RESET, so they are joined by a track (the "RESET-EN" jumper is permanently closed). JP1 has both pads on GND.
- C3 (100 nF) sits from RESET to GND in series with the DTR capacitor C9; I did not question it.
- U6 pin 4 (bypass) is unconnected in the netlist.
