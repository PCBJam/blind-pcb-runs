# NOTES: Arduino Mega 2560 routing (2-layer, JLCPCB standard)

## Status: NOT FINISHED, NOT READY TO ORDER

The board is routed in part. The last `bt check` says CHECK FAILED:

- KiCad DRC: 12 errors, all "courtyards overlap" between footprints that were already placed (C16/Y2, J3/J2, J6/J2, FID3/J1, J2/D3, J4/FID2, and 6 more). Placement is fixed by the brief, so I could not clear them; they are assembly-clearance problems that need parts moved. 101 warnings: silkscreen overlaps and clipping, library footprint mismatches. No copper clearance or short errors.
- 23 signal nets are still open (ratsnest): ADC0, ADC1, ADC3, ADC4, ADC9; PB0, PB2, PB3, PB4, PB5; PH4, PH5, PH6; PE1, PE3; TXD2, RXD2, TXD3, RXD3; PC1, PG0, PG1; and the D6 anode net (Net-(D6-A)).
- GND is in 8 pieces and +5V in 8 pieces (`bt islands`). The GND pour on B.Cu reaches most headers and the MCU's W (pin 11) and N (pin 81) ground pins. Not joined: MCU pins 32 (S), 62 (E) and 99 (AGND); C8.2, C18.2, J12.6, and D6.1. The +5V pour on F.Cu covers only the left-bottom area. MCU VCC pins 31 and 61, and the regulator cluster (U1, Q1, U4 power pins), are not joined to the +5V copper. Until +5V is joined the board would not power up.
- Copper now: 798 segments, 169 vias, 2 zones (`bt check`, `bt length`).

The board file is saved in place and is valid for KiCad 10 (written by bt and pcbnew). The .kicad_pro was changed only by `bt rules` (see Rules below).

## What is done

1. **Rules** (written to Arduino_Mega_2560.kicad_pro with `bt rules`; nothing else in the file changed):
   - Default class: clearance 0.15 mm, then 0.127 mm; track 0.2 mm, then 0.15 mm for new routes (existing 0.2 mm tracks kept). Vias 0.6/0.3 mm.
   - Power class (+5V, VCC, Net-(D4-A)): track 1.0 mm, clearance 0.15 mm, vias 0.9144/0.4064 mm (left as the project had them).
   - Board minimums: clearance 0.1, track 0.1, via 0.5 mm OD / 0.3 mm drill, annular 0.1; copper-to-edge kept at the project's 0.5 mm.
   - Why: JLCPCB's 1-2 layer minimum track and spacing are 0.10 mm (1 oz), and their SMD pad-to-pad guidance is 0.15 mm. The project's 0.1 mm clearance was at the minimum, so I raised it. Later I dropped the default track to 0.15 mm and clearance to 0.127 mm, because the MCU area needed room. Both stay above the 0.10 mm minimum.
2. **Power input:** barrel jack to reverse-polarity diode D4 (10 mm, F.Cu, 1 mm); VCC from D4 to the regulator input, bulk caps and the power header (1 mm, F.Cu, bottom loop). One short branch (RN5.6, a 10k pull-up) is necked to 0.127 mm because it is boxed in.
3. **USB block** (mostly by hand, each step checked with `bt probe` before writing):
   - D+/D-: the two D+ pads of the USB-C connector are joined round the west end of the connector, because an east loop would cross the D- escape. D+ and D- run as traces to the RN2 series resistors, and their 5 pF shield capacitors RV1/RV2 are connected.
   - RD+/RD- from RN2 to ATmega16U2 pins 29/30, routed as a pair with length tuning (skew 0; two small bumps on RD-).
   - CC1/CC2 to their 5k1 pull-downs. USHIELD (shell pads, FB1, RV1/RV2) by hand, with one B.Cu strap along the west edge of the connector. XVCC (VBUS, 0.3 mm) from F1 to a junction west of the connector, then to A9 and A4, passing between the two 0.65 mm connector mounting holes. USBVCC to U4.31, C10 and Q1.
4. **ATmega16U2 group:** ICSP and PB header nets, LED and UART nets, crystal, UCAP (16 nets, router, escapes-first, 25 s).
5. **MCU core:** AVCC, AREF, XTAL1/XTAL2 (with Y1 and R1), PB7. PB1 is connected; PB2 and PB3 are not (see the open list).
6. **MCU buses to the headers:**
   - East bus to J5: PA3-PA7, PG2, PC0, PC2-PC7 (13 of 16 nets, F.Cu preferred). PC1, PG0 and PG1 are open.
   - South bus to J5's lower rows: PL0-PL7 and PD7 (9 of 9; PL4 has a 3.5 mm section necked to 0.127 mm).
   - Top-right: PA0-PA2 to J5's top rows; TXD1/RXD1 to J8.5/J8.6; SCL and SDA (SCL also to J6.1 and RN1). 9 of 11 nets; TXD3 and RXD3 failed.
   - West-top: PE0, PE4, PE5, PG5, PH3 and PB6 are in place. PE1, PE3, PH4, PH5, PH6, PB4 and PB5 are open.
   - ADC: ADC2, 5-8 and 10-15 are in place (11 of 16); ADC0, 1, 3, 4 and 9 are open.
