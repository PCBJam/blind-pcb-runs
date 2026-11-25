# Arduino Mega 2560 (USB-C) – placement and routing notes

Result: `/work/Arduino_Mega_2560.kicad_pcb`, 2 layers, all 49 loose parts placed on F.Cu, fully routed,
GND poured on both layers. KiCad 10 DRC: 0 unconnected, 4 errors – all four are courtyard overlaps between
*locked* parts (J2/J3, J2/J6, J1/FID3, J4/FID2) that are in the board as delivered. Locked parts, outline and
mounting holes untouched (`bt same` ok). Generator scripts for the hand-drawn copper are in `/work/scripts`,
the step-by-step pictures in `/work/progress`.

## Rules (changed, with reason)
The project came with clearance/track minimum 0 and class clearance 0.1 mm – below JLCPCB's standard 2-layer
process. Now: board minimum clearance 0.127, track 0.127, annular ring 0.13, via 0.5/0.3 (unchanged);
Default class 0.2 mm track / 0.15 mm clearance / 0.6-0.3 via; Power class (+5V, VCC, D4-A) clearance 0.2,
default width 0.5 (was 1.0 – every pin connection would have been a neck), vias 0.8/0.4; the power trunks are
drawn 0.8-1.5 mm by hand. Narrowest track on the board is 0.2 mm, smallest gap 0.15 mm, all vias 0.6/0.3 or
0.8/0.4, tented. Hole clearance minimum is back at the original 0.15: the locked USB-C footprint has its own
GND pads 0.19 mm from its locating-peg holes; my copper was routed with 0.25.
JP1 (GND-GND solder jumper) was on the back in the delivered file; it is now on the front like everything else.

## Floorplan
- **U3 ATmega2560** at 179,96, rot 0, between ICSP (J12) and the double-row header J5. This orientation puts
  PA/PC opposite their J5 rows, PE/PH/PB towards the top headers and PL towards the lower part of J5. x is
  pinned by FID1's courtyard, y lines pins 51-75 up with J5.
- **U4 ATmega16U2** between the USB-C connector, its ICSP header J2/J3 and crystal Y2 (crystal tracks 11 mm
  incl. the run to the load caps under the crystal).
- **Power** bottom-left in signal order: J4 → D4 → C1 → U1 → C2, 3V3 regulator U6 above U1.
  USB power: J1 → F1 → Q1 (P-FET) right behind the fuse, comparator U7 and divider RN5 next to it.
- **Reset switch** S1 in the top-left corner (free when a shield is fitted), LEDs L/ON right of RN3, TX/RX right
  of RN4. Silk labels L/ON/TX/RX/RESET-EN were moved to the new positions.
- Decoupling: one 100 n at each VCC/GND pin pair of U3 (C8 W, C13 S, C6 E, C7 N) with <1.5 mm stubs, C18+FB2
  at AVCC, C5 at AREF, C11/C10/C12 at the 16U2's VCC/UVCC/UCAP, C4 at the regulator input, C15 at 3V3.
  U7 has no cap of its own (there is none left in the BOM); it sits 2 mm from J2's +5 V pin.

## Routing approach
Layer use: F.Cu carries the long signal bundles, B.Cu the things that must cross them, plus the +5 V trunks;
both layers are poured with GND and stitched (≈200 vias).
- **ADC0-15** face away from their headers and are in reverse order. They go to vias under U3 (two staggered
  rows) and run as one B.Cu bus under the chip; from there the order matches J10/J9 and nothing crosses.
- **J5** (PA, PC, PG, PL, SPI): F.Cu, direct; even-column pins through the gap below their row. PG2 and PD7
  are out of order on the header and take one via each.
- **J8** (UART1-3, I2C): from vias under U3 on B.Cu. The I2C/UART1 pins come out in reverse order; the
  F.Cu stubs under the chip are stepped so the B.Cu lanes leave in header order.
- **J7/J6** (PE, PH, PB4-7, PG5): 14 F.Cu tracks in three groups round FID1, the mounting hole and J12, then
  lanes under the header row. PG5 and PE3 (out of order) hop on B.Cu, 1 via each.
- **AREF, SCL, SDA** to J6 use the 1.2 mm strip above the top headers (AREF on B.Cu, I2C on F.Cu). 65 mm along
  the board edge; the alternative was crossing all 14 header tracks.
- **SPI/ICSP**: B.Cu legs from U3 to J12, then F.Cu to J5.31-34. **RESET**: U3 → J12.5 → reset cluster
  (C9/JP2/D7/RN5) → S1 and J11.6.
- **USB**: D+/D- 11/16 mm on F.Cu over unbroken B.Cu ground apart from three short crossings at the connector
  (VBUS link, CC1, CC2) and the UVCC feed; no vias in the pair. D+ runs through RN2's middle channel to get the
  pair order right. 0.2/0.2 mm – on 1.6 mm 2-layer FR4 a 90 Ω pair is not practical; full-speed USB over
  16 mm does not need it.
- **+5 V**: 1 mm B.Cu trunk U1/C2 → east → U3 south decap (C13), branch to J12 and to U3's north side
  (FB2, and C8 via a via in its pad); second trunk U1 → Q1/U7/16U2. Under U3 two 0.4 mm links join pins
  80↔10 and 31↔61. **J5 pins 1/2** (shield supply) get their own 0.9 mm F.Cu run from J11.4 along the bottom
  and right edge so shield current does not pass through the MCU's decoupling. VIN: 1.2 mm to U1, 0.7 mm on
  B.Cu under the power header to J11.1.

## Known weak points / not finished
- **Silkscreen**: the delivered board has pin labels for the original layout. With U3/U7/RN3/RN1 where they are
  now, the J8 labels (14-21, TX3…SCL), parts of the J6 row (AREF, 13, 12), "32" at J5 and the POWER bracket
  line land on pads and will be clipped (69 silk-over-copper warnings, 71 silk-overlap). References of Q1 and
  U7 still touch other silk. Needs a manual silk pass.
- **ADC bus under Y1/XTAL pins**: the 16-wide analog bus passes under the 16 MHz resonator and the XTAL pins
  on the other layer (no other way out on two layers with U3 in this spot). Expect a little 16 MHz pickup on
  high-impedance analog sources.
- **Ground under U3** is mostly on F.Cu islands and the caps' vias; the B.Cu side under the chip is taken by
  the ADC bus and J8 lanes. GND pin 32/C13/Y1 share one via west of the bus.
- **Via in pad**: one 0.6/0.3 via in each pad of C8, one in the lower USB-C GND
  pad pair, four in the 16U2 exposed pad (intended). Tented, not plugged – some solder wicking possible.
- **+5 V for U3's north half** (pins 80, 10, AVCC) comes through a 0.6 mm branch ~50 mm long; fine for the
  load (<50 mA) but it is the longest supply path.
- **Power-select cluster** (RN5/U7/Q1/D3/D7, x 120-132, y 85-96) is the least tidy area: DTR to its pull-down
  takes 6 vias and several router-made tracks wander. Electrically slow nets only.
- The +5 V edge run and the I2C/AREF runs are 0.5 mm from the board edge (the rule minimum).
- Not done: teardrops, length matching (nothing needs it), thermal check of U1 (SOT-223 tab has ~1 cm² of
  +5 V copper plus GND pour; with 12 V in and >300 mA it will run hot, as on the original Mega).
- U7's C14/CMP and 3V3 reference lines are long (30-45 mm) thin tracks; they are DC nodes with a cap at the pin.
