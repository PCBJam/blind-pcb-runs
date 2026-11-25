# Layout review: RaspberryPiNVMeNAS, boards A, B, C, D

## Verdict

Ranking, best first: **A, B, D, C**.

| Board | EMI | SI | Power | Placement | Routing / DFM | Overall |
|---|---|---|---|---|---|---|
| A | 8 | 7 | 7 | 8 | 7 | **8** |
| B | 7 | 8 | 8 | 7 | 6 | **7** |
| D | 7 | 7 | 7 | 5 | 5 | **6** |
| C | 3 | 2 | 2 | 3 | 1 | **2** |

- **A** is the one I would order. It is complete, single-sided, heavily stitched and has textbook regulator layouts. It needs a zone refill and has three things worth fixing: one PCIe lane with 8.4 mm of skew, the CM4 5 V feed through single small vias, and copper 0.2 mm from the board edge.
- **B** is electrically as good as A or better (shorter matched PCIe, planes for power, tighter decoupling), but must not be ordered as it is: seven tracks run 0.05–0.11 mm from non-plated holes and plane copper touches those holes.
- **D** has the best PCIe geometry and decoupling, and the only defined stackup. It loses on build and product issues: 32 vias inside solder pads (including the M.2 and CM4 connector pads), all 16 status LEDs on the bottom side, and 185 parts on the back.
- **C** is not a finished board: 147 unconnected items across 77 nets, including power rails and regulator feedback.

Human guess: **A**, about 92 % sure (reasons at the end).

## How I checked

- All boards were copied to a scratch area; nothing in `/work/boards` was changed.
- KiCad 10.0.8 DRC was run three ways: on the files as saved, after a zone refill, and under one common, stricter rule set (edge 0.2 mm, hole clearance 0.2 mm, courtyards and silk checks on).
- Geometry was read with `pcbnew` and measured with my own scripts: pad-to-pad path length and skew per pair, coupling, the plane under every signal track, plane voids, decoupling distances, regulator loops, the narrowest copper on each power path, vias in pads, edge distances.
- Locked parts, pad nets and footprints are identical on all four boards.
- Not counted against anyone, because all four inherit them: 17 `footprint_type_mismatch`, 6 silk-on-edge warnings, and the 0.165 mm pad-to-peg-hole gap inside the J7/J15 USB-C footprints.
- Impedance figures are closed-form estimates, good to roughly ±10 %. A, B and C leave the stackup at KiCad's placeholder (three 0.48 mm dielectrics), so I judged their trace geometry against JLCPCB's real 4-layer stackups (0.21 mm or 0.10 mm prepreg).

## Board A

All 254 parts on the top side; 2212 track segments (84 arcs), 1049 vias, no net classes.

**EMI: 8**
- In1 is one unbroken GND piece (91 % of the board) with no tracks on it. In2 is 81 % GND with three local power islands (+3.3VSTB, +1V2, +3.3VA).
- 802 GND vias; 37 within 2 mm of the edge; via fences along the USB pair.
- Every differential via has a GND via 0.6–0.9 mm away.
- All layers are voided in a 26 × 26 mm window under the RJ45 (80.9–106.7, 55.0–80.9). The four Ethernet pairs run about 13 mm each with no reference plane there. This looks deliberate, but it is an impedance step.
- Seven PCIe nets on B.Cu cross the +3.3VA island on In2 next to U12 (3–16 mm each).
- GND pour is 0.198 mm from the edge; four stitching vias sit 0.225 mm from the top edge at y = 55.0 (x = 115, 130, 210, 220).

**SI: 7**
- PCIe: 14 of 15 pairs matched within 0.05 mm, 98–100 % coupled, two vias per net, symmetric.
- **PCIe_RX_3 has 8.4 mm of skew** (P 101.2 mm, N 109.6 mm). The extra length is a meander on the N line only, B.Cu at (158–162, 128.3–129.0). That is roughly 55 ps, a real margin loss at 5 GT/s.
- The downstream pairs are long, 76–107 mm, mostly on B.Cu, because U12 sits at (173.3, 123.5), 55–65 mm from the sockets.
- Trace geometry is inconsistent: 0.2/0.2 mm from the CM4, 0.127/0.2 mm to the sockets. The thin pairs come out near 100 Ω only on a 0.10 mm prepreg and about 125 Ω on JLCPCB's default 0.21 mm. No stackup is defined.
- Ethernet skew 1.6–3.3 mm, no vias (fine for gigabit). USB 1.9 mm skew, no vias.
- Crystal nets 8.2 and 3.4 mm on F.Cu, no vias, six GND vias around Y1. QSPI nets at most 11 mm, all on F.Cu.