7. **Small local nets:** Net-(D1-A), Net-(D2-A), Net-(D5-A), L13, CMP, GATE_CMD (6 nets, 2 vias). D- second pad (B7) joined through two vias. RESET: all links, after one 82 mm link through the top middle (5 vias). +3V3 (U6.5 to C15, J11.5, U7.6).
8. **Pours:** GND on B.Cu over the outline (solid connection to through-hole pads). GND joins written from `bt islands --fix`: C2.2; the C14/U7.4/C15.1/RN5.4 group; RN3.5; R3.1 and R4.1 groups. Two MCU GND vias (U3.32 and U3.62 spots from `bt via --near`) are not yet connected to the pour. +5V on F.Cu in a box (99-124 x 110-124 mm) for the left-bottom +5V pads.

## Decisions and why

- **Layer use:** F.Cu for most signals and the pin stubs; B.Cu for long horizontal runs (the south bus, the ICSP run, parts of the bundles) and for the GND pour. Signals were routed before the pours, so the pours fit round them. The router prefers F.Cu and uses vias for crossings.
- **Order:** power input, then USB by hand, then the ATmega16U2 group, then the MCU core, then the buses in the order of the crowded areas: east, south, top-right, west-top, ADC. The ADC bus was routed first in a later call, to test whether it could get through the north side. It took 11 of 16 nets, but only by using the west-side corridor, which then cut the west-top bundle.
- **USB and VBUS by hand:** the router's answers used vias and B.Cu diagonals across the connector; the hand plan checked with `bt probe` was cleaner. Two probes caught real problems first: the J1 mounting holes and a D+ clearance.
- **Clearance and track widths:** see Rules above. A narrower default track was tried because the north-west corner had boxed-in pins. It did not clear the blockage, which is topological.

## What is not good

- **Not complete.** 23 signal nets and both power pours are open (see Status). The ADC bus, the west-top bundle (PH4-PH6, PB4, PB5, PE1, PE3), TXD2/RXD2 and the east-corridor nets (TXD3/RXD3, PC1, PG0, PG1, PB0, PB2) compete for the same space in the north-west and east corridors of the MCU. With two layers, I could not find a routing that fits all of them: whichever bundle goes first blocks the other.
- **Long routes:** RESET (174 mm total, 11 vias, including an 82 mm link over the top middle); SCL (132 mm, 6 vias) and SDA (122 mm, 4 vias) as rails along the top; ADC13 (81 mm, 9 vias); ADC10, ADC11 and ADC12 (about 72 mm each); PB1 (66 mm) and PE0 (68 mm). Each of these crosses the board.
- **Vias:** 169 in total, many in the MCU's north and east corridors.
- **MCU power and ground pins:** U3.32 (S) and U3.62 (E) have GND vias that are not joined to the pour; U3.99 (AGND) has no legal via spot within 2 mm (blocked by AREF and ADC copper); U3.31 and U3.61 (+5V) are boxed in.
- **RN3.5** (GND pin of the LED resistor array) is joined, but only through a 2-via detour.
- **D6** (green LED): its anode net is open, and I left its cathode-to-GND join out, to avoid a 17 mm track across the top-right.
- **PL4** section necked to 0.127 mm (boxed-in end).
- **Via annular ring:** the 0.6/0.3 mm via has a 0.15 mm annular ring. JLCPCB's PTH guideline is 0.18 mm absolute and 0.25 mm recommended. I kept 0.6/0.3 mm as their standard 2-layer via, but check this with the fab.
- **Courtyards:** 12 overlaps are in the fixed placement (see Status). Not fixable without moving parts.
- **Silkscreen:** 37 silk overlaps and 5 silk clipped by the edge are warnings I did not clear. `bt silk --fix` would move the reference labels; I did not run it.

## How to finish (suggested next steps)

1. Move the parts that cause the courtyard overlaps (C16 off Y2, J3 and J2 apart, FID3 off J1), if the placement can change. That also frees space in the USB and crystal areas.
2. Give the ADC bus its own plan: pick one escape (west descent or east corridor), reserve it first, then route the top-header bundles round it, perhaps with more B.Cu on the top band. Route the failing nets with `bt route --through` waypoints rather than open search.
3. Join +5V with 1 mm tracks from the regulator cluster to the MCU VCC pins and the header pins, and extend the F.Cu +5V pour where room allows. Stitch GND vias next to every SMD ground pad (`bt stitch` or `bt plane`), then `bt islands --fix` for the remaining GND pieces.
4. Re-run `bt check` until only the courtyard errors remain, then re-review the long nets.

## Files

- `progress/` holds numbered picture and note pairs 001-008 (001 start, 002 USB and U4, 003 east bus, 004 south bus, 005 top headers, 006 west-top, 007 ADC-first attempt, 008 final state).
- `.orig/` holds the untouched original board and project, copied before any change.
- `.scratch/` holds the items files of every routing call (for audit, or for reuse with `bt apply`), the scratch notes and the logs.
- `BT-REVIEW.md` holds my notes on the bt tools.
