# IoT RedBoard ESP32-P4 + ESP32-C5 – layout notes

## State of the delivered board

`SparkFun_IoT_RedBoard-ESP32-P4_WiFi_BLE.kicad_pcb` is placed and fully routed.
KiCad 10 DRC on the delivered file: **0 unconnected, 0 clearance/short errors, 0 schematic-parity issues.**
Left over: 10 `track_dangling` warnings (dead-end stubs, 0.04–2.5 mm), and 7 courtyard overlaps + 4 silk-edge warnings that are between locked parts and existed before I started.
Locked parts are untouched (`bt same`: nothing locked moved, no parts added/removed, pad nets unchanged). The `.kicad_pro` is byte-identical to the original.

**I would not order this board as it is.** It is electrically complete and DRC-clean, but the power layer and part of the low-speed routing are not at the standard the brief asked for. The section "Not good" below says exactly what, most serious first.

## Placement

- **ESP32-P4 (U1)** at 156/106, rotated so pins 27–52 (flash, MIPI DSI/CSI, USB) face north to the FPC connectors and USB, pins 1–26 (SDIO, GPIO) face east to the C5 module and headers.
- **ESP32-C5 module (U3)** on the right edge between the two standoffs, antenna end flush with the board edge, antenna keep-out over the edge strip. This is also what the locked "ESP32-C5" silk bracket implies.
- **Flash (U4)** at the NE corner of U1, oriented so D/CLK/HOLD/VDD go round its north side and WP/Q/CS enter the channel between pad row and centre pad: no vias on any flash line (12–16 mm).
- **MIPI CSI series resistors** in one row between U1 and the J5/J6 corridor, in pin order.
- **Decoupling** in a ring round U1, each supply pin running straight to its own capacitor; the west side (LDO outputs, VDD_LDO, VDD_DCDC) has two columns. C26 sits directly at VDD_MIPI pin 41, C41 at the USB-PHY pin 51.
- **Buck converter** (U5, L1, C6, C7) at the SW corner next to the DCDC/FB/EN pins; input loop C6–U5 and L1–C7 are short and wide; the feedback divider is on the far side from the switch node.
- **Crystal** 3 mm south of pins 99/100 with its load caps beside it.
- **LDOs + power mux** SE of U1 next to the 5V/3V3 header pins; **charger and fuel gauge** next to the LiPo connector.
- **SD pull-ups** in a column right at the card pads; **USB ESD arrays, CC resistors, VBUS diodes** at the two USB-C connectors; **LEDs** beside their silk labels; **C5 reset/boot transistors and SDIO pull-ups** in the C5 bracket area.
- **Bottom side**: test points and solder jumpers beside their bottom-silk labels (that is what the labels are for), and the LM1117 block (U10, C52, C53, R16, R17, D10) under the SD socket. A SOT-223 does not fit on top without covering silk or taking the power corner; on the bottom its tab has a copper pour.
- **JP5 (LED_DO)** is *not* at the top of its label: it sits at the lower end of the label next to the header pin, because at the upper end it collided with VIN and SD_CMD on the bottom layer.

## Layer stack use

| Layer | Use |
|---|---|
| F.Cu | components, all controlled-impedance pairs, flash, SDIO bus, GND pour |
| In1.Cu | solid GND plane, nothing else on it |
| In2.Cu | 3.3V plane, 1.1V island under U1 fed by the buck – **and, against my plan, 428 mm of tracks** (see below) |
| B.Cu | GPIO/low-speed routing, power trunks, test points, jumpers, GND pour |

Stack is 0.1 mm prepreg outer / 1.24 mm core, so F.Cu is tightly coupled to the GND plane. Pair geometry used: MIPI 0.127 mm track at 0.35 mm pitch (≈100 Ω by the usual microstrip formula, not field-solved), USB 0.15 mm at 0.35 mm pitch (≈90 Ω).
Net classes and design rules are unchanged.

## Routing approach