**Power: 7**
- All seven bucks use copper polygons for VIN, switch node and output; input loop about 7.7 mm; feedback 2.5–3.4 mm.
- +12V is a 626 mm² F.Cu pour; each M.2 3.3 V rail is a pour over its socket pins.
- **+5V to the CM4 is one 0.8 mm track, about 82 mm long, passing through single 0.45/0.2 mm vias** at (122.63, 105.53) and (117.85, 110.15). That is roughly 50 mΩ and one small via carrying the whole module supply.
- The fan and LDO branch is about 145 mm of the same 0.8 mm track.
- U12 decoupling caps sit 2.2–4.3 mm from their pins, same side, each with its own via; U18 caps 1.6–2.6 mm. 13 thermal vias under U12, 5 under U3.

**Placement: 8**
- Single-sided assembly. LEDs next to the sockets they report on, RP2040 beside its USB-C and buttons, each buck beside its load.
- Nine courtyard overlaps: test points against C5, C12, C70 and IC1; D1 and R10 against the DC jack J6; C9 against C13.
- The PCIe switch is far from the sockets (see SI).

**Routing and manufacturability: 7**
- 0 unconnected, clean 45° routing, 13 acute corners.
- As saved, KiCad 10 reports 59 errors of its own: 40 zone clearances short by under 1 µm (the saved fill is stale) and 19 overlaps between same-net zones. Both are harmless but need a refill and cleanup.
- The project's hole clearance is 0, so a KiCad 10 refill pulls the pours up to the non-plated holes (64 places). The saved fill keeps 0.2 mm. Set the rule before refilling.
- 1035 of the vias are 0.45/0.2 mm; reference text is 0.5 mm high; 74 silk overlaps.

## Board B

109 parts on the back; 3073 segments, 755 vias; net classes for PCIe, ETH, USB and Power.

**EMI: 7**
- In1 is one GND piece (93 %), 11 mm of GND track only. In2 is 83 % GND with +12V, +5V, +3.3VSTB and +1V2 islands.
- Every differential pair runs over GND for its whole length; there is no void under the RJ45.
- Buck input loops are the tightest of the four (about 6.7 mm), with the 0805 input cap straddling the IC pins.
- Slow nets on B.Cu cross In2 plane boundaries 73 times (LED, enable, tacho, PCIe_RST, SCL_CM4, SD_CMD).
- Return vias at layer changes are far away: 1.8–4.0 mm for the CM4-side PCIe clock and TX pairs, up to 5.2 mm for PCIe_TX_1.
- 390 GND vias, but only one within 2 mm of the edge. A +3V3 track runs 0.325 mm from the left edge on B.Cu (x = 80.9).

**SI: 8**
- PCIe: all 15 pairs within 0.14 mm; lengths 27–85 mm; the five clock pairs have no vias; RX and TX have two each.
- 0.2/0.2 mm pairs come out near 90–95 Ω on JLCPCB's default stackup, so no special order is needed. The stackup in the file is still the placeholder.
- Ethernet: zero skew, no vias, 0.15/0.2 mm. ETH_P0 and ETH_P2 run 13–16 mm with a foreign track closer than 0.3 mm.
- USB (CM4) 3.1 mm skew, all of it at the connector; harmless at USB 2.0.
- Crystal 6.0 and 5.2 mm, no vias, solid GND on all three layers under Y1. QSPI at most 9.6 mm.

