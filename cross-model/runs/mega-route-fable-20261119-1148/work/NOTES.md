# Arduino Mega 2560 (USB-C variant) – routing notes

Board file: `Arduino_Mega_2560.kicad_pcb` (KiCad 10), rules in `Arduino_Mega_2560.kicad_pro`
and `Arduino_Mega_2560.kicad_dru`. Placement is untouched (`bt same`: nothing moved, added or
removed, pad nets unchanged).

## State

- All 152 nets connected, 0 unconnected items.
- KiCad DRC on the saved file: **nothing new** compared with the board as delivered. The 113
  items that remain were there before routing and come from the placement and footprints:
  51 library-mismatch warnings, 50 silkscreen warnings, 12 courtyard-overlap errors
  (C16/Y2, J2/J3, J2/J6, FID3/J1, J2/D3, J4/FID2, …). I did not touch silkscreen or footprints.
- 3.11 m of track on F.Cu, 1.53 m on B.Cu, 221 vias (197 × 0.6/0.3 mm, 24 × 0.8/0.4 mm),
  GND pours on both layers, 94 of the vias are ground stitching.
- Not done: no Gerber/drill export, no JLCPCB DFM upload, no signal-integrity simulation.
  The checks I ran are KiCad's DRC and connectivity only.

## Rules (changed, and why)

The project came with 0.1 mm clearance and no minimums, which is below what JLCPCB builds.

| | was | now |
|---|---|---|
| board minimum clearance / track | 0 / 0 | 0.15 / 0.15 mm |
| minimum via / drill / annular ring | 0.5 / 0.3 / 0.1 | 0.6 / 0.3 / 0.13 mm |
| hole-to-hole | 0.25 | 0.5 mm |
| Default class | 0.2 track, 0.1 clearance | 0.25 track, 0.2 clearance, 0.6/0.3 via |
| Power class | +5V, VCC, Net-(D4-A); 1.0 track | + GND, USBVCC, XVCC, +3.3V, AVCC; 0.5 track, 0.2 clearance, 0.8/0.4 via |

- Everything routed is at or above 0.2 mm track / 0.2 mm gap; zone clearance is 0.25 mm.
  That leaves margin over JLCPCB's 0.127 mm.
- Hole clearance: tracks and vias keep 0.25 mm from every hole (rule in the `.kicad_dru`).
  The board-wide floor is 0.19 mm only because the USB-C land pattern has its locating pegs
  0.194 mm from its own ground pads; a custom rule cannot relax a board minimum, so I lowered the
  floor and tightened routed copper instead.
- Power-class nets are narrower than 0.5 mm where they enter fine-pitch pins or feed a single
  small load (0.25–0.4 mm). KiCad does not flag that; it is deliberate.

## Approach

Two layers, so the plan was: F.Cu carries the signals and most power, B.Cu is ground with as
few, as short and as bundled crossings as the pin-outs allow, GND poured on both layers.

I worked the netlist out by hand first (which header pin each MCU pin goes to, and where the
orders disagree), then generated almost all copper with small scripts as explicit ordered lanes
with 45° corners, checked every batch against the board before writing it. The autorouter in the
supplied tool was only used for a few simple B.Cu links.

### ATmega2560

- **North pin row (ADC0–15, to J10/J9 at the bottom edge):** the only way is under the chip.
  The 16 pins go inward, fan from 0.5 to 0.61 mm pitch into two staggered via rows, and run south
  as one 0.2 mm / 0.2 mm bus on B.Cu, kept east of the XTAL pins. One bundle rather than 16
  scattered crossings.
- **East side (ports A, C, G, L to J5):** F.Cu lanes in J5 pin order, 0.25 mm at ≥0.45 mm pitch,
  one track per header pad gap. Two nets are out of order at J5 (PG2, PD7); each has one via and a
  short B.Cu hop next to the header.
- **UARTs and I2C to J8:** the header order is opposite to the pin order, so these cross on B.Cu.
  UART2/3 leave from vias inside the chip in J8 order; UART1 and I2C follow the south bundle on
  F.Cu and then run straight north on B.Cu, each under its J8 pin. SDA/SCL carry on from J8 to J6
  along the top edge between the header pads and the board edge (0.2 mm, the only free way).
- **West side (to J6/J7):** a 14-lane F.Cu nest. PE3/PG5 are out of order at J7 and drop through
  a via under the other lanes. PE0/PE1 also go to the USB bridge's series resistors on the far
  side of the nest, by a B.Cu hop.
- **SPI/RESET to the ICSP header:** F.Cu lanes across the inside of the footprint, over the ADC
  bus, then short B.Cu links to J12. PB0–3 also go to J5.31–34 as the outermost lanes of the south
  bundle.
- A fiducial (FID4) with 1 mm clearance sits in the middle of the MCU footprint; the interior
  lanes are planned around it.
- **Resonator:** XTAL1/2 as a pair on F.Cu, with the MCU's own ground pin 32 routed alongside to
  the resonator's ground pad and tied to the plane by a via.
- **Decoupling:** C8 → pin 10 and C7 → pin 80 are pin–cap–via in that order. AVCC is
  FB2 → C18 → pin 100 with C18's ground via beside it.

