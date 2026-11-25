# NOTES – RaspberryPiNVMeNAS 4-layer routing

**Status: not finished.** The board is routed to about 95 % of its connections and has no shorts and no track-to-track or track-to-pad clearance errors. `bt check` (last run) reports 13 nets with open pieces and no routing errors (no shorts, no crossing or clearance errors), plus 26 footprint-level DRC errors from the original placement (below). Do not send it to fab as it is. The open items and their locations are listed at the end.

All footprints are where they were: `bt same` against the original board reports nothing locked moved, nothing added or removed, and no pad net changed.

## Layer stack

| layer | use | why |
|---|---|---|
| F.Cu | signals and part escapes | parts are on this side; GND plane (In1) is its reference for every signal |
| In1.Cu | **solid GND plane**, whole outline | the reference for both signal layers; stitching is via the GND vias |
| In2.Cu | **power zones** (8 zones, below) | keeps the rails out of the signal layers; each rail sits under the parts it feeds |
| B.Cu | signals (long runs) | no parts on this side, so it is the free routing layer |

Stack: 0.48 mm FR4 between each layer pair (as the board's stackup). Microstrip on F.Cu/B.Cu references In1 at 0.48 mm; B.Cu also references In2 at 0.48 mm. The 100 Ω differential pairs were sized for that stack: 0.35 mm wide, 0.15 mm gap (eps_r 4.5, 1 oz). USB pairs: 0.40/0.15 for about 93 Ω.

## Net classes and rules (set in the .kicad_pro with `bt rules`)

- `Default`: 0.15 mm track and clearance, vias 0.45/0.20.
- `PCIe` (30 nets): 0.35 mm, pair 0.35/0.15.
- `ETH` (8 nets): 0.35 mm, pair 0.35/0.15.
- `USB` (8 nets, CM4 and USB-C sides): 0.40 mm, pair 0.40/0.15.
- `Power_HC` (+12V, +12P, +5V, +3.3V_M1..M4): 0.6 mm, vias 0.6/0.3.
- `Power` (+3V3, +3.3VA, +3.3VSTB, +1V2, +1V8): 0.3 mm, vias 0.6/0.3, **clearance lowered to 0.15 mm** late in the job so a path could pass a CM4 pad at 0.17 mm (the 0.2 mm clearance was otherwise blocking it). Nothing else changed.
- Board minimums unchanged: track 0.127, via 0.4/0.2, edge 0.

## Power and ground

- **In2 zones** (one net each, no overlaps):
  - `+3.3V_M1..M4`: a band under each M.2 socket (y 57.2–73.6), so the socket's bottom-row power pins drop into their own plane.
  - `+12V`: x 122.5–224, y 75.6–97.8, with a 3 mm protrusion up to y 66 at x 125.9–128.8 so the eFuse output pins U3.10–12 can reach it.
  - `+1V2`: under the PCIe switch (x 161–186, y 99.5–132.5).
  - `+3.3VSTB`: RP2040 side (x 200.5–224, y 109–139.5).
  - `+5V`: west block (x 84–121, y 77–135) for the CM4 5 V pins and fan M4.
- The rest of +5V (fans M1–M3, U4, C8) is connected by tracks from the west zone (about 100 mm of F/B copper, shared with the fans).
- +3V3 and +1V8 are CM4 outputs with small loads, so they are tracks, not planes.
- **In1 GND**: 227 of 268 GND pads got a via by `bt plane`; the rest were routed to the plane one by one. Four or five GND pads are still open (see below).
- Zone fills were refreshed (`bt fill`, `bt check`) after the vias were placed. Before that, the ratsnest counted stale fills as connections.

## Routing approach

1. **PCIe** (four M.2 sockets and the CM4 uplink, 38 nets): escapes first, then the long runs. Each socket's PCIe pins sit in the gap between the two pin rows, so every pin gets a 0.25 mm stub and a via there, alternating y 60.0 and 61.6 so neighbouring vias keep 0.6 mm centres. The long runs go on B.Cu. Lane 3 needed its RX pair swapped at the socket (N on the west) so the order matches the switch pins. Pairs are two single-ended `bt route` calls, the second beside the first; `bt pair` could not leave the pads. Pair lengths are 46–94 mm and are not matched yet.
2. **Ethernet** (8 nets): `bt escape` put the CM4 pin vias in the gap between the module's two pin columns; each pair goes CM4 → ESD pad → (bridge across the shunt ESD pads) → RJ45. Three ESD bridges were drawn by hand (the router's grid put them 0.15 mm from the neighbour pad). Pair lengths differ by 2–10 mm.
3. **Bulk pass**: 137 nets with `bt route --nets --order escapes-first --passes 2`, with the PCIe and ETH copper fixed. 124 connected in that pass, and the rest needed targeted work.
4. Power and GND vias with `bt plane`, then routes for the leftover pads.

## What is not finished or not good

