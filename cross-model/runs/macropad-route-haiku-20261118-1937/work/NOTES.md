# macropad-top: routing notes

Board: `macropad-top.kicad_pcb`, 2 copper layers, JLCPCB standard 2-layer. Placement untouched (no footprint moved, rotated, flipped, added or removed).

## Status

- Every net is connected. `bt ratsnest`: 0 unconnected, 0 mm.
- `bt check`: CHECK OK, 0 DRC errors, 0 unconnected, 0 nets in pieces, 0 bt findings.
- Independent check: `kicad-cli pcb drc` on the saved board gives 0 errors and 0 unconnected items. One warning remains: the U103 footprint differs from the library copy of `QFN-56-1EP_7x7mm_P0.4mm_EP3.2x3.2mm`. I did not touch the footprint, as the rules say. (An earlier run found three clearance errors from stale pour fills; they are fixed, see progress/012.)
- Copper: 356 segments (F.Cu 239, B.Cu 117), 852 mm of track in total. Widths: 0.2 mm 646 mm; 0.4 mm 148 mm (LED rail); 0.3 mm 23 mm; 0.5 mm 23 mm (VBUS and +5 V); 0.127 mm 12.6 mm (LED_EN, see below).
- Vias: 107 in total: 105 at 0.6/0.3, 2 at 0.4/0.3. Of those, 61 are GND stitching vias on a 4 mm grid, and 4 are thermal vias inside the RP2040 exposed pad.
- Net classes (set in the .kicad_pro with `bt rules`): Default 0.2 mm, clearance 0.2; Power5V (+5V, VBUS) 0.5 mm; LED5V (+5V_LED) 0.4 mm; Power3V3 (+3V3) 0.3 mm; USB (D+/D- pair) 0.2 mm with 0.2 mm gap.

Working log: `progress/` (NNN-name.png + .md pairs, failed attempts included).

## Approach

Order of work, because the RP2040 pin groups fight over the same space and the first net routed takes it. This is the order I actually used:

1. Power input and USB: VBUS, fuse, +5 V tree, ESD, the two 27 ohm series resistors, CC pull-downs, D+/D- into the RP2040.
2. Crystal (XIN/XOUT/C113 node).
3. The five key GPIO nets that routed first (north edge of the RP2040 into the key field).
4. QSPI (six nets), then +1V1 with chosen via sites, then +3V3. Routing +3V3 before +1V1 walled in pins 43-50, and routing +1V1 before QSPI left pin 50 with no exit.
5. LED_EN and LED_DIN_3V3 from the bottom edge. The +3V3 run that had gone along the bottom edge had to come out and be re-routed after them.
6. The LED data chain and the +5V_LED rail.
7. The sixth GPIO (KEY3) and a re-route of all six GPIOs together with rip-up (see Not finished, item 1), then TESTEN and the pin 22 +3V3 exit.
8. GND pours on both layers, plugging every isolated ground pad, then stitching.

Routing was done with `bt route` (trials written with `-o`, applied with `bt apply --checked`), with hand-placed stubs and vias where the router could not find a clean answer, each probed with `bt probe`.

## Decisions and why

- **Layers.** F.Cu carries the RP2040, the flash, the USB, power and most signals. B.Cu carries the key field: the key sockets, the LEDs and the decoupling caps are all B.Cu pads, so the GPIO, LED chain and most of the +5V_LED copper live on B.Cu there.
- **Clearance 0.2 mm everywhere.** JLCPCB's 2-layer minimum is 0.127 mm, but 0.2 mm keeps yield margin. The only narrower copper is the 0.127 mm LED_EN neck (see below).
- **Track widths.** 0.5 mm for VBUS and +5 V (fuse-limited 0.5 A). 0.4 mm for the LED rail (up to ~0.36 A at full white). 0.3 mm for the LDO output trunk. 0.2 mm everywhere else, which is ample for the IOVDD and logic stubs (RP2040 + flash draw about 0.1 A). I did not use controlled impedance: a 1.6 mm 2-layer board needs ~3 mm wide tracks for 50 ohm, so the USB pair is short (9.7/9.8 mm) and matched, not impedance-controlled.
- **USB.** The connector's D+ and D- pads are interleaved (B7 D-, A6 D+, A7 D-, B6 D+). D+ is bridged from A6 to B6 around the east side of the connector; D- from A7 to B7 round the west side. The bridges never cross, and the series resistors and ESD sit in-line.
- **VBUS.** The A9/B4 pad is boxed in by the connector's NPTH hole and CC2 on the west side (a router attempt needed a 0.127 mm neck there, so I rejected it). VBUS runs F.Cu down the east side of the connector, up a B.Cu trunk at x = 95.55, and back to A4 through two vias placed clear of CC2.
- **ESD VBUS pin (U102.5)** is enclosed by the two USB lines, so it gets a stub and a via at 100.6,106.5 and a 13.9 mm B.Cu run to the 5 V tree.
- **Crystal.** XOUT and the C113 node came from the router. XIN failed when the router tried to shove XOUT; I placed XIN by hand on the open side of the crystal.
- **QSPI.** Six nets on F.Cu. SD1 hops to B.Cu (two vias) because SS blocks its lane on F.Cu. The flash sits below the RP2040, so the bottom-row flash pins (SD0, SCLK, SD3) wrap round the flash's west side. The west fan needed no vias in the lanes to be planar, which I enforced with `--no-via`.
- **+1V1.** C115 to DVDD (pin 23) and VREG_VOUT (pin 45) across the north interior on F.Cu, with a via to B.Cu for C116/C117. DVDD pin 50 reaches the net by an 8 mm loop round the west of the USB resistors, which is the only exit left after the QSPI and USB lanes were fixed.
- **+3V3.** 22 links at 0.2 mm, 67 mm, 5 vias. The pin 22 exit is a via at 110.9,107.9 that lands on the C108.1 decap pad, because the east side is crowded by XIN/XOUT, +1V1 and TESTEN.
- **TESTEN (RP2040 pin 19, must be GND).** Routed as a 3.6 mm F.Cu track straight into the exposed pad (the EP is GND); it reaches the EP's thermal via at 109.4,107.0.
- **Exposed pad.** Four 0.6/0.3 vias inside the EP at 107.4,107.0; 109.4,107.0; 107.4,108.6; 108.5,107.6, joining the EP to the B.Cu pour.
- **Pours.** GND on F.Cu and B.Cu, outlined to the board edge (0.2 mm clearance, min width 0.25 mm). Nine GND pads were isolated by copper around them; each got a via into the pour. The ESD ground pin (U102.2) is joined by a 0.4 mm via at 96.75,106.5 that overlaps its own pad, clear of the USB bridge.
- **Stitching.** 61 GND vias on a 4 mm grid (only where they land in the pour on both layers).
- **LDO output.** The 3 V3 trunk from the LDO output pin to C104 and C103 is 0.3 mm (widened after routing).