**Power: 8**
- +12V: pour at U3, then eight 0.6/0.3 mm vias into a 468 mm² In2 plane, two vias up at each buck.
- +5V: In2 plane with three 0.6/0.3 mm vias at the CM4 pins; fans on 0.6 mm track.
- Each M.2 rail: 139 mm² pour on B.Cu directly under the socket, five 0.6/0.3 mm vias to the pins.
- U12 caps on the back, 1.6–3.1 mm from the pins with a via 0.8–1.2 mm from each pin; U18 caps 0.5–1.0 mm. Nine thermal vias under U12, one under U3.
- The switch-node track is 0.5 mm wide for 3.9 mm, thin for 3 A. U6 has no local capacitor (nearest is 12.7 mm away).

**Placement: 7**
- U12 moved to (171.5, 87.5) between the sockets, which is what shortens PCIe. Bucks sit on the back under each socket. No courtyard overlaps.
- All 16 LEDs are stacked in one column at the left edge (x 82–85, y 68–108), away from the sockets they belong to.
- U12 sits on top of the existing title text on the silkscreen. Double-sided assembly.

**Routing and manufacturability: 6**
- 0 unconnected; clean under its own rules; vias are mostly 0.5/0.3 and 0.6/0.3 mm; edge clearance 0.3 mm.
- **Seven track segments are 0.05–0.11 mm from non-plated holes**:
  - Net-(R15-Pad1), F.Cu, (88.41, 64.75) and (84.36, 64.75), at the RJ45 posts
  - Net-(R14-Pad1), B.Cu, (87.06, 66.10), same posts
  - TSENSE_2, F.Cu, (196.70, 64.54) and (196.70, 65.44), at a J2 peg
  - J7 shell link, B.Cu, (107.42, 61.55) and (114.07, 61.55)
- **Plane and pour copper touches the non-plated holes** (0.0 mm, 76 places) on J2–J5, M1–M4, J7, J15 and U7, because hole clearance was left at 0.
- 59 reference texts land on pads, 38 silk overlaps, text 0.5 mm; 26 acute corners.

## Board C

154 parts on the back; 1549 segments, 485 vias.

**Not a finished board.** KiCad reports 147 unconnected items; 77 nets are open.

- Open power: +12V does not reach U2, U15, U10, U11 or U13; +3.3VSTB reaches none of the RP2040 pins; +3V3 is entirely unrouted; several CM4 GND pins are open.
- Open control: the 1.2 V regulator's feedback net (Net-(R5-Pad2)) is unrouted, as are M2PWR_EN, PCIESWPWR_EN, PCIe_RST_M2, CM4_RUN and CM4_EN.

**EMI: 3**
- In1 GND is good (94 %), but there are no GND pours on the outer layers and only 251 GND vias.
- In2 is 26 % +5V; signal tracks on B.Cu spend 32 % of their length over +5V and cross the +5V/GND boundary 32 times, PCIe and Ethernet included.
- In1 and In2 copper runs to 0.000 mm from the board edge. GND vias sit 0.154 mm from the edge at (210.8, 54.9) and (212.2, 54.9).

**SI: 2**
- The "pairs" are two separate 0.4 mm tracks: coupling 3–30 % on most.
- Skew: PCIe_RX_1 20.0 mm, PCIe_TX_4 11.1 mm, PCIe_CLK_4 10.6 mm, PCIe_TX_1 9.6 mm, ETH_P1 10.3 mm.
- Unequal via counts inside pairs (for example PCIe_CLK_4: 2 and 5). Crystal nets carry 2 and 4 vias. The Pico USB pair is incomplete.

**Power: 2**
- Rails open as listed. U2 and U15 have no input capacitors (nearest 10 µF is 17 and 28 mm away) and sit on the back directly under U12.
- No thermal vias under U12 or U3. The RP2040's LDO (U4) is 92 mm from the RP2040.

**Placement: 3**
- M.2 bucks are sensibly grouped under the sockets, but the points above and ten LEDs on the back pull it down.

**Routing and manufacturability: 1**
- Besides the opens: 8 dangling vias, 4 tracks 0.07–0.18 mm from non-plated holes, 91 acute corners, 199 silk overlaps (reference text never placed).

## Board D

185 parts on the back; 3898 segments, 845 vias; stackup set to 0.11 / 1.22 / 0.11 mm; net classes with pair geometry.

