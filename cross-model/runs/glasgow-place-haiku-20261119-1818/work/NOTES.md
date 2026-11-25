# Glasgow 4-layer board — layout notes

**Status: NOT FINISHED. The board is not ready to order.**

- Placement: complete. Every unlocked part is on the board inside the outline (0 off-board), with decoupling and passives placed by pin.
- Routing: partial. `bt ratsnest` reports **161 nets not fully connected (2312 mm of ratsnest)**. The largest open groups are listed under "Open items" below.
- DRC (KiCad 10, project rules): **0 shorts, 0 clearance errors, 0 hole-clearance errors.** The only errors are 4 `footprint_type_mismatch` (U1, J1, U8, U36): the supplied footprint definitions mark SMD parts that carry through-hole thermal vias as "SMD". I did not change footprint definitions. 11 courtyard overlaps are between locked parts (FID/MK/J2/J3/J5/J6), also from the supplied layout. Other items are warnings: silkscreen text clipped by pads (pin labels inside the library footprints), library footprint mismatch, 33 dangling stubs of partly routed nets, 5 dangling vias, and text heights of library fields.
- Locked parts: `bt same` against the original board: nothing locked moved, no parts added or removed, pad nets unchanged.
- Outline: unchanged (50,71 → 130,120, rounded corners).
- Project file: only the net classes changed (see "Net classes").
- Board size: 434 vias, 1350 track segments, 2 zones (GND on In1.Cu, +3V3 on In2.Cu).

## Placement

