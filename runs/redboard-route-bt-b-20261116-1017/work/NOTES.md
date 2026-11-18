# Routing notes – SparkFun IoT RedBoard ESP32-P4 (4 layers)

Result: `SparkFun_IoT_RedBoard-ESP32-P4_WiFi_BLE.kicad_pcb` is fully routed (2073 track segments, 423 vias, 5 zones).
KiCad 10 DRC incl. schematic parity: 0 unconnected, 0 parity errors, no clearance/short/width errors.
What remains in the report: 12 courtyard overlaps and 4 silkscreen-edge warnings that were already in the placed board, and 4 "via dangling" warnings (see below).
No footprint was moved (checked: position/rotation/side of all 292 identical to the original).

## Layer use
| Layer | Use |
|---|---|
| F.Cu | components, all MIPI pairs that could stay planar, C5 SDIO bus, short decoupling links, GPIO fan-out; GND pour in the gaps |
| In1.Cu | solid GND plane, no tracks. It is 0.1 mm under F.Cu, so everything fast on top has an unbroken reference |
| In2.Cu | GND everywhere except a 3.3V region under U1 / U4 / the C5 module (the two regulators' loads). A few tracks: 1.1V core spine, VDD_FLASH / VDD_MIPI links, UART0+IO11 hop, and some slow nets that had no other way (listed below) |
| B.Cu | pairs that had to cross (USB-HS, CSI CLK, DSI D0), SD-card bus, GPIO bundle to the headers, ADC bundle, power feeders; GND pour |

Stack-up as found in the file (0.1 mm prepreg outer, 1.24 mm core). Net classes added in the .kicad_pro: `Power` (0.4 mm), `USB` (0.14/0.15 → ≈90 Ω),
`MIPI` (0.127 with 0.2–0.22 gap → ≈100 Ω); Default track 0.15, via 0.5/0.3 (0.45/0.3 only in tight spots – that is the board's stated minimum). Clearance stays 0.127 everywhere.

## Decisions worth knowing
- **MIPI / USB are not planar with this placement.** The staggered FPC pads and the U1 pin order force one crossing in DSI and one in CSI.
  DSI CLK and D1, CSI D0 and D1 are on F.Cu end to end. DSI D0, CSI CLK and USB-HS leave U1 through vias placed in the ring between the pin row and the exposed pad and run on B.Cu.
  Their reference there is the GND part of In2; In2 tracks cross under them only at right angles, right next to the launch vias.
- **USB-HS** passes the TVS D2 on B.Cu with short via stubs up to the D2 pads (the pads of each line are linked on top); staggered via column at J11, test points on the trunk.
- **Flash** (QSPI): WP/Q/CS on top, D/CLK/HOLD via B.Cu – not planar because of R33 and the VDD_FLASH caps.
- **C5 SDIO**: six lines on F.Cu, 19.6–27 mm (not length-matched; fine for 50 MHz SDIO). **SD card**: 19–27 mm, on B.Cu with one via pair each.
- **GPIO to the headers**: IO1–IO10, IO0 run as one ordered bundle on B.Cu under the C5 module's west pad row (nothing of the module is on B.Cu), UART0/IO11 cross it on In2 and continue on F.Cu.
  ADC lines IOA49–54 are a second ordered bundle on B.Cu.
- **1.1 V core**: buck → via → 0.45 mm In2 spine along U1's west side, In2 link along the top to pins 54/26, B.Cu branch to pin 91. Every VDD pin has its cap on the same layer, a few mm away.
- **3.3V** comes from the In2 region through vias at the caps.
- U1's exposed pad has 13 ground vias (kept sparse on purpose so the 3.3V region under the chip is not perforated).

## Not good / not finished – please look at these
1. **Vias in or at pads.** About 20 ground vias sit inside or on the edge of SMD pads because there is no room beside them:
   C20, C33, C34/C43 (shared), C44, C26, C35, C38, C40, R19, R27 (3.3V), R30, R33, C45 (3.3V), J6.22, J11 GND, Y1.2, D2.2 (edge), plus the 13 in U1's pad.
   Order the board with plugged/tented vias, or expect some solder wicking on these 0402 pads.
2. **MIPI intra-pair skew is only partly removed.** After `bt tune`: DSI CLK 2.35 mm, DSI D1 2.2 mm, CSI D1 ≈1.9 mm (incl. series-R side), CSI CLK ≈1.4 mm, CSI D0 0.4 mm, DSI D0 0.5 mm.
   That is up to ≈16 ps – acceptable at the P4's lane rates but not matched. The tuning bumps are very small (0.075–0.175 mm) wiggles.
   Pair-to-pair lengths are not matched at all (13.7–20.5 mm).
3. **Three pairs change layer** (2 vias each, 4 for USB-HS) and have no dedicated ground-return via right at the transitions – there was no room in the ring; the nearest ground vias are in U1's pad (~1 mm).
4. **Long auto-routed slow nets**: SDA 155 mm / 16 vias, SCL 132 mm / 8 vias, ~RST 94 mm / 7 vias, SD_PWR 53 mm, VDD_SD pull-up feed 111 mm total, 3.3V_P 191 mm total / 27 vias, 5V 168 mm total / 20 vias (0.6 mm).
   They work electrically (I2C ≤400 kHz, DC rails; 5V trunk ≈75 mΩ) but they are not pretty and I would redo them by hand with more time. Reset has its 100 nF at the pin.
5. **In2 is not a clean plane round U1.** It carries the 1.1V spine, VDD_FLASH/VDD_MIPI/3.3V lanes, UART0 TX/RX + IO11 (22 mm), ALRT, reset hop, and the slow nets IOB35 (17 mm) and the charge-LED line (≈35 mm at x 142.2).
   The 3.3V region is therefore narrow in places (west of U1 it is fed through R27's pad via and the strip between the lanes and the spine). A small unfilled patch of In2 lies under U1's top pin row.
6. **Four single-layer vias** (3.3V_P ×3, VDD_PSRAM ×1) are left from re-routing: harmless, reported as warnings.
7. Some auto-routed top-layer tracks pass under the C5 module body between its pad rows (not under the antenna; the keep-out is respected).
8. USB-serial pair (full speed only) has 2.5 mm skew and wraps U1's north-west corner on F.Cu; this is what made that corner so tight.
9. Not done: teardrops, silkscreen review, test of fab-specific rules (0.45/0.3 vias, 0.122 mm necks at the QFN are the board's own minimums).

## Files
- `progress/` – numbered pictures + notes of each stage, including the attempts thrown away.
- `scripts/` – the Python that generated the hand-planned parts (pairs, buses, fixes); `scripts/edge.py` is the outline helper.
- `BT-REVIEW.md` – review of the `bt` tool.
