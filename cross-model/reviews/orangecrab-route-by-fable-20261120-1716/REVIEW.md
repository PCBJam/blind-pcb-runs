# OrangeCrab layout review: boards A, B, C, D

Reviewed as delivered in `/work/boards/<label>/OrangeCrab.kicad_pcb` (working copies in `/tmp/rv`; the originals were not touched).

## Verdict

| Rank | Board | EMI | SI | Power | Placement | Routing / mfg | Overall | One line |
|---|---|---|---|---|---|---|---|---|
| 1 | **B** | 8 | 9 | 8 | n/a | 7 | **8** | Complete, through-vias only, DDR3 length-matched. Order this one after a short clean-up. |
| 2 | **D** | 6 | 5 | 6 | n/a | 4 | **5** | Complete and DRC-clean, but only buildable as a 2nd-order HDI board. Not a standard 6-layer order. |
| 3 | **C** | 5 | 3 | 6 | n/a | 3 | **3** | Good structure, but 29 nets are not routed (USB D−, JTAG, SD clock, reset). Dead as delivered. |
| 4 | **A** | 3 | 2 | 2 | n/a | 2 | **2** | 120 open connections, supply inputs open, shredded ground plane. Unfinished. |

Placement is `null` for every board: the job fixed it, and I confirmed that no footprint moved and no pad net changed between the four files.

**Only B can be ordered.** D would work electrically but needs a different (HDI) fabrication process. A and C would come back as non-functional boards.

## How I measured

- KiCad 10.0.8 DRC (`kicad-cli pcb drc`, all severities) on each board, with the saved zone fills. I also re-ran it after a zone refill for A, C and D; the results did not change.
- **B could not be refilled.** `kicad-cli --refill-zones` and pcbnew's zone filler both hang on B. Each F.Cu pour fills alone and every other layer fills fine; the hang appears only when the 20 small F.Cu pours are filled together. B's numbers therefore come from the fills saved in the file. A B.Cu-only refill reproduced the saved area (425.9 vs 424.1 mm²), so the saved fills look current.
- Python scripts on `pcbnew` + `shapely` for: track and via statistics, plane coverage per region, voids, routed length and via count per net, pair coupling and skew, reference-plane presence under each track, plane-split crossings, narrowest copper on each supply path, decoupling via distance, and tracks routed inside plane layers.
- `bt render` for each layer of each board, plus close-ups of the FPGA, regulators and USB.

Inherited by all four boards from the fixed footprints, and not scored against anyone:

- 68 courtyard overlaps, 84 edge-clearance errors on the castellated J1/J2 pads, 39 silkscreen text-height warnings, a malformed J5 courtyard, and library warnings.
- The silkscreen is identical on all four boards.
- No track is within 0.5 mm of the board edge on any board.

One point applies to A, B and C: none of them defines a stackup. In a standard JLCPCB 6-layer build the In2–In3 dielectric is thin prepreg (about 0.11 mm) and In1–In2 is a 0.55 mm core. That makes In3 the real reference for In2 signals, and In4 the reference for B.Cu. I judged reference planes with that in mind. D declares its own stackup (0.09 / 0.09 / 1.078 / 0.09 / 0.09 mm).

---

## Board B: overall 8

Layer use: F signals, In1 GND, In2 signals (981 mm), In3 power islands, In4 GND, B signals plus GND pour.

### EMI: 8

