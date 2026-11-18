# ESP32-PoE-ISO Rev.O – compact 4-layer re-layout: design notes

Board: **30.0 x 74.7 mm** rectangle (2241 mm2; the original outline noted in the file was 28 x 98 mm),
4 copper layers, parts on both sides. All 147 footprints are on the board; none added, removed or edited.

> **Status – read this first.** Placement, outline, planes, the whole PoE primary side, the Ethernet
> pairs, USB data, all power distribution and most signals are routed and pass KiCad DRC, including the
> custom isolation rules. **The routing is not complete**: see "Not finished / not good" at the end for
> the exact list of open connections. The board must not be ordered as it is.

## Floorplan (left to right)

```
 x=0                 ~21        ~43                         68        74.7
 +--------------------+----------+---------------------------+---------+
 | RJ45 (top)         | USB  BUT | EXT2 header (1x10)        | MH      |
 |  PoE primary parts |  RST LED |  ESP32-WROOM (antenna ->) | antenna |
 |  under it (bottom) | UEXT     |  PHY + power + passives   | keep-out|
 | C27 C26  DC/DC ====|==iso== BAT  underneath (bottom)      |         |
 +--------------------+----------+---------------------------+---------+
   PoE primary (Earth) | 3 mm gap |        secondary (GND)
```

* **RJ45 at one short end, antenna at the other.** The two things that need a board edge and want to be
  far from each other get the two ends. The module's antenna section lies on the board (not hanging
  off) so the module is fully supported, with a copper keep-out on all four layers under and beside it.
* **Width 30 mm, not 28.** With the jack against one long edge (17.2 mm of pads) a 28 mm board leaves a
  10 mm strip plus the area under the jack front for the whole cable-side circuit: ~350 mm2 for ~310 mm2
  of parts. That only fits by eating the isolation gap, so I gave the board 2 mm more width (progress 001).
  The length is set by what must sit on the top side between jack and module: UEXT box header (20.6 mm)
  above the SIP-7 DC/DC, with USB and the buttons along the top edge.