## Not finished or not good

These are the real weak points. Everything else is DRC-clean.

1. **GPIO routing (KEY1-KEY6) is long and messy.** KEY3 58.7 mm (57 mm on B.Cu), KEY6 60.2 mm (58 mm on B.Cu, 3 vias), KEY5 42.9 mm, KEY2 36.7 mm, KEY4 31.8 mm (3 vias), KEY1 17.8 mm. The six pins sit at 0.4 mm pitch on the north edge, and their escapes cross in the 2.3 mm corridor between the chip and the top key row. I could not find a crossing-free two-layer plan by hand, and the router only did it with long detours (`bt fan` agrees: it can give only four exits on F.Cu). A proper fix needs either a different layer strategy in that corridor, or a four-layer board. Nothing here is out of spec, but a designer would not ship it as is.
2. **LED_EN has 12.6 mm of 0.127 mm track** (the JLCPCB minimum), on the bottom-edge pin 9 path. It is a logic line, so the current is negligible. I tried 0.2 mm again with no necks and it does not fit now that the 3V3 copper is on both layers.
3. **+5V_LED is 144 mm of 0.4 mm point-to-point track** (15 links, 8 vias, mostly B.Cu). A B.Cu +5 V pour in the channel between the rows would be the better layout; I did not do it because the channel is full of GPIO and chain copper, and a pour would have to be cut round all of it. That is the first thing I would change.
4. **QSPI is not length-matched.** SD3 24.7 mm, SCLK 19.1 mm, SS 16.0 mm, SD0 14.8 mm, SD1 11.0 mm (with two vias), SD2 10.2 mm. The flash placement forces the long paths; I did not try to tune them.
5. **LED_DIN_3V3 is a 38.9 mm all-F.Cu detour** around the flash and BOOTSEL (the direct route is boxed in by the other RP2040 bottom-edge copper). LED_DIN is 30 mm.
6. **+1V1 pin 50** reaches the net through an 8 mm loop round the USB resistors (the 1V1 net is 21.8 mm in total).
7. **Vias at the minimum.** Two vias are 0.4/0.3 (annular ring 0.05 mm, the DRU minimum): one at the ESD ground pin, one at the pin 22 +3V3 exit. Both pass the DRU. If JLCPCB's CAM wants 0.1 mm annular, these two need moving.
8. **Thermal vias inside the RP2040 exposed pad** (4 × 0.6/0.3) are plain vias in pad. Check the paste/mask setting at order time; tenting or filling them would be the safer option.
9. **TESTEN** is tied to GND by a stub into the exposed pad, not by a via (every via spot next to pin 19 is blocked by pins 18/20 and the XIN track). It works electrically but is not how I would like it.
10. **Not designed in (no footprints allowed to be added):** no SWD access pads (the schematic leaves RP2040 SWCLK/SWDIO unconnected), no test points, and RUN is tied directly to +3V3 (as in the schematic, no reset RC or button).
11. **USB** is not impedance controlled (not achievable with 2-layer 1.6 mm FR4 at usable track widths).
12. **Silkscreen** was not reviewed beyond DRC (no `bt silk` pass). DRC passes, but the reference labels in the RP2040 and decap cluster are crowded in the render.

## Reproducing the checks

- `bt ratsnest macropad-top.kicad_pcb` → 0 unconnected.
- `kicad-cli pcb drc --severity-all --units mm macropad-top.kicad_pcb` → 0 violations, 0 unconnected; one footprint-library warning on U103. Run this on the saved file: it reads the fills as saved.
- `bt check macropad-top.kicad_pcb` → CHECK OK. Caution: after I widened a 3V3 run, `bt check` reported "fills were up to date" while the saved GND fill was stale. I refilled with `bt fill` and re-ran the KiCad DRC above; that is the state in /work now (see progress/012).

Note that the stale fill was a problem of my own making (I widened copper after the last fill). The pours in /work were refilled after the last copper edit.

`bt` keeps a backup of every board it writes in `/work/.bt-undo/` (20 kept, 23 MB). I cleared them with `bt undo --clean` and removed the folder, along with the `macropad-top.kicad_prl` KiCad state file that my tool runs created. The untouched originals were kept in `/tmp/orig/` during the session; they are not part of the deliverable.