- **FPGA U30 (iCE40, BGA-121)** at (83, 98), rot -90. Its Z-port row (B1..K2) is on the top edge toward J5, its FX2-interface column (L/K/J/H) on the left, bank A on the right and bank B on the bottom. This orientation was taken from the ball map: it puts each group on the side of the package its connector is on.
- **FX2 U1 (CY7C68013A)** at (66, 96), rot 0. Moved up 2 mm from (66, 98) after the first bus attempt (see below). USB D+/D- on the left edge facing J1.
- **Port A IO** (connector J2 at top right, DNP sockets J8/J9): 8 SN74LVC1T45 level shifters on the F side in two rows at rot 180 (their DIR pin, which carries the FPGA's DA line, faces the FPGA; A/B face up toward J2). Port B (connector J3 at bottom right): 8 level shifters on the B side at rot 180 (DIR faces the FPGA; A/B face down toward J3). Reason: the SN74LVC1T45 has DIR on the opposite side of the package from A and B, so the rotation is chosen per port to put DIR toward the FPGA.
- **RN networks** (33 Ω, RN1..RN12) on the B side next to their buffers; **ESD arrays** D20..D23 next to J2/J3.
- **Port power** (LDOs U14/U31, DACs U13/U20, INA233 U12/U21 and their shunts/filters) in the right strip, F and B. PCA6408 expanders U19 (Port A, next to DNP socket J9) and U5 (Port B, right strip).
- **Crystal Y1** and its 9 pF caps at the top-left of the FX2. **USB**: U15 (USB power/data tap) on the B side under the connector, CC resistors R52/R53 on the B side, FB1, C13, R3 and C8 round J1.
- **Decoupling**: about 90 capacitors (87 assigned by pin, one per power sink), placed with `bt near --each` on the B side. FPGA power caps are not under the ball field (that field needs the B-side dog-bone vias); they sit in a strip above the FPGA.
- **Status LEDs and their resistors** (all 12 LEDs, D1..D10, D14, D15): a block on the B side above J5 (the top-left corner of the board), each LED with its resistor in the row below it. Test points beside their nets. Reset switch SW1 at the bottom edge; EEPROMs U2/U3 and reset supervisor U7 at the bottom left.

Why the layout is so tight: the locked connectors leave about 2000 mm² for ~230 parts. I used the B side for passives and decoupling wherever the F side was taken, and kept routing corridors clear by hand (see the progress log).

## Layer stack use

- **In1.Cu = GND**: one zone over the whole board. Surface-mount GND pads: 193 of 206 got one via each (placed one at a time with `bt via --near`); most of the 13 that had no spot within 2 mm were retried at 5 mm, and 8 GND pad groups are still open (see Open items). Through-hole GND pins connect through the plane by thermal reliefs.
- **In2.Cu = +3V3**: one zone over the whole board. Each +3V3 surface-mount pad has a via (78 placed; 15 +3V3 pad groups still open, see below).
- **In2 islands for +1V2, VIOA, VIOB** were tried and removed. Each island covered +3V3 pins (FPGA VCCIO balls, the buffers' VCCA pins) and cut them off from the +3V3 plane. A finger/comb version for VIOA was also tried; every via spot for the buffers' VCCB pins was already blocked by copper, so it was removed too.
- **F.Cu and B.Cu**: all signals and the short power connections.
- **Inner signal layers** were allowed for some routes (`--layers F.Cu,B.Cu,In2.Cu`) but this did not unblock any route, so the planes are unbroken except for the via antipads.

## Net classes and rules

- `Default`: track 0.15 mm, clearance 0.15 mm, via 0.45/0.2 (was 0.6/0.3).
- `Power` (+3V3, GND, +1V2, VIOA, VIOB, VIO_AUX, +5V, VUSB, xVBUS): track 0.25 mm, clearance 0.15 mm, via 0.5/0.25.
- `USB` (USB_P, USB_N): class track 0.45 mm and pair 0.45/0.15 were set, but the connector and FX2 pins (0.5 mm pitch) only let a 0.3 mm pair escape, so the routed pair is 0.3 mm (see "Known problems").
- Board minimums unchanged.

## Routing done (what is connected)

- **USB**: J1 A/B pins bridged (B6 to A6 on F.Cu; B7 to A7 with two B.Cu vias); D+/D- pair 0.3 mm, 6.2 mm, skew 0.05 mm, FX2 pins 8/9; U15 D+/D- taps (B.Cu, one via each); TP15/TP16 links; CC1/CC2; VBUS/VUSB/xVBUS; shield (three F.Cu links plus one B.Cu link). All connected.
- **FPGA escape**: `bt fan U30` on F.Cu/B.Cu, 91 of 101 escape nets (the 10 others are listed below). Power balls go to the planes.
- **FX2 control/bus**: 12 of the 24 FX2-to-FPGA nets connected (D2, D7, WR, A0, A1, PKTEND, OE, FLAGA, ~ALERT, FPGA_DONE, ~FPGA_RESET, ~CY_RESET). The other 12 are open (D0, D1, D3..D6, FLAGB..D, RD, CLKIF, CLKREF). See "Open items".
- **Z-port (J5 ↔ FPGA)**: 7 of 13 differential pairs connected (Z11, Z9, Z6, Z5, Z1, Z4, Z0). Z4 has a 4.8 mm skew and Z0 0.6 mm; these are not tuned. Z2, Z3, Z7, Z8, Z10, Z12 are open.
- **IO banks**: 48 of 105 bank/buffer nets connected in the single-pass run. Still open: Port A 23 nets (DA/QA lines, several X/Y/Z/P bits, VSENSE); Port B 31 nets (most of its Z and P lines, DB/QB lines).
- **Planes**: GND 8 pad groups open (of ~200); +3V3 15 groups open (buffer VCCA pins, FX2 pins).

## Open items (not finished, in order of impact)

1. **VIOA, VIOB (buffer VCCB pins, DNP sockets, connector VIO pins), +1V2 (FPGA core and U36 output), VIO_AUX (FPGA banks 3 and J5.44) and +5V (regulator inputs)**: nothing routed. The VIO pins of each buffer sit 1.9 mm from its +3V3 pin on the same edge, and the DA/QA routes and decoupling caps have filled the space around them. Every route attempt was walled in by copper already on the board.
2. **FX2 data bus D0..D6 and FX2 control CLKIF, CLKREF, RD, FLAGB/C/D, SCL, SDA**: open. The FX2 bottom-edge bus pins had to reach the FPGA's inner balls H7/J7/J9/K10 through lanes that the escape stubs of other nets (D7, FPGA_DONE, I2C, PLL, and fan-out GND vias) had already taken. Removing and re-routing one net at a time (D2, D7, FPGA_DONE) moved the problem rather than solving it.
3. **Z-port pairs Z2, Z3, Z7, Z8, Z10, Z12**: the FPGA's top-row Z balls are boxed in by the fan-out stubs of the pairs already routed.
4. **Port A/B bank nets (about 40)**: the Port B Z and P lines to J3 pass through a ~2 mm channel between the bottom-side buffers and the J3 pin row, shared with 8 RN networks.
5. **Status and misc signals**: LED_CY/LED_FPGA/LED_ACT/LED_ERR and ENVA/ENVB (FX2 top edge to the LEDs), I2C SCL/SDA (13 groups each), SYNC, VSENSE, ISNS_H, VDAC, VIO_EN, PCA6408 P-lines, XTALIN/XTALOUT (crystal and load caps).
6. **Planes**: 15 +3V3 pad groups (FX2 pins 11/17/32/55, several decoupling caps and buffer VCCA pins) and 7 GND groups (FPGA GND balls in the centre and decoupling caps) have no via yet. A via could not be found within 5 mm for most of them.
7. **Dangling stubs**: 33 track ends and 5 vias belong to partly routed nets. They are kept so the work is not lost; they will go away when the nets complete. `bt cleanup --dry` lists them as "work in progress".

## Known problems I am not happy with

- **USB impedance**: the connector-to-FX2 pair is 0.3 mm with a 0.15 mm gap. That is about 110 ohm differential on the 0.48 mm dielectric, against 90 ohm. The 0.45 mm width the stackup needs cannot escape the 0.5 mm pin pitch at either end. The pair is short (6 mm) but this is a deviation.
- **USB stubs**: the U15 taps are 5 to 7 mm on the B side with one via each, and the connector bridges are 2.8 mm loops round the connector's left side. That is not what I would ship.
- **Decoupling distance**: several FX2 decoupling caps were moved to the strip above the FX2 (about 10 mm from their pins) to clear the bus corridor. They connect through the +3V3 plane, so they are a weaker high-frequency decoupling solution than the caps next to the pins.
- **FPGA interior vias**: 44 vias sit inside the BGA box: the fan-out's own, plus GND/+3V3 vias that my per-pad loop added. I removed 9 redundant GND vias on FPGA balls (the fan-out already connected those balls); 1 was put back at E6. The interior is still crowded. A designer would have reserved the escape corridors before placing the ground vias.
- **Stackup**: the given stackup (0.48 mm dielectrics) makes 0.15 mm tracks about 110 ohm single-ended. I kept it because it is given; a 0.2 mm prepreg between F and In1 would be the normal choice for a 4-layer board this dense.
- **Silkscreen**: text clipped by pads and the 'Glasgow' footprint library warnings come from the supplied footprints.

## Decisions and why

- **Rotated the IO buffers per port** (see Placement), because DIR is on the opposite side of SN74LVC1T45 from A/B.
- **Moved the FX2 up 2 mm** (66, 98) → (66, 96). The bus pins are then level with the FPGA's west exit lanes. At the original position the bus crossed the control lanes and nothing routed. The move cost the USB pair and a few small parts, which I re-routed and re-placed.
- **Put the FPGA power decoupling in a strip above the FPGA** (B side) and kept the B side under the ball field free for dog-bone vias. The first fan-out gained 22 nets (69 → 91) after that.
- **Solid planes instead of islands** for everything except GND: the island approach broke +3V3 pins at the FPGA and buffers.
- **One via per SMD ground/+3V3 pad, placed sequentially** (`bt via --near` applied one at a time). A batch placement would have clashed.
- **Kept the partial routes** instead of cleaning them up, so no finished work is lost.

## Next steps (what I would do next)

1. Re-place the Port A/B buffer blocks so each buffer's VCCA and VCCB pins are on different edges (or give each VIO pin its own track to a corridor). Then route VIOA/VIOB as copper on In2 with islands that exclude the +3V3 pins, or as 0.4 mm tracks.
2. Move the Port B RN networks off the buffer-to-J3 channel and give the Z and P lines a dedicated corridor.
3. Re-plan the FPGA's west and inner escape before routing the FX2 bus: reserve lanes for D0..D7 and the PLL/I2C stubs, and keep GND/+3V3 vias to the perimeter balls.
4. Route the rest with `bt route --passes 3` in small groups (each group took 5–20 minutes here), then `bt fill` and `bt check`.

## Files

- `progress/001..008` — placement, FPGA escape, USB, IO banks, planes/vias, final overview and FPGA area.
- `scripts/` — the helper scripts used: `assign_decaps.py` (capacitor-to-pin assignment), `zpairs.sh` (Z pairs one at a time), `gnd_vias.sh` / `3v3_vias.sh` / `retry_vias.sh` (one via per surface-mount pad, applied sequentially).
- `BT-REVIEW.md` — my notes on the bt tools.