- Critical nets were drawn by script with explicit coordinates (`scripts/esc_n.py`, `esc_n2.py`, `esc_wse.py`, `usb_ser.py`) and checked before writing: all MIPI lanes, both USB pairs, flash, crystal, the P4 pad escape, the buck loop.
- **MIPI DSI**: the pin order of U1 and J6 cannot be joined in one layer (I worked the planar order through). CLK goes up the west side of J6, D1 the east side, both entirely on F.Cu; D0 hops 5 mm on B.Cu and comes up between the pad columns.
- **MIPI CSI**: same problem at J5; D0 and D1 stay on F.Cu, CLK hops on B.Cu after its series resistors.
- **USB HS (OTG)**: F.Cu from U1 to the ESD array, then 11 mm on B.Cu past TP3/TP4 to J11. 49.9 / 51.5 mm, 2 vias each.
- **USB serial/JTAG**: all on F.Cu, with 1 mm bottom stubs to TP1/TP2.
- **P4 escape**: 0.35 mm pitch leaves no room between pads, so alternate signal pins have a via inside the pad ring (between pad row and thermal pad) and the others a via just outside. 1.1V pins have in-ring vias into the island.
- **SDIO to the C5**: six lines on F.Cu, no vias, 18.6–23.3 mm.
- **SD card**: stub and via between each card pad and its pull-up, then B.Cu, 21–28 mm.
- Everything else was routed by `bt route` in stages with the hand-routed nets held fixed (`scripts/rt.sh`).
- 5V, 3.3V_P, VIN, VBATT, VRAW are 0.4–0.6 mm; 5V_BAR has a pour under the regulator tab.

## Not good – most serious first

1. **The In2 power layer is cut up.** It carries 428 mm of track, including GPIO (CAM_IO 37 mm, UART0 RX 25 mm, SCK 21 mm, IO7 15 mm, analog lines) and supply links. After the first complete route KiCad found 1.1V in 4 pieces and 3.3V in 6. I removed the three worst cuts and joined the rest with explicit tracks, so DRC is clean, but:
   - parts of the 3.3V and 1.1V distribution near U1 now depend on narrow link tracks (some 3.3V links are 0.127–0.2 mm) instead of plane copper;
   - bottom-layer signals that reference In2 cross slots in it.
   I did not measure plane resistance or check decoupling loops after this. This is the main reason I would not order the board.
2. **The cause is my P4 escape.** In-ring vias at 0.7 mm pitch plus a second row just outside the pads act as a fence on B.Cu: a bottom-layer track cannot pass between them. Two signal layers were then not enough, and the router went to In2. A proper fix is a redone fan-out (staggered rows at 1.4 mm pitch, or a different via pattern per side) – that means re-routing most of the low-speed nets.
3. **MIPI pairs are not length-matched.** Intra-pair skew: DSI CLK 3.6 mm, DSI D1 3.7 mm, DSI D0 0.5 mm, CSI CLK 4.0 mm, CSI D1 2.7 mm, CSI D0 2.0 mm (≈15–27 ps). Lane-to-lane lengths differ as well (DSI 13–20 mm). No tuning was done. USB HS skew is 1.6 mm.
4. **Long, via-heavy low-speed nets**: SD_PWR 98 mm with 6+ vias, UART0 TX/RX 69/63 mm, the LED data-out net ~55 mm, SD_D2 with 5 vias, VDD_SD rail assembled from many thin segments. They work electrically but are not how one would draw them.
5. **Thin supply bits**: VDD_SD and VDD_FLASH links are 0.127–0.2 mm; a few track necks are 0.122 mm (the board minimum is 0.12192 mm); the 5V entry into the power mux is 0.25 mm for ~1 mm via a via under the IC.
6. **Via-in-pad** at J6 pin 22 and C40 pad 2 (both GND), because no other spot was free. One 1.1V via connects the buck output to the island; a second did not fit.
7. **Not done at all**: GND stitching vias and return vias beside the pair layer changes, teardrops, any 3D/mechanical check, any thermal estimate for the LM1117 beyond giving its tab a pour, tidy-up of the 10 dangling stubs.
8. **Things a reviewer may question**: SDIO runs on F.Cu under the west end of the C5 module; the VIN trunk passes on B.Cu under the buck converter area; the USB test points sit in line (HS) or on 1 mm stubs (serial).

## Files

- `scripts/` – placement table (`place.py`), the hand-routing scripts, `rt.sh` (router wrapper with the fixed-net list), `check.py` (real KiCad DRC with refill), `mode.py`.
- `scripts/mode.py` matters if anyone re-runs `bt` on this board: the outline lives inside footprint H1, which `bt` cannot read. While working I kept H1's outline lines on the Margin layer plus a board-level copy; the delivered file has been converted back (H1's nine Edge.Cuts lines restored, the copy removed).
- `progress/` – numbered pictures and notes, including the two approaches that were thrown away.
- `BT-REVIEW.md` – review of the `bt` tool.