**Open connections (bt check, 14 nets with open pieces):**

- `CM4_RUN` (CM4 pin 92 to RP2040 pin 27, 109 mm): the pin is boxed in by the +1V8 and IMON exits and the microSD tracks next to it. It needs a re-plan of the CM4 left-block east column, which the bulk pass left packed. Not routed.
- `+3V3`: the link from CM4 pin 84 to the R8 pull-up (95.6, 120.7) is blocked by the SD and I²C tracks in the same corridor (91.6, 118.6 is the other piece). Pins 78 and 84 are joined, so only this link is open.
- `GND`: four or five pads not yet on the In1 plane: R6.2 (173.1, 96.5), R35.2 (167.1, 76.8), R32.2 (190.3, 76.7), U9.8, and one more. R6.2, R35.2 and R32.2 are blocked by the F.Cu tracks of the buck feedback nets (Net-(R5-Pad2), Net-(R34-Pad2), Net-(R31-Pad2)); U9.8 is walled in by the ETH_P1- and ETH_P0- pads of the ESD U9. Moving those feedback tracks to B.Cu would free the pads.
- `+3.3VA`: seven groups. The switch's +3.3VA pins (1, 10, 21, 32, 38, 56) and their caps are boxed in by the PCIe fan-out.
- `+1V2`: U12.64 (177.05, 127.9). No legal via within 2.5 mm: PCIe_CLK_N_4 runs against the pin.
- `+3.3V_M1`: the R20 pull-up (190.0, 69.0) is a 5 mm piece not joined to the rail.
- `PICO_PWM1` (U18.6 to fan M1, 19 mm), `USBpico_DN` and `Net-(R60-Pad2)` (RP2040 D- side, boxed in for the 0.4 mm USB width), `Net-(J7-PadA7)` (1 mm piece on the USB-C A7 pad): all boxed in by the LED, QSPI and tacho tracks around U18. A planned RP2040 fan-out (`bt fan U18`) with those nets first would be the next step.
- `TSENSE_2` (U18.39 to J10.1): **unrouted**. The routed version (165 mm, 16 vias) shorted PICO_LED_3 and crossed PICO_LED_2 and TSENSE_0, so I removed it. A correct route needs the RP2040 escape planned first.
- `Net-(C10-Pad2)` (U2 buck feedback) and `Net-(R24-Pad2)` (GPIO pull-up at U12 north-west): boxed in by the lane-2 and lane-3 PCIe tracks.
- Two USB-C shield pads (`unconnected-(J7-PadS1)`, `unconnected-(J15-PadS1)`) have no net in the netlist, so KiCad reports them as unconnected. I left them as the netlist has them.

**KiCad DRC (bt check): 26 errors, all from the original footprints.** 17 `footprint_type_mismatch` (parts whose pads are SMD but whose footprint type says through-hole, or the reverse, e.g. U14, J1, U1, J5) and 9 `courtyards_overlap` (for example C9/C13, C12/TP_1V2, IC1/TP_VIN1). Those are in the placement I was asked to keep, so I did not change them. They need a footprint-level fix by whoever owns the library. Warnings (426): silk text height below the board's 0.8 mm minimum, footprint-library mismatches, silk clipped by the edge.

**Quality issues in the copper:**

- **Layer use is lopsided**: 1553 segments on F.Cu, 464 on B.Cu (2017 in total). The bulk pass used F.Cu freely; a better pass would move the long non-critical runs to B.Cu.
- **Necks at the pads**: the bottom-row M.2 power pins and the CM4 pins are joined through short 0.127 mm necks (roughly 0.5–6 mm of neck per rail). Those are current bottlenecks on the 3.3 V rails and should get a second via each.
- **PCIe coupling**: the two members of each pair leave the vias about 0.5 mm apart but split on F.Cu/B.Cu at some points (up to 1–2 mm apart at the switch). The lane-2 RX_N and lane-4 TX pairs run partly on F.Cu.
- **Length matching not done**: PCIe pairs differ by up to 9 mm (lane 4 RX), ETH pairs by up to 10 mm (P1). `bt tune` has not been run.
- **Hand-drawn pieces**: three ETH ESD bridges (0.2 mm straight F.Cu segments), the CM4 PCIe escape stubs, the M.2 escape stubs and vias (generated in Python from the socket geometry), one +12V protrusion in the In2 zone.
- **Via count**: 599 vias on the board. The GND vias (about 200) are at every decoupling pad; there were no stitching vias along the board edge.
- **Power neck**: see above; the +3.3V_M rails are the places to add vias before fab.

**Not done**: stitching vias around the edge and near high-speed transitions; thermal vias under the ASM1184 exposed pad (U12 pin 65); refilled-zone check after the last edits (the final `bt check` did refill, so the saved fills are current).

Files: `/work/progress/001..005` (the planes, PCIe, Ethernet, bulk pass, power and ground). `/work/BT-REVIEW.md` covers the bt tool.