**EMI: 7**
- In1 is one GND piece (94 %), no tracks.
- In2 is a patchwork: GND 61 % in 104 pieces, ten power nets, and 160 mm of signal tracks. B.Cu signals run 37 % of their length over something other than GND, with about 100 boundary crossings (all slow nets).
- Differential pairs on B.Cu were given their own GND islands on In2, and every pair via has a GND via within 0.6–1.6 mm.
- 291 GND vias (31 % of 5 mm cells, about half of A and B), one near the edge. F.Cu and B.Cu pours are broken into 65 and 66 pieces.
- ETH_P2 runs within 1 mm of the left edge for about 10 mm.

**SI: 7**
- PCIe: all 15 pairs within 0.03 mm; the shortest runs of the four (22–71 mm); TX capacitors 4 mm from U12.
- 0.18/0.14 mm on 0.11 mm dielectric is about 85 Ω; USB 0.17/0.15 mm about 85–90 Ω. It only holds if the board is ordered on the matching thin-prepreg stackup.
- Ethernet is the weak spot: long sawtooth tuning on all pairs; **ETH_P0 has three vias on P and none on N**, 4.6 mm skew and about 26 mm uncoupled.
- The Pico USB pair has two vias on P and none on N.
- Crystal 6.1 and 5.4 mm, no vias; four slow nets pass under Y1 on other layers. QSPI at most 11 mm.

**Power: 7**
- Every rail has an In2 plane (+5V 1571 mm², +12V 748 mm², each M.2 rail about 250 mm²). 12 V input enters through ten vias at U3.
- Best U12 decoupling of the four: caps on the back 0.5–2.7 mm from the pins.
- Only four thermal vias under U12 and none under U3.
- Buck input loops are larger than A and B (9.5 mm and 14 mm). M.2 current reaches the pins through vias placed in the socket pads.

**Placement: 5**
- **All 16 status LEDs are on the bottom side** in a row at y ≈ 135, under the CM4 and away from the sockets.
- The top side carries only the ICs; 185 parts are on the back.
- Functional grouping is sound (U12 between the sockets, bucks at their loads), no courtyard overlaps. U12 sits on the title text.

**Routing and manufacturability: 5**
- 0 unconnected; clean under its own tightened rules (edge 0.25 mm, hole clearance 0.2 mm, one written exception for the USB-C pegs). References enlarged to 0.8 mm; only 7 silk overlaps.
- **32 vias inside SMD pads**:
  - sixteen 0.55 mm vias centred on 0.30 mm-wide M.2 pads (pins 2, 14, 16, 72 of J2–J5)
  - six 0.6 mm vias on 0.30 mm pins of U3 and IC1
  - one 0.52 mm via on the 0.20 mm CM4 connector pad Module1.83 at (89.70, 127.08)
  - five in 0402 pads (C81, R67, R69 ×2, R71)
  
  These need filled and capped vias or they will wick solder.
- Eight via sizes, 28 track widths, 22 % of segments off the 45° grid, 92 acute corners.

## Ranking reasons

1. **A**: complete, cheapest to assemble, best stitching and return-via discipline, proven-looking regulator and power-entry layout. Its faults are local and none stops an order.
2. **B**: better PCIe geometry, power distribution and decoupling than A, and the right trace sizes for the default stackup. It ranks second because the hole-clearance defects have to be fixed first, the return vias are far from the pair vias, and it needs double-sided assembly.
3. **D**: the most deliberate impedance work and the shortest PCIe. It ranks third on vias in fine-pitch connector pads, LEDs on the bottom, the fragmented second plane and the untidy Ethernet.
4. **C**: unroutable as delivered; would not power up.

## Which board is the human's

**A, about 92 %.**

- Only Module1 is locked in A. B, C and D all carry the same 38 locked parts the job description starts from, so A did not grow out of that starting file.
- A keeps every part on the top side; the other three all moved 109–185 parts to the back.
- Hand-work habits: 84 arc tracks, via fences along the USB pair, 44 keep-out areas, dozens of small hand-drawn power polygons, one manual tuning meander.
- Its saved zone fills do not match what KiCad 10 produces, and it has no net classes, which fits an older design carried forward.
- Its mistakes are human ones (a meander on the wrong side of one pair, test points crowding caps), where the other three show script-like regularity: identical regulator cells to the hundredth of a millimetre, or many odd track widths and via sizes.
