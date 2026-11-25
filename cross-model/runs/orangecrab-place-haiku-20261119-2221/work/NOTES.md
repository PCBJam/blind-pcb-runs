# OrangeCrab 6-layer layout: notes (work in progress)

Status is updated at the end of the session. See the "Not finished" section before ordering anything.

## Placement

- Locked parts (headers J1/J2, USB-C J3, microSD J4 on back, battery J5, JTAG J6, mounting holes, fiducials, logos) were not touched. `bt same` confirms this.
- FPGA U3 at (171.5, 102.5), rotation 90, front. Rotation 90 puts the DDR banks (balls A-D on the FPGA's west edge) facing the DDR3. Scored the four rotations by wire length to the fixed connectors and the DDR3 (`/home/kicad/work-notes/scripts/orientscore.py`); rotation 90 was best.
- DDR3 U4 at (161.5, 102.5), rotation 0, front. Its signal columns 2-3 and 7-8 face the middle channel and the FPGA.
- Charger U5 (BQ24232) on the back under the battery connector, programming resistors next to its pins.
- Three TLV62569 bucks U7 (3.3 V), U2 (1.35 V), U1 (1.1 V) with inductors in a column on the front-left, below the battery connector. Feedback dividers and 10 pF feed-forward caps next to each FB pin. LDO U10 on the back, near the FPGA's 2.5 V pins.
- QSPI flash U6 on the back at the FPGA's north-east corner, next to its configuration balls.
- Analog mux U9 on the back at the bottom-left, next to the analog header pins (moved from a short with J2's pads and the microSD mounting pad).
- Crystal OSC1 on the back under the FPGA's west edge, 4 mm from ball A9 (REF_CLK).
- RGB status LED D1 with its three resistors on the front in the bottom band, near the FPGA's LED balls. Charger status LED D2 on the back.
- Button SW1 on the front-right strip, with its debounce and pull-up beside it.
- Decoupling: DDR3 VDD/VDDQ caps on the back, on the two outer ball columns only. Interior-column caps moved out, because a cap under an interior ball takes that ball's via site. FPGA core, IO and VCCAUX caps moved from under the FPGA to the front band above the FPGA's north edge, the back strip below the FPGA, and the front bottom-right beside the LDO. Front-band caps were moved to the back, because they sat in the north escape lanes.
- Lesson: decaps placed under a 0.5 mm BGA's interior balls remove via sites needed for the planes and escape. `bt fan` could only via 129 of 233 pads until they moved.

## Layer stack used

- F.Cu: components, short signal escapes, and a GND pour (full outline, solid pad connection, clearance 0.089) so that the FPGA and DDR3 ground balls connect without a via each.
- In1.Cu: GND plane, full outline, clearance 0.2.
- In2.Cu: signal routing (DDR3 and FPGA escapes), plus a small P2.5V island in the FPGA's interior.
- In3.Cu: signal routing, plus a P3.3V island in the FPGA's interior.
- In4.Cu: P1.1V (FPGA core) island over the FPGA.
- B.Cu: signal routing and components, plus a P1.35V pour over the FPGA interior.
- Power balls: each of the 36 FPGA power balls gets a through via-in-pad (0.28/0.15) to its own plane. Adjacent balls of different nets are at 0.5 mm pitch and the via clearance check passes for each. Each plane has holes at other nets' vias, and the planes can split into islands in the FPGA interior. Check the islands with `bt islands`.
- Ground balls get no vias. The front GND pour and the GND plane carry them. The escape planner's ground vias were dropped (100 of them), because they would have cut every interior power plane.

## Routing

- FPGA and DDR3 escapes: `bt fan` on each BGA. For the DDR3, the fan ran with ground and both DRAM power nets as planes. For the FPGA, it ran with the default planes, and only the signal tracks and vias were kept (the ground vias were dropped). About 19 FPGA signal vias and 102 tracks were applied; the DDR3 fan applied 108 tracks and 50 vias.
- DDR3 data and address routing with `bt route --nets "RAM_*"`, on F.Cu, In2.Cu, In3.Cu and B.Cu, with 0.089 mm tracks and 0.28/0.15 vias, which are the class widths.
- Net classes changed: DDR3 DQS0/DQS1 vias 0.6/0.4 to 0.28/0.15 (the 0.6 mm vias do not fit the 0.8 mm DDR3 field next to the FPGA's escapes). New "Power" class (0.5 mm tracks, 0.6/0.3 vias, clearance 0.0889) for the P-rails, VSYS, VBATT, PUSB_VBUS, DRAM VDD/VDDQ and ECP5_VREF. New "USB" class (0.2 mm tracks, 0.2/0.15 differential pair, clearance 0.0889). RAM_CK+/- in the DDR_CLK class.

## Schematic and circuit issues found (not changed; the netlist is not ours to change)

These came from the schematic brief written by a helper reading the .sch files. Verify them against the datasheets before ordering.

1. DDR3 data mask lanes look crossed: RAM_LDM lands on FPGA ball G16 (bank 6, upper-lane group) and RAM_UDM on D16 (bank 7). Verify and consider swapping the FPGA pins.
2. DDR3 strobe names look swapped against the Micron ball names: RAM_LDQS+/- land on the DRAM's UDQS balls (C7/B7) and RAM_UDQS+/- on the LDQS balls (F3/G3). Each strobe still sits in its own FPGA data lane, but check that the lower byte's strobe is what the lower byte uses.
3. FPGA_RESET (Feather J2 pin 1) reaches two FPGA balls, T15 (PROGRAMN) and V17 (CSON/config). Check V17.
4. U7 (3.3 V buck) feedback R37 360 k / R38 82 k gives about 3.23 V, not 3.3 V. For 3.3 V, about 80 k on R38.
5. Charger: the note says charge current is set by ILIM, but ISET (pin 16, R12) is the charge-current pin by name. TS (pin 1) is tied to GND through R26 10 k with no thermistor. Check the datasheet.
6. Bank voltage labels on banks 2/6/7 read "1V5", but the nets are P1.35V.
7. Several P1.35V balls (C6, B18, D17, K15, K16, K17) have no documented purpose.
8. Oscillator OSC1 is a 48 MHz part, but the symbol says 32 MHz. No load caps.
9. Feather J2 pin 16 is GND; its note says I/O.

## Known DRC issues not from the layout

- Edge clearance errors (84): the locked Feather header pads (J1 at y 91.39, J2 at y 114.51) extend past the board outline. These are locked footprints.
- Courtyard overlap H4 vs FID6 (both locked).
- J5 courtyard is malformed (locked footprint).
- Library footprint warnings for `gkl_housings_bga` and `Package_BGA` (the footprints in the file do not match the library copies).

## Not finished (state at the end of this session)

**The board is not ready to order.** Routing and plane connections are incomplete. What is on the board is placed and mostly checked, but many nets are open.

- DRC (`bt check`, fills refreshed): 86 errors, which is exactly the original locked board's count: 84 edge-clearance errors from the locked Feather header pads (J1 and J2 extend past the outline), one malformed courtyard on the locked J5, and one courtyard overlap of the locked H4 with FID6. Everything else KiCad reports is unconnected copper: 210 unconnected items, 114 nets not fully connected, about 1,250 mm of ratsnest, and 65 dangling-track and 9 dangling-via warnings.
- DDR3: 38 of the 56 `RAM_*` nets are routed; 18 are open. Still open: RAM_D14, RAM_D10, RAM_LDM, RAM_D2, RAM_D3, RAM_D6, RAM_D7, RAM_D5, RAM_CK+, RAM_CK-, RAM_CAS#, RAM_WE#, RAM_A10, RAM_BA0, RAM_A5, RAM_A2, RAM_A1, RAM_A9. The blockers are the DDR3 field itself (routed neighbours, the back-side parts R19, R5, R13, C27 and the reference-voltage caps C1, C25, C28, R46 in the escape channel) and the fan's escape vias on the FPGA's west edge.
- Feather signals and FPGA IO: about 40 of 76 routed. Open include IO_11, IO_10, IO_6, IO_5, IO_9, IO_SCL, IO_SDA, IO_12, IO_13, IO_1, IO_A0 to IO_A5, the ADC_* nets, the SD0_* nets, JTAG_TCK/TDI/TMS/TDO, SPI_CONFIG_*, the QSPI nets, USB_D+/USB_D-/USB_PULLUP and their series resistor nets, REF_CLK, USER_BUTTON, LED_R and two LED nets, and FPGA_RESET. Most are blocked at the FPGA's north and south-west edges, where DDR3 tracks now run.
- Power: the 1.1 V joins (98 items, probed clear) were refused by the checked apply on the second write, so the P1.1V pour islands are still split (17 pads). P3.3V has 30 unconnected pads (one LED pad is boxed in). The 1.35 V and 2.5 V joins are applied. VSYS (13), EN (7), PUSB_VBUS (4) and the DRAM VDD/VDDQ networks (15 pads each) need routing; the DRAM networks also need the ferrites FB2/FB3 connected. ECP5_VREF has 14 open pads.
- Ground: 18 GND pads are not joined (two are the locked Feather pads that hang over the edge).
- Not done: `bt islands --fix` for P1.1V, P3.3V and the ground pieces, and any length tuning or DDR3 length matching.

**What I would do next, in order**
1. Move the reference-voltage caps and the four parts in the channel (C1, C25, C28, R46) and the DDR3 back-side parts (R19, R5, R13, C27) off the DDR3 field, and re-run the DDR3 escape with the ground pins left to the pour. That is the blocker for most of the DDR3 nets.
2. Consider rotating or moving the FPGA by 1 mm to widen the channel, or accept a two-row escape on the north edge. Re-plan the north escapes before routing the Feather IO nets.
3. Route the USB and SD nets as pairs with `bt pair`/`bt route` on the front layer, after the north and south-west corners are clear.
4. Finish the power joins with `bt islands --fix` and check the P1.1V and P3.3V pieces with the same probed-then-apply step.
5. Settle the schematic questions above (DM and strobe lanes, FPGA_RESET on two balls, U7 feedback), because some of them change routing.

**Files:** progress images and notes are in `/work/progress/` (001 to 008). `/work/.bt-undo/` holds bt's own board backups; delete it with `bt undo --clean` if you do not want them. The scratch scripts and intermediate items files are in `/home/kicad/work-notes/` (outside /work). `/work/BT-REVIEW.md` has the bt review.