* **Headers** EXT1/EXT2 flank the module at 25.4 mm (1.0") row spacing, pin 1 diagonal like a DIP, so the
  board still plugs into a breadboard. They use edge strips that nothing else could use.
* **The full ESP32-WROVER footprint outline is kept free on the top side** (the fitted part is a
  WROOM-32E, 6 mm shorter). This costs ~6 mm of length; I kept it because the footprint is a dual
  footprint and its extra pads are on the board anyway.
* **Bottom side** carries the PoE converter (under the RJ45), microSD (card slides out over the top long
  edge, under the buttons), CH340 (under the USB connector), LAN8710A PHY (under the module tail), the
  3.3 V buck, charger, power-path FETs and all small passives (under the module body, not under the antenna).
* **Mounting holes:** MH1 in the bottom-left (PoE) corner next to the jack, MH2/MH3 in the two corners
  beside the antenna. Those two are 3 mm from the antenna: use nylon screws/spacers there.
* **Drill_Slot3** (2 x 4 mm milled slot) is used as an isolation slot under the DC/DC converter,
  between its primary pin 2 and secondary pin 4.
* Fiducials: three per side (two right corners + one left/middle) plus one spare each.

## Isolation (the part I would not compromise)

* Primary side = everything tied to the cable pairs: Spare1/Spare2 (rectified PoE), Earth (hot-swap
  return), 5V_DCDC and the small control nets of U2/U5. Secondary = GND and everything on the ESP32/USB side.
* **3.0 mm copper-to-copper between primary and secondary on every layer**, enforced by a custom DRC rule
  (`ESP32-PoE-ISO_Rev_O.kicad_dru`, net classes `PoE_Power` + new `PoE_Sig`). 3.0 mm is what the bridging
  parts themselves give: RJ45 pin 6 to pin 9 = 3.05 mm, SIP-7 pin 2 to pin 4 = 3.56 mm, 1808 Y-cap = 3.56 mm.
* The zone outlines of the primary (Earth) and secondary (GND) pours are drawn so that they also never
  overlap **between layers** (outer prepreg is only 0.127 mm); the gap is a copper-free band through the
  whole stack. Only DCDC1, C23 (Y-cap, placed between DC/DC pins 2 and 4) and C20 (not populated) bridge it.
* Cable shield / chassis net (jack tabs, NC pins 7/8, C2 2 kV): separate 1.0 mm rule (limited by the
  jack: pins 8 and 10 are 1.016 mm apart). It runs as one 1 mm track between the primary area and the
  jack's signal pins.
* The two electrically unconnected pins of U2/U5 were put in the `PoE_Sig` class so the rule does not
  flag them against their neighbours.

## Layer use

| layer | secondary area | primary area |
|---|---|---|
| F.Cu | module, connectors, signals, GND fill | Spare1/Spare2 under the jack body, R27, R28, D10, Earth fill |
| In1.Cu | GND plane (reference for top side); 5V_USB feed and two short VDDA hops | Earth fill, 5V_DCDC trunk (1 mm), bootstrap hop |
| In2.Cu | GND plane (reference for the bottom side incl. the Ethernet pairs), 3.3 V tree, 3.3VLAN hop, a few RMII lines | Earth plane (reference for the buck) |
| B.Cu | most parts and signals, GND fill | buck, hot-swap, switch node, Earth fill |

Stackup is the one stored in the file (0.127 mm prepreg / 1.2 mm core / 0.127 mm prepreg), which is what
the Zdiff=100R (0.127/0.127 mm) and Zdiff=90R classes were defined for.

## Routing decisions

* **PoE primary by hand** (`routes/010_primary.py`). Switch node (U5.1, D5, L4, C12) is one short
  bottom-layer island at the board edge. R28 (sense) sits on the top side so the pulsed input current
  goes C27(+) -> R28 -> U5 exposed-pad via -> D5 -> C27(-) in a loop a few mm across. 5V_DCDC runs on In1
  to C26 and on to DCDC1 pin 1; C26 and the TVS D11 sit at the DC/DC input. The two 9.1k/1W bleeders are
  apart (one top, one bottom) and away from the electrolytics' pins.
* **Ethernet pairs by hand** (`routes/020_eth_usb.py`), 0.127/0.127 mm, RD on the bottom all the way.
  With the PHY on the bottom the jack's pin order and the PHY's pin order cannot both be met on one
  layer, so TD leaves the jack on the top layer, crosses over RD there, and changes to the bottom with
  one via per line beside the ESD array (TD+ has one extra stub via to reach its TVS pad). 49.9R
  terminations lie alongside their lines 9 mm before the PHY; centre taps are decoupled next to the jack.
* **USB D+/D-**: 2 mm, connector on top, CH340 directly underneath.
* **3.3 V**: one via per load into a 0.5 mm tree on In2, routed around the pairs' reference area.
  The buck (U7/L2/C6/C22) is under the middle of the module, 8 mm from the antenna, with SW leaving
  between the input-capacitor pads.
* **PHY**: decoupling on each supply pin, straps/RMII RX leave as a bus under the module pad column to
  the pull-up arrays; 50 MHz clock and TX lines to the module on In2/B (see open items).
* Everything else was auto-routed with `bt route` (F/B first, In2 for leftovers), 0.15–0.2 mm tracks.

## Design-rule / project changes

* New net class `PoE_Sig` (0.2032 mm clearance, 0.254 mm track) for the small primary control nets.
* New rule file with the two isolation rules above. Nothing else in the project rules was changed.
* The old board-level silkscreen texts/arrows (they were at their old absolute positions) were removed;
  header pin labels, board name and layer markers were added again in new places.

## Not finished / not good

Final check with kicad-cli 10.0.8 DRC (project rules + the isolation rule file): **0 violations,
39 unconnected items**. Coordinates below are board-local mm (origin = top-left board corner; add 100 mm
for KiCad page coordinates).

### Open signal connections (15 links, 13 nets) – the board does not work without these

```
Track [/GPIO15/HS2_CMD] on In2.Cu (41.2, 4.0)  ↔  Pad 3 [/GPIO15/HS2_CMD] of MICRO_SD1 on B.Cu (35.3, 7.6)
Pad 2 [/GPIO15/HS2_CMD] of R39 on B.Cu (40.9, 8.8)  ↔  Track [/GPIO15/HS2_CMD] on In2.Cu (46.9, 4.0)
Track [/GPIO15/HS2_CMD] on F.Cu (48.4, 19.7)  ↔  Pad 2 [/GPIO15/HS2_CMD] of R39 on B.Cu (40.9, 8.8)
Track [/ESP_EN] on B.Cu (52.8, 20.0)  ↔  Pad 1 [/ESP_EN] of RST1 on F.Cu (38.2, 7.2)
Pad 1 [/GPIO2/HS2_DATA0] of D2 on B.Cu (51.4, 23.8)  ↔  Track [/GPIO2/HS2_DATA0] on F.Cu (49.4, 23.5)
Track [/GPIO4/U1TXD] on F.Cu (51.9, 24.3)  ↔  Via [/GPIO4/U1TXD] (55.5, 28.6)
Pad 2 [Net-(LAN_CON1-RCT)] of LNK1 on F.Cu (41.3, 1.2)  ↔  Pad 1 [Net-(LAN_CON1-RCT)] of C16 on B.Cu (42.2, 11.2)
Track [/GPIO17/EMAC_CLK_OUT_180] on F.Cu (54.4, 23.5)  ↔  Pad 5 [/GPIO17/EMAC_CLK_OUT_180] of U4 on B.Cu (44.8, 12.0)
Pad 3 [Net-(U3-VBAT)] of FET2 on B.Cu (50.4, 22.1)  ↔  Pad 1 [Net-(U3-VBAT)] of R7 on B.Cu (58.0, 6.8)
Pad 5 [Net-(MICRO_SD1-CLK/SCLK)] of MICRO_SD1 on B.Cu (37.6, 7.6)  ↔  Pad 2 [Net-(MICRO_SD1-CLK/SCLK)] of R40 on B.Cu (51.9, 6.0)
Track [Net-(Q2-E)] on B.Cu (47.4, 7.6)  ↔  Track [Net-(Q2-E)] on B.Cu, length 1.2000 mm (26.0, 5.8)
Pad 3 [Net-(D9-K)] of Q2 on B.Cu (43.9, 5.4)  ↔  Pad 1 [Net-(D9-K)] of D9 on B.Cu (66.9, 14.9)
Track [/D_Com] on B.Cu (53.2, 4.6)  ↔  Pad 2 [/D_Com] of R49 on B.Cu (54.7, 4.3)
Via [Net-(D6-K)] (26.8, 3.0)  ↔  Pad 1 [Net-(D6-K)] of D6 on B.Cu (61.6, 21.5)
Via [Net-(U1-V3)] (28.6, 3.2)  ↔  Pad 1 [Net-(U1-V3)] of R19 on B.Cu (62.9, 22.4)
```

What they mean functionally:
* **USB programming path is open**: CH340 TXD (Net-(D6-K)), its V3 pull-up reference (Net-(U1-V3)),
  RTS (Net-(Q2-E)) and the auto-reset nets (Net-(D9-K), /D_Com, /ESP_EN to the reset button side) are
  each missing one link. The CH340 end has vias waiting under the IC (dangling-via warnings), the far
  ends are boxed in on the bottom side under the module.
* **Ethernet clock** GPIO17 -> PHY XTAL1/CLKIN is not connected, so the PHY would not run.
* **microSD**: CMD (GPIO15) and CLK are not connected to the socket.
* GPIO2 to D2, GPIO4 to its header via, battery-sense divider feed (VBAT -> R7), LNK LED anode to VDDA.

### Open ground connections

GND pads with no connection to the planes (their pour fragment has no via and I found no legal via
spot next to them): C21.1 (NA part), RM1.1.1, U6.15 (one of the two module GND twin pads), C15.2, C17.2,
R16.2, R26.2 (RBIAS resistor!), R30.2 (buck feedback divider!), R6.2 (charger PROG resistor!), plus
11 small outer-layer GND pour fragments reported as zone-to-zone gaps.

### Why it stopped here

The bottom side under the module and around the PHY ended up too dense for one-net-at-a-time routing:
the remaining pads are surrounded by other nets' tracks with no room for a via, and four passes of the
autorouter (plain, In2, rip-up, shove) could not open them. Finishing needs manual rip-up of those
clusters (module bottom-left corner around D2/U3/U8, the UART level-shifter group at x=60..67 y=17..23,
the row of 0402s under the module's top pad row) or 2-3 mm more board length to spread them. I ran out
of effort budget before doing that; I would rather hand over an honest partial than a file that looks
finished.

### Other things that are not good

* **Board size**: 30 x 74.7 mm is 27 % smaller than the 28 x 98 mm noted in the original file, but the
  density that this forced on the bottom side is exactly what blocked the last connections. A board
  2-3 mm longer would be the better product.
* Auto-routed signals were not cleaned up: unnecessary vias and detours, RMII TX/clock partly on In2
  (cuts in the GND plane under the module), a few 0.127 mm tracks where 0.2 mm would fit. One 3.3 V
  repair link runs on In2 under the TD pair (x=31.2, y=14.3..17.3) – a small slot in its reference plane.
* Ethernet TD pair has 2 vias per line (+1 stub via on TD+); pair lengths are not matched (difference
  is a few mm, fine for 100BASE-TX, not verified numerically). Impedance relies on the stackup stored
  in the file; no field-solver check was done.
* The 5V_USB feed runs ~50 mm on In1 at 0.4-0.5 mm; fine for the CH340 and the power-path FET, but it
  is a long thin supply.
* No thermal check of the PoE section (U5 exposed pad sits on the ILIM net in this schematic, so it
  only has a small copper island; R27/R41 dissipate ~0.25 W each).
* Mounting holes MH2/MH3 and two fiducials sit in the corners beside the antenna.
* Silkscreen: 191 "silk clipped by mask" warnings – reference designators overlap pads on both sides
  and were not tidied. Logo_OSHW and Sign_Antistatic had no free space and are on the top side inside
  the RJ45 outline (hidden by the jack); Sign_PB-Free and Sign_RecycleBin are on the top side under the
  module's antenna section (hidden by the module). Sign_CE and the Olimex logo are visible on the bottom.
* Schematic parity: KiCad reports 26 pre-existing mismatches between the schematic and the footprints'
  "do not populate"/datasheet fields; I did not touch footprints, so these are as delivered.
* The `.kicad_prl` was not regenerated; `.kicad_pro` only gained the `PoE_Sig` class and its patterns.

## Files

* `ESP32-PoE-ISO_Rev_O.kicad_pcb` / `.kicad_pro` / `.kicad_dru` – result (the `.kicad_dru` is new and is
  needed for the isolation DRC).
* `orig/` – untouched copies of the files as received.
* `tools/`, `routes/` – placement table, zone outlines, hand-route scripts and the bt item files.
* `progress/` – numbered pictures and notes. `BT-REVIEW.md` – review of the bt tool.