### USB and the ATmega16U2

- D+/D− leave the connector on F.Cu straight into the 22 Ω array and on to the 16U2 as a pair,
  about 9 mm, over unbroken ground except where the D− jumper passes. The four data pads of a
  USB-C receptacle interleave, so one of the "flipped" pads (B7) needs a 6 mm B.Cu jumper; B6 is
  joined behind the pad row. No impedance control: full-speed USB over under 20 mm on a 1.6 mm
  2-layer board.
- VBUS: the footprint's pegs block every F.Cu way around the pad row, so both VBUS pad pairs
  leave through the gap under the CC resistors, drop to B.Cu and run under the connector shell to
  the fuse (0.5 mm, two 0.8/0.4 vias at the fuse).
- Crystal, UCAP, LED and UART-resistor nets are short and on F.Cu. Four vias in the exposed pad.

### Power

- Barrel jack → D4: 1.2 mm. VCC: 1.0–1.2 mm on F.Cu (it loops round the regulator because the
  input capacitor sits on the output side of it); 0.7 mm along the bottom edge to the VIN pin.
- +5V: regulator tab → three in-pad vias → 1.0 mm B.Cu → the USB power switch (Q1) and the
  16U2's supply; regulator pin → 1.0 mm F.Cu lane → C2 → 0.8 mm to the 5V header pin.
- From C2, +5V reaches the rest as a tree, not a plane: a 0.8 mm B.Cu spine north to the 3.3 V
  regulator and RN4, a 0.8 mm trunk to FB2/AVCC and a bar under the MCU's north row to C7, then a
  0.8 mm F.Cu lane along the top to the 5V pins of J5 and the I2C pull-ups; a second 0.6 mm
  trunk from C6 to the MCU's south and west supply pins.
- 3.3 V: 0.5 mm to its header pin (B.Cu), 0.3 mm to the comparator.

### Ground

- Pours on both layers, 0.25 mm clearance, thermal reliefs on through-hole pads only, isolated
  islands removed. The fill is one piece.
- Every decoupling capacitor and every SMD ground pad has its own via beside it.
- 94 stitching vias on a 3 mm grid, minus those under the crystal or beside SMD pads.

## What is not good, or not finished

1. **B.Cu is not a solid plane.** It has slots: the 6 mm ADC bus under and south of the MCU,
   the four UART runs north-east of it, the UART1/I2C runs to J8, a DTR/RESET2 slot east of the
   16U2, and the +5V trunks. F.Cu lanes cross these slots. For a 16 MHz AVR this is how the
   original board works too, but return paths are not ideal and I did not measure or simulate
   anything.
2. **+5V is long and thin towards the north and east.** The J5 5V pins, C7/pin 80 and the I2C
   pull-ups are roughly 110 mm from C2 through 0.8 mm track (about 0.1 Ω by my estimate, not
   measured). MCU pin 61 is fed by a 0.4 mm lane across the inside of the footprint and has no
   capacitor near it; C6 is 13 mm from pin 31. The capacitor positions are the placement's.
3. **Long single-ended runs on B.Cu:** AREF 35 mm (the AREF capacitor is at the header, not at
   the MCU); RESET 129 mm in total, 73 mm of it on B.Cu along the west board edge to reach the
   button in the top-left corner (it has 100 nF to ground); the RESET2 pull-up branch about 30 mm.
4. **ADC lines** run 0.2 mm wide at 0.2 mm spacing in parallel for 15 mm and more, so adjacent
   channels will couple. The resonator tracks are 15 mm long and have SPI and +5V crossing under
   them on B.Cu.
5. **Vias in pads:** three in the regulator tab, four in the 16U2 exposed pad. They are tented
   on the back, but solder can still wick; if that worries the assembler, ask for them plugged.
6. **USB:** not impedance-controlled; D− carries a jumper branch (D+ 9.1 mm, D− 14.2 mm including
   it); RD+/RD− differ by 1.8 mm. Fine for full speed, would not do for high speed.
7. **Thermal reliefs:** spoke 0.45 mm, gap 0.3 mm, chosen so the header ground pins get two
   spokes. J12 pin 6 is solid-connected on F.Cu through a small extra zone; J6.4 and J2.6 are
   still tightly boxed in on F.Cu and rely mostly on B.Cu.
8. **JP1 and JP2** have both pads on the same net in the netlist, so the copper joins them; as
   routed they are not jumpers. JP2's pads are bridged by a track.
9. No teardrops. No silkscreen clean-up: reference texts were not moved and some will sit on
   vias (tented).
10. SDA and SCL run side by side for 65 mm along the top edge, 0.25 mm apart, with only a thin
    strip of pour next to them.

## Files

- `Arduino_Mega_2560.kicad_pcb` – routed board, zones filled and saved.
- `Arduino_Mega_2560.kicad_pro` – only board minimums and net classes changed.
- `Arduino_Mega_2560.kicad_dru` – one rule: routed copper keeps 0.25 mm from holes.
- `progress/` – numbered pictures and notes, including the attempts that were thrown away.
- `BT-REVIEW.md` – review of the `bt` tool.