- In1 and In4 are each one unbroken GND piece of 891 mm². Coverage is 78 % under the FPGA (U3), 97 % in the U3–U4 corridor, 95 % under the regulators.
- No signal is routed in either GND plane. The only tracks there are GND ties.
- 141 GND through-vias, 9 of them within 2 mm of the edge. This is the best stitching of the four, though the top edge under J1 is still thin.
- Regulators U1, U2 and U7 have local F.Cu pours for VIN, SW, VOUT and GND, with 2–4 vias per capacitor pad. The hot loops are as tight as the placement allows.
- **Main weakness:** In2 signals cross In3 power-island boundaries 108 times (73 for DDR3 nets, 35 for USB, SD and SPI). Examples: RAM_A0 crosses P1.35V→P3.3V at (168.2, 98.8) and P3.3V→RAM_VDD at (170.1, 99.0); USB_D_N crosses VBATT→P3.3V at (147.4, 95.1). With a standard JLCPCB stackup In3 is the nearer plane, so these are real return-path breaks. Either specify a stackup with a thin In1–In2 dielectric or accept the penalty.
- The B.Cu GND pour is in 46 pieces and covers only 37 %. It is fill, not a reference.
- In1, In3 and In4 planes come within 0.149 mm of the board edge (the board's own rule is 0.25 mm).

### Signal integrity: 9

- DDR3 is length-matched:
  - Byte lane on U4 E3–H8: 15.32–15.85 mm (spread 0.53 mm).
  - Byte lane on U4 A2–D7: 15.45–15.91 mm (spread 0.46 mm).
  - 25 address and control nets: 14.99–15.56 mm.
  - RAM_CK+ / RAM_CK−: 21.70 / 21.71 mm, 90 % coupled at 0.25 mm centre spacing.
  - DQS pairs: skew 0.05 and 0.00 mm, 91–94 % coupled.
- Every DDR net has at most 2 vias (lane totals 22 / 22 / 39).
- USB: `_USB_D_P` 30.11 mm and `_USB_D_N` 29.90 mm, skew 0.21 mm, 90 % coupled at 0.28 mm centres, 3 vias each. FPGA side: 4.08 / 4.73 mm.
- REF_CLK is 3.1 mm on F.Cu over solid In1 GND, with no via.
- QSPI nets are 5–18 mm with at most 2 vias.
- Deductions:
  - The split crossings above.
  - Dangling vias left on DDR nets that run entirely on F.Cu: RAM_CKE (171.25, 100.83), RAM_BA1 (172.05, 99.20), RAM_A7 (177.63, 96.80). They are small stubs, harmless at DDR3-800.
  - The USB signal vias have no GND via nearer than 2 mm (median 2.67 mm).

### Power: 8

- Every rail has an island on In3: P3.3V 464 mm², RAM_VDD 94, P1.35V 77, RAM_VDDQ 52, VSYS 47, P1.1V 31, PUSB_VBUS 23, VBATT 19 mm².
- Switch nodes are short pours (narrowest point 0.6–0.8 mm). Output capacitors sit on pours about 1 mm wide.
- Decoupling under the FPGA: a via within 0.4–1.2 mm of almost every pad, and none left open.
- The charger (U5) thermal pad has 4 vias. No other board has more than one.
- Deductions:
  - VBUS enters In3 through a single 0.3/0.15 mm via per connector pin and travels partly on 0.15–0.2 mm tracks (17.9 mm at 0.15 mm on In3).
  - VSYS leaves U5 on 0.12–0.2 mm copper before it reaches the In3 island.
  - The P1.35V path to FB3 necks to about 0.15–0.2 mm.
  - All of this is adequate for the roughly 0.5–1 A involved, but it is not generous.

### Routing and manufacturability: 7

- 0 unconnected items.
- 441 vias, all through-hole: 273 at 0.3/0.15 mm and 168 at 0.28/0.15 mm. Tracks are mostly 0.121 mm, minimum 0.089 mm.
- This fits a JLCPCB 6-layer order at their minimum drill (0.15 mm) and with resin-filled via-in-pad, which is listed as free for 6 layers and up.
- To clean up before ordering:
  - 3 plane-to-edge violations at 0.15 mm.
  - 13 NPTH-to-plane clearances of 0.10 mm, at H4 (182.77, 94.06) and the J3 pegs (139.21, 100.06 and its twin).
  - 13 via pairs with 0.20–0.249 mm hole-to-hole spacing, e.g. (149.96, 107.73) / (150.34, 107.85).
  - The B.Cu GND zone exists twice (`zones_intersect`).
  - GND pour runs into the mask openings of FID1, FID3 and FID5.
  - 5 dangling vias (the three above, plus PUSB_VBUS at (145.41, 102.88) and EN at (154.42, 109.35)).
  - 3,846 segments shorter than 0.05 mm and 80 zero-length ones.
  - The F.Cu pour set that hangs the zone filler (see "How I measured").
- The 56 "clearance" errors are rounding-level, not real: 0.0882 vs 0.0889 mm, 0.097–0.0999 vs 0.1 mm, 0.198–0.199 vs 0.2 mm.

---

## Board D: overall 5

Layer use: F signals plus GND pour, In1 GND, In2 signals plus GND fill, In3 "power" plus 548 mm of signals, In4 GND, B signals plus GND pour.

### EMI: 6

- Four layers carry GND, and there are 136 GND vias. DDR signal vias have a GND via within 0.88 mm (median), the best of the four.
- The GND planes are perforated where it matters:
  - In1 covers only 56 % under U3 and has one merged 34.6 mm² void spanning (157.2, 96.4)–(167.0, 107.7), the DDR side of the FPGA.
  - In4 covers 63 % under U3.
  - 49 mm of signal is routed inside In1 and 53 mm inside In4, each crossed by other signals in 76 places.
- In3 is a power plane in name only. P3.3V is 414 mm² in 18 islands, and any-plane coverage is 27 % in the U3–U4 corridor and 30 % under U3.
- The In2 GND fill is in 22 pieces; the F and B pours are in 33 and 31.
- Only 1 GND through-via within 2 mm of the board edge.
- Regulator layout is sound: pours on VIN, VOUT and GND, switch nodes at 0.36 mm.

### Signal integrity: 5

- Good:
  - USB pair on In2: 26.40 / 26.26 mm, skew 0.13 mm, 82 % coupled, 2 vias each.
  - DQS pairs: skew 0.01 and 0.00 mm, 87–99 % coupled.
  - REF_CLK: 2.5 mm on F.Cu over GND.
  - The designer noticed that the schematic's "UDQS" net actually serves the D0–D7 lane and regrouped the net classes accordingly.
- Not good:
  - DDR data is not matched: 10.64–16.78 mm in one lane, 12.72–18.66 mm in the other. Address and control: 11.31–18.39 mm.
  - RAM_CK pair: skew 1.02 mm, only 69 % coupled.
  - Via count is excessive: lane totals 62 / 59 / 92, against 22 / 22 / 39 on B. RAM_UDM and RAM_BA1 have 10 vias each, RAM_D2 and RAM_D7 have 9 and visit up to six layers. SD0_DAT1 has 14.
  - 20–45 % of the length of many DDR nets has no GND directly on an adjacent layer (RAM_D4 42 %, RAM_BA1 46 %, RAM_CKE 43 %), because of the In1/In4 perforation.
- It should still run DDR3 at ECP5 speeds, but with much less margin than B.

### Power: 6

- VSYS has F.Cu pours and a 46 mm² In3 island. Regulator capacitors have vias within 0.5–1.0 mm. FPGA decoupling vias are within 0.06–0.9 mm. Nothing is open.
- Distribution to the loads is thin:
  - P1.35V reaches the DDR3 ferrites FB2 and FB3 partly on 0.127 mm track, e.g. F.Cu (160.5, 111.7)–(167.8, 111.7), 7.3 mm.
  - RAM_VDD has 33.7 mm of 0.127 mm track, e.g. In3 (168.1, 111.3)–(173.3, 111.3).
  - P3.3V has 78.5 mm of 0.127 mm track.
  - The P1.35V island on In3 is only 20 mm² in 6 pieces.
- U5 thermal pad: 1 via.

### Routing and manufacturability: 4

- DRC is clean apart from the inherited items: 0 unconnected, also after refill. A documented custom rule waives edge clearance for the J1/J2 castellations.
- **The via structure is the problem.** 858 vias in total:
  - 359 through.
  - 385 laser microvias at 0.25/0.1 mm: F–In1 166, In1–In2 93, In3–In4 39, In4–B 87.
  - 114 buried: In2–In3 86, In1–In4 28.
  - 115 stacked sites. 41 are three-high (F–In1 on In1–In2 on a buried In2–In3 via) and 2 are five-high. KiCad flags 31 co-located holes.
  - 31 microvias sit in BGA pads.
- This is a 2nd-order HDI build with stacked, filled microvias on capped buried vias and three lamination cycles. JLCPCB lists HDI up to 3rd order as a separate service, so it is buildable, but not as a standard 6-layer order. I have not priced it; expect a higher cost and a longer lead time.
- The brief asked for a board "ready to order as a 6-layer board". D meets that only on paper.

---

## Board C: overall 3

Layer use: F signals plus GND pour, In1 GND, In2 signals (705 mm), In3 GND, In4 power islands, B signals plus GND and VSYS pours.

### Not finished

29 nets are open (ratsnest 317 mm). The ones that kill the board:

- **USB D−** (`/IO/_USB_D_N`): only 3.4 mm routed; open between R29.2 (157.16, 94.72) and the connector.
- **JTAG_TCK and JTAG_TMS**: J6 to U3.U13 / U3.V13 not routed.
- **FPGA_RESET**: in 4 pieces.
- SD0_CLK, SD0_CMD, SD0_DAT3.
- RAM_RESET#.
- The USB-C CC pull-down: J3.B5 to R14.1 is open, so one plug orientation gets no VBUS.
- IO_0, IO_1, IO_5, IO_6, IO_10, IO_MISO, /IO/A1 to /IO/A5, USER_BUTTON, LED_G, Net-(R44-Pad1).
- C52.1 (P1.1V, at 160.12, 97.40) and C26.2 (GND, at 164.35, 107.07) are not connected.

With neither USB nor JTAG the FPGA cannot be programmed.

### EMI: 5

- In1 GND is one 870 mm² piece (80 % under U3). This is a sound choice: In2 sits between two GND layers.
- In3 GND carries 60 mm of tracks that cut slots under the In2 bus:
  - The P2.5V track from U10 toward the FPGA is crossed by 16 In2 nets, including RAM_D9 to RAM_D12, RAM_D14, RAM_UDQS+, QSPI_D3 and SPI_CONFIG_SCK.
  - The ECP5_VREF track running (165.2, 98)–(166, 105.5)–(161, 111) is crossed by 9, including RAM_RAS#, RAM_WE# and RAM_BA0.
- B.Cu DDR routes run over the In4 power islands and cross their boundaries 30 times, e.g. RAM_D0 at (166.95, 105.1), (170.77, 105.1) and (173.39, 105.1).
- 111 GND vias, only 2 within 2 mm of the edge.
- Regulator loops are acceptable.

### Signal integrity: 3

- USB, JTAG and SD are incomplete (above).
- DDR3 is connected except RAM_RESET#, but not matched:
  - Lanes: 8.28–19.77 mm and 11.33–17.21 mm.
  - Address and control: 7.57–16.91 mm.
  - One DQS pair is only 13 % coupled, the other 60 %.
  - RAM_CK: 23.62 / 24.28 mm, 74 % coupled, mostly on F.Cu.
- REF_CLK is fine (2.5 mm on F.Cu over GND).

### Power: 6

- Real islands on In4: P3.3V 359 mm², P1.35V 166, RAM_VDD 125, P1.1V 58, RAM_VDDQ 55 mm². VSYS has a 50 mm² pour on B.Cu.
- VBUS is on 0.4 mm track.
- FPGA decoupling is the tightest of the four: vias in or beside the capacitor pads, 0.03–0.3 mm away for most.
- Weak points:
  - The 3.3 V switch node (U7.4 to L3.1) is a 0.2 mm track.
  - P2.5V necks to 0.089 mm and is routed inside the In3 GND plane.
  - U5 thermal pad has no vias.
  - The two open capacitor pads above.

### Routing and manufacturability: 3

- Process fit is good: 436 through-vias only (0.28/0.15, 0.3/0.15, 0.45/0.2, 0.6/0.3 mm) and tracks of 0.089–0.2 mm. It would be a standard order, with 35 vias in capacitor pads needing fill.
- The file is not orderable: 29 open nets, 16 dangling track ends, 1 dangling via at (138.25, 101.72).
- 212 acute track corners.

---

## Board A: overall 2

Layer use: F signals, In1 GND (with 147 mm of signals in it), In2 signals, In3 GND, In4 power as 0.3 mm tracks, B signals. No pours on the outer layers and no power planes.

### Not finished

120 unconnected items; 54 nets in pieces; GND in 45 pieces; 57 dangling tracks; 43 dangling vias. The ones that kill the board:

- **VBUS**: J3.A4 (140.56, 100.50) is not joined to U5.13 or C77. USB power never reaches the charger.
- **VBATT**: J5.2 (146.21, 99.38) is not joined to U5.2/U5.3.
- **P2.5V**: U10 and C47 are not joined to any FPGA VCCAUX ball (net in 4 pieces).
- **RAM_CK+ and RAM_CK−**: open between U3.J18/K18 and the In2 tracks at (172.45, 102.0) and (172.45, 101.2).
- USB_D+ is open at (159.45, 96.65).
- JTAG_TCK, SPI_CONFIG_SCK, SPI_CONFIG_MISO and QSPI_D2 are open, so the flash cannot boot the FPGA.
- RAM_D11, RAM_D12, RAM_D15, RAM_A10, RAM_A13, RAM_BA0 and RAM_CAS# are open.
- About 16 decoupling capacitors have a floating GND pad, e.g. C52.2 (159.48, 97.40), C61.2 (161.70, 97.88), C19.2 (163.71, 103.40), C32.2 (178.78, 99.67).

There are 50 dangling fan-out stubs that all stop at the same distance from the BGAs (x = 179.25, y = 106.265, y = 95.2, x = 166.565, x = 155.835). Several are on unconnected FPGA pins, e.g. U3.A10 at (166.565, 101.15).

### EMI: 3

- In1 GND covers only 38 % under U3 and 53 % in the U3–U4 corridor. It is cut by 0.2 mm zone clearance around 75 microvias and by 131 mm of signal routed in the plane, which other signals cross in 126 places.
- In3 GND is better (73 % under U3, one piece).
- B.Cu (557 mm of signal) has no plane on the adjacent layer; In4 holds only tracks.
- 77 GND through-vias, the fewest of the four (B 141, C 111, D 106), and only 1 within 2 mm of the edge.
- The USB pair is not routed as a pair: `_USB_D_P` is 38.6 mm, `_USB_D_N` is 28.5 mm, 3 % coupled.

### Signal integrity: 2

- DDR clock and several data and address nets are open.
- No length matching: the address group ranges from 1.1 to 37.4 mm.
- REF_CLK and the QSPI stubs have no GND under them on In1.

### Power: 2

- Supply inputs are open (above).
- All three buck switch nodes are 0.089 mm tracks: U1.4–L1.1, U2.4–L2.1 and U7.4–L3.1, each about 1.3–1.6 mm long, on converters rated for 2 A.
- Rails are distributed as 0.3 mm tracks on In4, necking to 0.089–0.1 mm at the FPGA.
- U5 thermal pad has no vias, and its F and B halves are not joined.

### Routing and manufacturability: 2

- 75 microvias F–In1 at 0.25/0.1 mm make this a 1st-order HDI board, not a standard order.
- 1,428 segments (1,659 mm) are at 0.0889 mm.
- Overlapping drills: a GND microvia at (162.20, 104.90) on a via at (162.24, 104.85); two VBATT vias at (147.17, 95.74) and (147.12, 95.74).

---

## Ranking

1. **B**: the only board that is complete, uses standard through-via technology, and shows real DDR3 and USB signal-integrity work. Its faults are clean-up items plus one stackup decision.
2. **D**: complete and DRC-clean, with good USB and DQS pairs. It gets there with 499 blind, buried and micro vias and stacked structures, a perforated GND plane under the FPGA, and unmatched DDR. It would probably work, but on an HDI process.
3. **C**: the best-chosen stackup after B and the tightest decoupling, with standard vias. It was delivered with 29 nets unrouted, including USB D− and JTAG.
4. **A**: 120 open connections, including both supply inputs, the 2.5 V rail and the DDR clock. Switch nodes are on 0.089 mm tracks and the GND plane is shredded under the FPGA.

C ranks above A because it is far closer to done (29 open nets against 54), its power and ground are essentially complete, and it needs no HDI process.

## Which board is the human's

**B, about 92 % confident.** This guess was made after scoring and did not change the scores.

- B has serpentine length tuning that brings 25 address and control nets to 15.0 mm and both data lanes to within about 0.5 mm. No other board attempts tuning.
- Its 7,280 segments include 3,846 fragments under 0.05 mm and 80 zero-length ones, the residue of interactive push-and-shove routing and the length tuner.
- The In3 power islands are hand-drawn with priorities up to 13, and each regulator has its own small pours.
- It has keepout rule areas at the board-edge notches, a duplicated B.Cu GND zone, and rounding-level clearance leftovers (0.0971 vs 0.1 mm) typical of a design carried through several KiCad versions.
- It has dummy vias on F.Cu-only DDR nets, apparently to equalise via count.

The other three look machine-made:

- **A**: uniform-length fan-out stubs, including on unconnected pins.
- **C**: grid-regular vias dropped into capacitor pads, and straight unmatched buses.
- **D**: a single 0.127 mm width almost everywhere, programmatic stacked-via ladders, a custom DRC rule, and edited net classes.

## Sources for the JLCPCB process statements

- [JLCPCB HDI PCB service](https://jlcpcb.com/pcb-fabrication/hdi-pcb)
- [JLCPCB HDI capabilities FAQ](https://jlcpcb.com/help/article/hdi-pcb-capabilities-faq)
- [JLCPCB PCB capabilities](https://jlcpcb.com/capabilities/PCB-capabilities)
- [JLCPCB free via-in-pad announcement](https://jlcpcb.com/news/free-via-in-pad)
