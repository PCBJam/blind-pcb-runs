# NOTES — Arduino Mega 2560 clone: placement and routing

## Status: NOT finished, not ready to order

- 27 signal nets are still open: ADC0–ADC15 (16), XTAL1, XTAL2, RESET, PB7, PB5, PB6, PB3, PE0, PE1,
  SCL, PC3. Seven GND pour pieces and six +5V pour pieces are not joined to their pour (listed below).
- Everything else is routed or is a locked footprint. The two pours (GND, +5V) are only partly joined (see Problems 7).
- Locked footprints: unchanged (`bt same` clean). Board outline and mounting holes: unchanged.
- Net classes and rules: Default (clearance 0.15, track 0.2, via 0.6/0.3); Power (+5V, VCC, +3.3V,
  Net-(D4-A), USBVCC, XVCC: track 0.5, via 0.6/0.3). Board minimums: clearance 0.127, track 0.127,
  edge 0.5. Vias everywhere are 0.6/0.3 (JLCPCB standard).
- Pours: GND on B.Cu over the outline, solid connection to all pads (changed from thermal on the
  through-hole pads, which left one starved thermal).
  +5V on F.Cu over the bottom-left power block (box 104–156 × 108–126).
- KiCad DRC (kicad-cli on the saved file): 58 unconnected items; 4 courtyard overlaps between
  locked footprints that were already in the file (J2/J3, J2/J6, FID3/J1, FID2/J4; I may not move
  locked parts); 50 dangling escape vias belonging to the open nets; 1 starved thermal (fixed);
  92 silk-over-copper and 67 silk-overlap warnings (footprint graphics over their own pads; I may not
  change footprint definitions); 51 library-footprint mismatch warnings.
- `bt check`: CHECK FAILED — 58 unconnected items, 29 nets in pieces (the 27 signal nets and the
  GND and +5V pour pieces).

## Placement (what is where, and why)

- ATmega2560 (U3, TQFP-100) at (177, 104), rotation 0, on the top side. Its east edge (PA/PC/PG) faces
  J5, the 30-signal header; its west edge faces J12 (ICSP), its north edge carries the ADC pins, its
  south edge the PL/PD/XTAL/RESET pins. Chosen because J5 is the biggest group and the only free space
  next to it is the strip between the TQFP and J5. The trade-off is that the ADC pins face away from
  J9/J10 (see Problems).
- ATmega16U2 (U4, QFN-32) at (126.5, 96.5), rotation 90: D+/D− (pins 29/30) face the USB connector on
  the west, the crystal pins face Y2 on the south, the ICSP headers J2/J3 are on the north.
- Crystal Y2 is locked. C16, C17 (22 pF) and R2 (1 MΩ) sit north of it, beside the 16U2.
- Power input: barrel jack J4 (locked), D4 reverse-polarity diode to the north of it, C1 47 µF input,
  U1 NCP1117-5.0 at (131, 117) rotated so its input faces the barrel side, C2 47 µF output, C4/C13
  decoupling, U6 LP2985-3.3 and C15 by J11 (the +3.3 V pin).
- USB: RV1/RV2 (ESD varistors) and FB1 (shield ferrite) and R3/R4 (5k1 CC pull-downs) beside J1;
  F1 fuse toward VBUS; RN2 (22 Ω) between the connector and U4; C10/C12 on the 16U2's supply pins.
