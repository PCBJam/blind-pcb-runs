# RaspberryPiNVMeNAS: placement, routing, and what is not finished

## Status (read this first)

**The board is not finished and is not ready to order.** The final `bt check` says CHECK FAILED:

- 17 DRC errors. All 17 are `footprint_type_mismatch` (footprint attribute says SMD, pads are through-hole) on
  library footprints (J1, J3, J4, J5, J7, U18 and eleven more). They come from the footprint definitions, which the
  task said not to change. They should be fixed in the library/schematic, not in the layout.
- 435 warnings, among them: 199 silk text-height (below the board's 0.8 mm minimum; the reference fields are 0.5 mm), 196
  library-footprint mismatches, 215 schematic/PCB net-name parity items (see "Schematic/PCB mismatch" below), 7
  dangling vias, 4 dangling track ends, 6 silkscreen clipped at the edge.
- 147 unconnected pads (KiCad) and 77 open nets (`bt ratsnest`); 38 nets in pieces.
- The board is saved as the requested file and it loads in KiCad's pcbnew.

What is connected: all PCIe lanes (four M.2 slots, ASM1184 upstream and downstream, AC-coupling caps); all eight
Ethernet pairs; USB from CM4 through L7 to J7 (the RP2040 side of the J15 USB pair is open, see item 5); +5V (fans,
CM4 +5V pins, 5 V buck and its caps); +12P (DC input); M.2 3.3 V for M4 (complete; M1, M2 and M3 still have open groups, see below); +1V8;
ground: all but 16 of the 256 surface-mount ground pads have a via to the planes.

What is not connected, in priority order (details in "Open items"):

1. Power into five of the seven bucks: the VIN (+12V) of U10 (M1), U11 (M2), U13 (M4), U15 (+3.3VA) and U2 (+1V2)
   is cut off from the +12V zone. Without it those converters do not start.
2. ASM1184 supplies: +1V2 (4 small groups) and +3.3VA (7 pads) are partly connected.
3. M.2 3.3 V: M1 (4 groups open), M2 (5) and M3 (6): the converter feedback resistors, some pin groups and the output links are not all joined.
4. +3V3 (CM4 peripheral rail, 13 pads) and +3.3VSTB (RP2040 and flash rail, 17 pads).
5. RP2040 control and LED nets (LED_V+ bus, LED_1/4, PCIe_LED_1/4, CM4_RUN/EN, M2PWR_EN, PCIESWPWR_EN, IMON, VMON,
   TSENSE_0..2, SCL/SDA_CM4, PCIe_RST_M2), the RP2040 side of the USB series resistors, and the ASM1184 strap
   resistors (R23-R30, R36).
6. Sixteen ground pads (mostly CM4 pins in the connector field).

## Layer stack and planes

- Stackup as in the file: F.Cu / In1.Cu / In2.Cu / B.Cu, 0.48 mm dielectrics, 1 oz.
- **In1.Cu = GND** (full board). **In2.Cu = GND** with a **+5V island** (one polygon: the top band from x 84 to 226
  and y 72-92, the right edge down to y 111 for the fan headers, and the left strip from y 92 to 135 for the CM4 +5V
  pins). Both outer signal layers therefore have a ground reference, except under the +5V island.
- **B.Cu +12V zone** over the converter band (x 112-226, y 73-98). It is cut into pieces by existing bottom copper.
- **F.Cu +3.3V zones**, one per M.2 slot, under its lower row of 3.3 V pins; each joined to its converter's output
  inductor by a short bottom-side track and a via.
- Reason: 459 nets, mostly power and ground; two ground planes keep the return path for both outer layers, and the
  power had to go on the outside because two plane layers are needed for ground.

## Net classes (`bt rules`; only the .kicad_pro changed)

- `PCIe`: track 0.4 mm, pair 0.4/0.2, clearance 0.15, via 0.45/0.2. Note: on this stackup 0.2 mm is about 130 ohm
  differential and 0.4/0.2 about 104 ohm (my estimate, no field solver). The lanes are necked to 0.2 mm wherever
  they pass the 0.5 mm pitch pin rows of the M.2 sockets and the ASM1184, and the router keeps the neck width for
  much of the run. Impedance and length are not controlled (see "Open items").
- `ETH`: same geometry as PCIe.
- `USB`: 0.2 mm, pair 0.2/0.15.
- `Power12` (+12V, +12P): 1.0 mm, clearance 0.15 (lowered from 0.2 so the DC input could route next to IC1's
  unconnected pad; still above the 0.127 mm board minimum), via 0.6/0.3.
- `PowerM2` (+3.3V_M1..M4): 0.6 mm, clearance 0.15 (lowered from 0.2 because the M.2 connector's own lower-row pads
  are 0.2 mm apart).
- `Power5` (+5V): 0.6 mm, clearance 0.2.
- `Power3V3` (+3V3, +3.3VSTB, +1V2, +3.3VA): 0.3 mm, clearance 0.15.
- `Default`: 0.127 mm, via 0.45/0.2 (also holds the PCIe LED, reset and CLKREQ nets, which were moved out of PCIe).

## Placement

- The four NVMe drives lie flat over the right half of the board (x about 129-220, y 62-142). The front side under
  them carries only low-profile parts; tall parts (inductors, 22 uF caps) are on the back side, which is empty.
  Please check the drive standoff height against the front-side parts under the drives (the tallest is about 1.3 mm).
- The CM4 module hangs over x 88-128, y 90-146; its left-column pins need a clear strip to exit, so LEDs and small
  parts from that strip were moved to the back side.
- DC input (TPS2420 hot-swap, its dividers and LEDs) on the front side next to the DC jack.
- The M.2 3.3 V bucks (U10, U11, U14, U13) on the back side, one under each slot's power pins, with their inductors,
  bootstrap, feedback and output caps. U1 (+5V) and U4 (AP2112, +3.3VSTB) at the top left on the back side;
  U2 (+1V2) and U15 (+3.3VA) on the back side under the ASM1184.
- ASM1184 on the front side between the M.2 row and the CM4, rotated 180 so port 1 faces J2 (east), port 2 faces J3
  (north), port 3 faces J4 (west), port 4 faces J5 (south, then round), and the upstream pins face the CM4.
- RP2040, flash and crystal on the front side at the right, next to the fan headers, USB-C J15 and the buttons. The
  RP2040 decoupling capacitors are on the back side so the pins keep their exits.
- Ethernet ESD arrays U8/U9 on the back side, turned so each line runs across them.
- Passives were placed next to their pins with `bt near --each`; ASM1184 decoupling and straps are on the back side.

## Routing approach (what worked, and what did not)

- **PCIe M.2 lanes:** the upper-row pins (0.5 mm pitch) are escaped with `bt escape` (stub and via per pin, staggered
  between the pad row and the connector's inner channel). Port 3 and port 4 lanes then went from those vias to the
  ASM1184 through `bt route --batch` with explicit nested corner points; the clocks were routed last. Port 1 and port 2
  were routed directly.
- **ASM1184:** the AC-coupling capacitors were moved 3-6 mm out along their lanes so they do not block the pin exits.
  The upstream lanes route CM4 to the ASM1184 south and west pins; the RX pair crosses under the TX pair on a layer
  change. The CLK_N upstream lane was re-routed to keep 0.15 mm from CLK_P.
- **Ethernet:** the CM4 pins were escaped with `bt escape`, the ESD arrays moved to the back side, and the eight pairs
  routed on the back side from those vias to the ESD arrays and the RJ45.
- **Ground:** `bt escape --net GND` for the 256 SMD ground pads (stubs and vias into the planes), with the stubs
  removed and re-escaped round the buck inputs where they walled them in.
- **+5V:** an In2.Cu island; the 5 V buck output, the AP2112 input, the 5 V caps and the test point each get a via.
- **+12V:** a back-side zone; each converter input is joined by a narrow (0.25 mm) track to a free point in the zone
  where the zone cannot reach it; five of the seven converter inputs are still not joined (see open items).
- **M.2 3.3 V:** a front-side zone per slot, the converter output joined by one back-side track and one via, plus a
  short track bridging each left- or right-hand pin group that the zone cut off. M4 is complete; M1, M2 and M3 are
  partly connected (4, 5 and 6 groups open); M3's right-hand group could not be routed.
- **Everything else:** `bt route --nets` in chunks of 5-12 nets, each chunk applied with `bt apply --checked`.

## Open items (in priority order)

1. **+12V into the bucks.** The VIN of U10 (M1), U11 (M2), U13 (M4), U15 and U2 are boxed in: decoupling caps,
   the M.2 link tracks, and ground stubs surround them on the back side. The zone reaches U14 (M3) and U1 (5 V).
   Proposed fix: move the decoupling capacitors of each converter one row further from the VIN pin, or move each
   converter to a clear spot in the back-side band and re-route its input and output; the ASM1184 buck pair (U2, U15)
   needs the most room.
2. **+1V2 and +3.3VA at the ASM1184.** The 18 power pins were escaped with vias and most links routed. +1V2 has
   4 small groups open (about 2 mm of ratsnest) and +3.3VA has 8 groups open (about 11 mm), including the pads on the
   north side. The U2 input (+12V) is also open (item 1). The decoupling caps on the back side under the ASM1184 are in the way.
3. **M.2 3.3 V pin groups.** M3's right-hand group (J4 pins 70-74) is cut off by the port-3 clock lane at x about
   149-150; M1 and M2 each have a left-hand group that the router could not reach (J2 pin 2/4, J3 pin 2/4).
4. **+3V3 and +3.3VSTB.** Not connected. +3V3 is the CM4's peripheral rail (13 pads: CM4 right column, J1 SD card,
   TMP117 U5, the RJ45 LED supply). +3.3VSTB is the RP2040 and flash rail (17 pads), fed by U4 at the top left, about
   90 mm away. A better layout puts U4 near the RP2040 and the 5 V island's right edge.
5. **RP2040 control.** LED_V+ (14 pads, a long bus of LED resistors), CM4_RUN, CM4_EN, M2PWR_EN, PCIESWPWR_EN, IMON,
   VMON, TSENSE_0..2, SCL/SDA_CM4, LED_1/4, PCIe_LED_1/4, PCIe_RST_M2, and the RP2040 side of the USB series
   resistors (Net-(R59/R60-Pad2)) and Net-(U18-Pad2/3). The RP2040 pins are boxed in by its decoupling capacitors and
   flash routes; the router could not find exits in the time available.
6. **ASM1184 straps** (R23-R30, R36): short nets that are boxed in by the ASM1184's own ring.
7. **Sixteen ground pads**, mostly CM4 pins in the connector field (Module1.7, .8, .53, .59, .65, .98, .108, .155,
   .156) and a few passives (R35.2, R32.2, R4.2, C88.2, C87.2, C23.2) and two M.2 ground pins (J3.45, J3.51).
8. **Unconnected shield pins** of J7 and J15 (unconnected-(J7-PadS1), unconnected-(J15-PadS1)): the schematic leaves
   them unconnected; a USB-C shield is normally tied to ground.
9. **Signal integrity:** PCIe lanes are necked to 0.2 mm for much of their length; port 4 and the upstream lanes are
   60-90 mm long; no length matching or skew tuning was done. The Ethernet pairs were not length-matched.
10. **DRC leftovers:** 7 dangling vias, 4 dangling track ends and 6 silkscreen-on-edge items. These are small and
    left for the next pass (`bt cleanup`).
11. **Thermal reliefs:** the In2.Cu ground and +5V connections to through-hole pins are solid (not spoked) to clear
    the starved-thermal errors. This makes hand soldering the through-hole grounds and fan pins harder.
12. **M.2 lower row:** the +3.3V_M1..M4 zones sit under the connectors' lower row. The DRC clearance checks on the
    connector's own pads were passed by lowering PowerM2 clearance to 0.15 mm; the pads are 0.2 mm apart in the
    footprint.

## Schematic/PCB mismatch (not fixed here)

- The schematic netlist export shows the CM4's PCIe and USB pins unconnected (`PCIe_TX_P`, `PCIe_RX_P`, `USB_DP`,
  `USB_DN` only on the ASM1184 side, L7). The PCB connects them (CM4 pads 102-124). I followed the PCB.
- `bt check` reports 215 parity items: the PCB's net names differ from the schematic's for many pads (for example,
  `Net-(C6-Pad1)` on the PCB, `Net-(U3-CT)` in the schematic; `+3V3` on the PCB, `+3.3V` in the schematic).
  Someone should reconcile the schematic and the PCB before the board is ordered.

## Files

- `progress/001..006`: a picture and a note for each stage, including what did not work.
- `BT-REVIEW.md`: my honest review of `bt`.
- The `.bt-undo` folder that bt creates next to the board was removed at the end; it held only my session's backups.