- Reset: S1 at (119.5, 122.5) (clear of J11), C3, C9, D3 (moved to (132, 90.5)), D7, JP2 near J11.
- LEDs: D1/D2 (TX/RX) and D5 (L), D6 (power), and RN3/RN4/RN1/RN5 kept east of the 16U2 so that its
  pins keep a way out (the first trial had them walling the 16U2's east pins).
- 2560 resonator Y1 and feedback resistor R1: moved from under the TQFP's south edge to (165, 118) and
  (161.2, 118), where the crystal lanes can run west away from the PL lanes. This did not help the
  crystal routing (see Problems).
- JP1 (both pads GND) moved from B.Cu to F.Cu.
- TQFP decoupling: C6 (south), C7 (west corner), C8 (east corner), C11 (north-east); AREF/AVCC parts
  C5, C18 and the ferrite FB2 in the north-west corner. C5/C18/FB2 are in the path of the ADC bus
  (see Problems).

## Routing approach

- The TQFP escape: `bt fan U3 --dogbone --via-size .6,.3 --width .2`, one side at a time (N, E, S, W),
  each side seeing the copper of the sides before. 66 vias; the GND pins got their own vias, the VCC
  pins did not (they have stubs only).
- The 16U2 escape: `bt fan U4 --dogbone`, 14 vias, 18 nets.
- Signal routing: `bt route --nets ... --order escapes-first --passes 2` for groups (16U2/USB/LED
  group: 27/29 then SCK2 fixed by hand; the serial/I2C group to J8: 7/8; the west-face group: 11/16;
  small nets: 4/8; power nets: 5/6). The J5 bundle was routed in several orders on scratch copies; the
  best result (28/29) was kept.
- Power: +3.3V, USBVCC, XVCC, Net-(D4-A), VCC routed as tracks. +5V did not route as tracks; a +5V
  pour on F.Cu was added instead, and the GND pour on B.Cu. `bt route --net GND --all` joined 34 of the
  41 GND pieces to the B.Cu pour (26 vias); the +5V pour joined most of its F.Cu pieces.
- Dead ends from failed routes were removed with `bt cleanup --dead`.
- Locked and unlocked parts were checked with `bt same` after every stage.

## Decisions and why

- Board stays 2-layer, JLCPCB standard materials: 0.2 mm signal tracks, 0.5 mm power, 0.6/0.3 vias,
  clearance 0.15 (above the 0.127 mm minimum the fab quotes).
- All parts are on the top side. JP1 was on the back at the start and was moved to the top.
- The TQFP is at the east, against J5: J5 needs 30 signals, more than any other header, and the
  alternatives (TQFP rotated 90°/180°/270°) moved either the J5 group or the ADC group onto the far side.
- The 16U2's ICSP and LEDs were kept off its east pins so the escape keeps a way out.
- D3 (RESET2 clamp) moved off the 16U2's north exit, which had walled in PB7 of the 16U2.
- GND pour on B.Cu with solid connections: fewer thermal reliefs for the router to fight, and the
  starved-thermal DRC error went away.
- Y1/R1 moved away from the TQFP's south edge, which had no room for them.

## Problems that are not done or not good

1. ADC0–ADC15 unrouted (16 nets). Cause: the ADC pins are on the north face of the TQFP, but J9/J10
   (the ADC headers) are at the bottom of the board. The bus has to go round the TQFP through the
   north-west quadrant, which the west-face nets (to J6/J7, top) also need. Attempts: B.Cu only (4/16,
   the N face exits on F.Cu for ADC1); both layers after the west-face lanes were moved (10/16); an
   outside-only escape (only every other pin gets a via in one row). A layout that should work was
   designed but not built: F.Cu risers from each ADC pad, then B.Cu lanes at staggered heights, which
   needs C5/C18/FB2 moved out of the bus area first. The ADC8–15 lanes also have to reach J9 on the
   far side, through the south-east corner, which is already full.
2. XTAL1/XTAL2 unrouted: the crystal pins on the TQFP south edge are boxed in by the PB0–PB2 lanes
   (the J5 bottom pins and the J12 ICSP pins share those nets). Y1/R1 were moved, but the crystal lanes
   still cannot get out.
3. RESET and PB7 unrouted: long nets from the south edge to J11/J6; blocked by the same south-edge lanes.
4. SCL unrouted: its TQFP pin (PD0) is boxed in on the south edge by the vias of PL7, SDA, RXD1 and
   TXD1; there is no way north to J8.8 or west to J6.1 except through the crowded corners.
5. PE0, PE1, PB5, PB6, PB3 unrouted: west-face pins. SDA was routed earlier by the serial/I2C group
   as a diagonal B.Cu track through the TQFP interior, which cuts across the west-face pins. SDA should
   be re-routed around the outside of the TQFP.
6. PC3 unrouted (J5 pin 15). The routes of PC2 and PC4 go round the inside of the TQFP ring because
   the cluster at PC0/PC1/PG0/PG1/PG2/PD7 blocks the way out. Not ideal: those detours sit inside the
   TQFP and use up the interior.
7. Pour pieces not joined: GND 7 pieces (the 16U2's GND pins U4.3/U4.28/U4.33 and the decoupling
   caps C12, C8 etc., boxed in by their neighbours); +5V 6 pieces (TQFP VCC pins 10, 31 and 61; RN3.1;
   C8.1; J12.2). The +5V pour is only partly joined.
8. The escape vias of the open nets (50) are dangling in DRC. They are kept so that the open nets can be
   routed from them later.
9. JP2 has both pads on RESET and JP1 both on GND, as the netlist has them. Left as drawn.
10. Silkscreen warnings: footprint graphics overlap their own pads (92 + 67). Only references were moved
    (`bt silk --fix`, two moved). Cannot be fixed without changing footprints.
11. The lengths of the escapes into the J5 gap are long, and several tracks take 90° or wide detours;
    nothing was length-matched (no differential pairs here).
12. Not checked against the JLCPCB DFM rules beyond the rules set above.

## Suggested next steps (in order)

1. Move C5, C18 and FB2 out of the north-west corner, then route the ADC bus with a hand-planned
   staircase (F.Cu risers, B.Cu lanes), first to J10, then to J9.
2. Re-route SDA outside the TQFP, then the west-face pins (PE0, PE1, PB5, PB6, PB3).
3. Give the crystal its own lanes: move the PB0–PB2 lanes off the south-west corner, then route XTAL1/2.
4. Route RESET, PB7 and SCL once the corridors are clear.
5. Join the remaining GND and +5V pour pieces with stitching vias (`bt stitch`, or `bt via --near`).
6. Re-run `bt check` and kicad-cli DRC; re-run `bt same`.

The progress log in /work/progress/ (001–011) has the picture and reasoning for each step, including
the failed attempts (the J5 corridor variants in 006, the ADC variants in 010).

## Files

- `/work/Arduino_Mega_2560.kicad_pcb`: the board (saved; opens in pcbnew and kicad-cli).
- `/work/.bt-undo/`: bt's own undo copies of the board (the last 20 writes); `bt undo` restores one.
  Delete the folder if you do not need them.
- `/work/progress/`: numbered pictures (`NNN-*.png`) and notes (`NNN-*.md`), 001–011, including the
  failed attempts.
- `/work/BT-REVIEW.md`: review of the `bt` tools used on this board.
