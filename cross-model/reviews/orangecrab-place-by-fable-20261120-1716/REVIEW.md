# OrangeCrab layout review: boards A, B, C, D

## Verdict

**Order A.** It is the only board that is electrically complete, fits a plain through-via 6-layer order, and shows careful high-speed and power work. B is complete and DRC-clean but needs an HDI build and has a 0.105 mm main power path. D is a sound design that would arrive dead: the FPGA's 2.5 V auxiliary supply and most of its 1.35 V I/O supply balls are not connected to their regulators. C is unfinished: 114 of 170 nets are incomplete.

| Board | EMI | SI | Power | Placement | Routing / mfg | Overall |
|---|---|---|---|---|---|---|
| A | 8 | 9 | 8 | 8 | 7 | **8** |
| B | 5 | 5 | 4 | 5 | 5 | **5** |
| D | 5 | 5 | 3 | 6 | 3 | **4** |
| C | 2 | 2 | 2 | 3 | 1 | **1** |

**Ranking: A, B, D, C.**

## How I checked

- I worked on copies; nothing in `/work/boards` was changed.
- KiCad 10.0.8 DRC ran on every board with all severities and courtyard checks. For B, C and D it also ran after a zone refill. A's refill did not finish in the time I gave it, so A's result is for the fills as saved (nothing indicated they were stale).
- Everything else was measured with `pcbnew` scripts: per-net length, layer and via count; pair gap along the route; which plane lies on the adjacent layer under each signal segment (sampled every 0.15 mm); ground-plane voids on a 0.2 mm grid; pad-to-pad distances for decoupling and regulator loops.
- No NOTES.md and no schematic were in the review folders, so intent is inferred from the netlist and the layout.
- Coordinates are KiCad mm, y down. The board spans x 134.51–185.31, y 91.52–114.38.

Three findings are inherited from the locked parts and appear on every board, so I did not count them against anyone:
- 84 edge-clearance errors on the castellated J1/J2 pads (B waived them with a custom rule).
- A malformed courtyard on J5.
- A courtyard overlap between H4 and FID6.

All four boards keep the locked connectors, holes, fiducials and logos in identical positions, and all have the same 163 footprints.

On DDR3 skew: this board runs short point-to-point links of 5–20 mm. A 10 mm mismatch is about 70 ps, which the interface tolerates at the speeds an ECP5 reaches. I score matching as workmanship and margin, not as pass/fail.

---

## Board A — overall 8

Stack use: F signal / In1 GND / In2 signal / In3 split power / In4 GND / B signal. 441 vias, all through (0.30/0.15 and 0.28/0.15). 2848 mm of track.

### EMI — 8
- In1 and In4 are unbroken GND planes (890.9 mm² each). The largest void is 3.2 mm², at the J6 pin antipads (153.3–154.9, 96.6–98.2).
- 94.1 % of all signal length has GND on an adjacent layer; 5.9 % has no plane adjacent, mostly the Feather pin escapes.
- Buck input loops are about 0.8 mm² each (VIN to Cin 1.0–1.1 mm for U1/C6, U2/C7, U7/C11). Each regulator has its own small F.Cu pours for VSYS, the switch node and GND.
- 141 GND vias. No signal track runs within 0.9 mm of the board edge.
- Weak points:
  - The B.Cu GND pour is cut into 46 islands by routing.
  - In2 sits over a split power layer on its other side, so In2 nets cross In3 rail boundaries (the USB pair changes its adjacent-plane set 12 times). In1 GND is continuous above them.
  - Plane fills on In1/In3/In4 come to 0.15 mm from the edge at (134.51, 94.06); the board rule is 0.25 mm.

### Signal integrity — 9
- DDR3 address/control: 14.99–15.22 mm on 24 nets, with RAM_A7 at 15.56 mm.
- DDR3 data: lane D0–7 is 15.32–15.85 mm; lane D8–15 is 15.84–15.91 mm (RAM_UDM 15.45 mm).
- Strobe pairs are matched to 0.05 mm or better; RAM_CK+/− is 21.70/21.71 mm. Pair gap is 0.2 mm or less for 13–16 mm of each.
- Each DDR net uses 0 or 2 vias. Lane D0–7 is on B.Cu over In4 GND; lane D8–15 is on In2.
- USB connector side: /IO/_USB_D_P 30.11 mm, /IO/_USB_D_N 29.90 mm; gap 0.2 mm or less for 25 of 30 mm; vias placed as pairs at (155.58, 94.56/94.13) and (139.39, 102.67/102.23).
- USB FPGA side: USB_D+ 4.08 mm, USB_D− 4.73 mm, no vias.
- REF_CLK is 3.11 mm on F.Cu with no via, fully over GND. OSC1 is 2.3 mm from ball A9.
- Flash nets are 5.0–18.4 mm.
- Minor: RAM_LDM runs on In2 while its lane is on B.Cu, and RAM_UDM the reverse. TP26/TP27 hang off the USB pair as short stubs near J3.

### Power — 8
- Every rail has a pour on In3: VSYS 47 mm², PUSB_VBUS 23 mm², VBATT 19 mm², P1.35V 77 mm², P1.1V 31 mm², RAM_VDD 94 mm², RAM_VDDQ 52 mm², P3.3V 464 mm². Power tracks are short stubs at 0.2–0.25 mm.
- All 27 FPGA bypass caps are on the back under U3, 0.27–2.8 mm from their balls and 23 of them within 1.3 mm (C19 to C15 ball 0.27 mm, C61 to J5 ball 0.28 mm, C65 to M5 ball 0.38 mm).
- The small RAM caps are 0.1–3.6 mm from their balls (C36 to R9 0.12 mm, C34 to B2 0.54 mm, C30 to D9 3.6 mm).
- Charger caps C13/C12/C77 are 1.05–1.23 mm from U5. LDO caps C46/C47 are 0.96/1.44 mm from U10.
- Minor: buck output-cap ground returns to the regulator ground pin through the plane (about 6 mm pad to pad). C26 and C69 have their nearest GND via 2.3 mm away.

### Placement — 8
- Clear functional blocks: charger and three bucks between USB/battery and the FPGA; RAM to the right; flash 10 mm below the FPGA; oscillator between FPGA and RAM.
- LEDs D1/D2 sit at the left edge by the 'CHG' legend; SW1 sits at the right edge by 'btn0'; TP26/TP27 sit at the 'D+'/'D−' legends.
- Density is the cost: 68 courtyard overlaps, with pad gaps down to 0.083 mm (TP30 to C67), 0.123 mm (C51 to R27) and 0.175 mm (R49/R50/R51). C13's courtyard intrudes into J3's. Buildable, but tight for 0201 assembly.

### Routing and manufacturability — 7
- 0 unconnected.
- DRC against its own rules is not clean, but nothing is electrically wrong:
  - 56 clearance errors, all numerical (0.0882 mm against 0.0889 mm, or 0.097–0.0999 mm against a 0.1 mm zone setting).
  - 13 NPTH-to-fill at 0.10 mm (rule 0.15 mm) at the J3 pegs and H3/H4.
  - 13 hole-to-hole at 0.202–0.249 mm (rule 0.25 mm), e.g. (161.335, 95.405) SD0_DAT0 to SD0_CMD.
  - 6 mask bridges at FID1/3/5; 1 duplicate B.Cu GND zone; 5 dangling vias (e.g. RAM_CKE at 171.252, 100.825); 3 dangling stubs.
- Through vias only, 0.15 mm drill, tracks mostly 0.121 mm with 0.089 mm necks: a normal 6-layer order at the fine end of the fab's range.
- 97 acute junctions, mostly GND tees.

**Before ordering:** clear the zone-edge and NPTH clearances, delete the duplicate B.Cu zone and the dangling vias, and confirm the assembler accepts the 0201 spacing.

---

## Board B — overall 5

Stack use: GND pours on F, In1, In2, In4 and B; P3.3V pour on In3; signals on all six layers. 695 vias: 468 through, 127 microvias F–In1 (0.23/0.10), 70 microvias In4–B, 30 buried In1–In4. A custom stackup is written into the file (0.085 mm outer prepreg, 1.028 mm core).

### EMI — 5
- In1, the main ground reference for F.Cu, carries 191 mm of track. Under the FPGA and RAM its antipads and track channels join into one void network of 97.6 mm² spanning 156.7–173.7 × 95.2–110.4. In4 has a similar 49 mm² network (155.5–172.1 × 95.2–107.6).
- Only 69 % of F.Cu signal length has GND on In1 beneath it. Over all layers, 73.6 % is GND-adjacent and 23.5 % has no plane adjacent.
- 121 mm of signal is routed on In1 itself, including RAM_D6 (9.8 mm), RAM_D11 (7.1 mm), RAM_RAS# (5.5 mm) and QSPI_D3 (6.9 mm).
- All three bucks are on the back directly under the FPGA/RAM area: U1 at (158.8, 106.0), U2 at (167.5, 102.5), U7 at (164.8, 109.3). The L2 switch node at about (165.4, 104.2) is under the DDR channel, with the perforated In4 as the only shield.
- Good: buck input loops are small (0.07–0.9 mm²), 136 GND vias, pours on both outer layers, nothing near the edge.

### Signal integrity — 5
- USB connector side: 28.21/29.62 mm (1.4 mm skew). 17 mm runs on In3 at 0.2 mm gap or less, but 7.3 mm is uncoupled and the vias are not paired: P at (155.72, 97.80), N at (155.72, 99.55); P at (139.57, 103.60), N at (140.35, 97.72).
- USB FPGA side: D+ is on F.Cu and D− on B.Cu, never coupled. Adequate for full-speed, but not a routed pair.
- DDR3 is not matched: lane D0–7 is 8.85–13.93 mm; lane D8–15 is 8.86–19.18 mm; address/control is 4.80–13.27 mm against a 19.5/19.8 mm clock.
- Layer changes are heavy: RAM_D11 has 6 vias and RAM_D9 has 5; several nets cross four layers.
- Strobe and clock pairs are matched within the pair (0–0.3 mm).
- REF_CLK is 4.88 mm on B.Cu with one via; 3.1 mm of it has no plane adjacent.
- Flash is 23.5 mm from the configuration balls: SPI_CONFIG_SCK is 53.75 mm with 6 vias over five layers; the other flash nets are 24–38 mm.

### Power — 4
- The main power path is routed at 0.105 mm: PUSB_VBUS 35.1 mm, VBATT 33.5 mm, VSYS 54.2 mm of track, joined by single 0.28/0.15 vias.
  - Examples: J5.2 to (144.78, 100.80) on F.Cu; VBATT (149.57, 95.65)–(146.12, 99.10) on In3; PUSB_VBUS (147.28, 96.28)–(142.57, 96.28) on In2.
  - The 'Power path' class is set to 0.35 mm, but only the three switch nodes (7.7 mm) use it.
  - On thin inner copper these traces will run warm at charger and system currents and will drop tens of millivolts. This is the one finding on B I would not ship.
- VSYS has an In2 pour (47 mm²) and P3.3V, P1.1V, RAM_VDD and RAM_VDDQ have pours, so distribution past the bottleneck is reasonable.
- Decoupling is mixed:
  - Good: 15 FPGA caps are within 0.1–2.5 mm (C50 0.07 mm, C53 0.50 mm).
  - Far: C57 3.0 mm, C58 4.3 mm, C61 4.8 mm (P1.1V); C62 3.9 mm (P1.35V); C67 4.0 mm (P3.3V); C55 3.5 mm (P2.5V).
  - FPGA VREF caps C1/C4/C19/C20 are 6.4–12.2 mm from ball H15.
  - The SD supply filter (FB1, C29, C70) is at (155.6, 107.1), about 15 mm from J4.4, on 20.3 mm of 0.108 mm track.
- Regulator loops are acceptable (VIN to Cin 1.3–2.3 mm).

### Placement — 5
- Good: charger at the USB/battery end; SW1 at (178.8, 105.8) near 'btn0'; D2 at (142.6, 109.8) by 'CHG'. This is the only AI board that respected the fixed legends.
- Weak:
  - Flash U6 is on the back at (181.75, 105.35), far from the FPGA.
  - The ADC parts are 15–21 mm from U3 (C28 is 14.9 mm from ball G3, R46 20.9 mm from G1).
  - The CK termination R5/R13 is 6.5–6.9 mm from the RAM balls.
  - The VREF divider R1/R2 is 8.6 mm from U4.H1.
  - The bucks are under the BGAs.
  - TP26 is 0.34 mm from the board edge at (135.6, 108.7).
  - 49 vias sit in SMD pads, 21 of them on capacitors, resistors and inductors (C56.2, C7.1, L2.1, L3.2).

### Routing and manufacturability — 5
- Electrically complete and the cleanest DRC of the four: 0 unconnected, and only the two inherited courtyard errors, before and after refill.
- It is not a standard 6-layer order. 197 laser microvias and 30 buried vias mean a 1+4+1 HDI build with sequential lamination and a custom stackup. JLCPCB offers this through its HDI service, but not on the standard multilayer order the job describes; cost and lead time go up accordingly.
- 2605 mm of track is 0.09–0.108 mm wide. 39 acute junctions.

**Before ordering:** widen VBUS/VBATT/VSYS to 0.3 mm or more, or pour them. Then either accept an HDI quote or re-route the blind vias as through vias. Move the SD filter to the socket.

---

## Board D — overall 4

Stack use: F signal / In1 GND / In2 signal / In3 GND / In4 split power / B signal. 457 vias, all through (0.30/0.15 mostly). 2647 mm of track.

### EMI — 5
- Good: In2 carries 817 mm of signal as stripline between two GND planes, 93 % covered. In1 is clean (largest void 4.4 mm²).
- B.Cu carries 395 mm of signal referenced only to the split power layer In4: 67 % over a rail island, 33 % over nothing, and no GND adjacent anywhere. IO_SDA and IO_SCL each run about 12 mm over bare In4.
- In3 GND is slotted by 92 mm of signal routing, mostly ADC nets. ADC_SENSE_HI runs along y ≈ 94 from x 147.5 to 162, and with ADC_MUX2/3 and ADC_CTRL0/1 forms a 41.9 mm² void network (149.1–163.9 × 95.2–104.2) under the FPGA's top-left quadrant.
- There are no outer-layer ground pours.
- The 1.35 V buck (U2, L2, C7–C9) sits at the right edge, x 181–185. VSYS on F.Cu comes within 0.37 mm of the edge at (184.74, 103.55), fed by a 17 mm VSYS track on In4 across the board.
- Several ground pads float (see Routing).

### Signal integrity — 5
- DDR3 is disciplined in topology: almost every net is F.Cu to In2 with exactly 2 vias, and strobe/clock pairs are at 0.12 mm gap or less for 6–10 mm.
- The designer grouped the strobes with their physical byte lanes (the netlist names LDQS/UDQS are swapped against the RAM pins); the net classes reflect that.
- Lengths are not matched: lane D0–7 is 7.04–14.43 mm; lane D8–15 is 11.51–17.18 mm; address/control is 6.49–14.55 mm against a 17.2/18.4 mm clock (1.2 mm skew within the clock pair).
- Six lane-1 nets run on B.Cu over the split In4: RAM_D8, D10, D11, D12, D15 and RAM_UDM.
- USB connector side: 20.89/18.39 mm (2.5 mm skew). Only 4.8 mm is at 0.3 mm gap or less; 11.6 mm is at 0.3–1 mm. Three vias per net.
- USB FPGA side: 7.35/9.76 mm with 2 vias each.
- REF_CLK is 10.24 mm with 2 vias, 8.1 mm of it on B.Cu over In4 with 8 reference changes. OSC1 is 5.9 mm from ball A9.
- Flash is good: 5.3–9.3 mm.

### Power — 3
- Widths are right: PUSB_VBUS 0.4 mm, VBATT 0.3 mm, VSYS 0.4 mm, switch nodes 0.4 mm.
- Decoupling placement is the best of the AI boards: FPGA caps 0.25–3.8 mm from their balls (20 of 27 within 1.3 mm), eleven RAM caps within 1.3 mm, buck Cin 1.12 mm from VIN.
- It scores 3 because the rails do not reach the FPGA:
  - **P2.5V (VCCAUX):** the LDO output island is only U10.1, C47 and TP30. FPGA balls E6, E13, P13 with C49 form a separate island; ball N6 is alone; C51, C53 and C55 float. The FPGA cannot configure.
  - **P1.35V:** the regulator reaches only balls B18, C6 and D17. Balls G14, H14, K15, K16, K17, M14, N14 with C66/C68 form an unfed island, and G5/H5 form another. The DDR I/O supply is missing.
  - U5's back-side thermal pad (146.0, 103.8) has no vias, and U6's exposed pad is not grounded.

### Placement — 6
- Good: FPGA/RAM arrangement like A; all FPGA caps under the BGA; flash under the FPGA on the back; VREF divider 0.35 mm from U4.H1; CK termination 1.2 mm from the balls.
- Weak:
  - The 1.35 V buck is at the far right edge, 35 mm from the charger.
  - The ADC front end is 22 mm from the FPGA (C28 at 142.75, 107.85).
  - CC resistors R16/R14 are 8.7/6.6 mm from J3.
  - D2 (charge LED) at (150.4, 104.2) is 11 mm from its 'CHG' legend at (140.0, 109.4).
  - SW1 at (182.4, 99.2) is 7 mm from 'btn0' at (184.3, 106.3), with a pad 0.31 mm from the edge.
  - The fixed silk now collides with moved parts (55 silk-on-pad warnings); for example the 'A1' legend sits on R49.1.

### Routing and manufacturability — 3
- 27 unconnected items in 6 nets: GND 14, P2.5V 6, P1.35V 3, P1.1V 2, ECP5_VREF 1, VSYS 1.
- Besides the supply opens, these pads float:
  - SW1.1 GND, so the button is dead.
  - U9.12 GND, so the ADC mux is unpowered.
  - FPGA GND balls E12, L16, L17 and U14.
  - U9.17, U9.18 and U9.19 (rail monitoring inputs).
  - D2.1 VSYS, so the charge LED is dead.
- DRC also reports:
  - A GND via at (181.494, 100.839) landing on the OSHW logo copper.
  - 2 starved thermals at J2.4.
  - 10 dangling tracks (e.g. P3.3V at 159.92, 96.85) and 8 dangling vias.
- 235 acute junctions, the most of any board, and 5 % any-angle routing.
- In its favour: through vias only at 0.15 mm drill, so the process fit with a standard order is fine.

**Before ordering:** close all 27 opens, starting with P2.5V and P1.35V. Move the GND via off the logo. Put GND, not split power, under the B.Cu signals, or move those nets to In2.

---

## Board C — overall 1

Stack use: GND on F, In1 and most of B; small rail islands on In2/In3/In4/B. 222 vias. 1096 mm of track, against 2650–2850 mm on the complete boards.

### EMI — 2
- Only 48.9 % of the routed signal length has GND adjacent.
- In3 carries 257 mm of signal with 68 % over no plane. B.Cu carries 123 mm with 75 % over no plane.
- 26 GND vias in total; most bypass caps have no ground via within 3–12 mm.

### Signal integrity — 2
- The USB pair from J3 is not routed. USB_D+/D− are 1.1/1.7 mm escape stubs with 27–31 mm missing.
- DDR3 is partly routed: 5 of 11 nets in lane D0–7, 9 of 11 in lane D8–15, 18 of 28 address/control. RAM_CK+/− are not routed.
- What is routed is unmatched (6.3–17.7 mm) and largely on In3 with no reference plane.
- SD is unrouted apart from SD0_CD.
- REF_CLK is a 1.1 mm stub, 4.3 mm short of the oscillator.

### Power — 2
- No rail is delivered: P3.3V is in 31 pieces, P1.1V 18, VSYS 14, RAM_VDD 15, ECP5_VREF 15, P2.5V 7. PUSB_VBUS has no copper at all.
- The FPGA bypass caps are parked in rows away from the BGA: y = 95.0 (x 165.6–170.4), y = 109.3 (x 166.0–177.2) and y = 110.9 (x 166.8–174.8). They are 4.1–7.6 mm from their balls and mostly unconnected.
- The three bucks are laid out as identical tidy cells (switch pin to inductor 2.27 mm), and the tracks that do exist on power nets are 0.5 mm, but nothing feeds them.

### Placement — 3
- FPGA and RAM are swapped relative to the other boards: U3 at (171.5, 102.5), U4 at (161.5, 102.5). That puts the FPGA 30 mm from USB, SD and JTAG; JTAG_TMS/TDO are 31 mm each.
- 0201 pads are placed on top of connector pads in place of routing:
  - R3.1 at (163.72, 112.11) sits on the J2.10 header pad; R6 and R51 do the same on J2.9 and J2.8.
  - R40–R43 sit on the microSD pins (R43.2 at 141.62, 99.77 on J4.1).
  - This is an assembly defect.
- The charge LED D2 is on the back at (149.2, 96.3).
- Good: CK termination and ZQ resistor are at the RAM balls (0–0.25 mm).

### Routing and manufacturability — 1
- 210 unconnected items; 114 of 170 nets incomplete; 1252 mm of ratsnest left.
- 65 dangling track ends, 9 dangling vias, 71 silk-on-pad warnings.
- RAM_ODT changes layer at (166.135, 100.75) with no via.

**Not reviewable as a finished layout; do not order.**

---

## Ranking

1. **A** — complete; standard process; matched DDR3 and USB; pours for every rail; decoupling under the BGA. Its faults are housekeeping and tight 0201 spacing.
2. **B** — complete and DRC-clean, so it would probably work. It needs an HDI build, runs the whole power input through 0.105 mm tracks, perforates its ground planes under the BGAs, and places the flash, ADC parts and SD filter far from where they belong.
3. **D** — better architecture, power widths and decoupling than B, and a standard process. But as drawn it cannot boot (VCCAUX open, VCCIO mostly open), and the button, charge LED and ADC mux are dead. I rank it below B because a costly board that works beats a cheap one that does not. It is closer to A in intent, and closing 27 links would move it to second.
4. **C** — about a third routed.

## Which board is the human's

**A, about 95 % sure.** The scores above were set before this guess.

- The DDR3 nets are tuned to a target (24 address/control nets within 0.22 mm of 15.0 mm, data lanes within 0.6 mm), with serpentines. None of the others attempts matching.
- There are 20 small hand-drawn pours on F.Cu around the regulators, each with its own priority, and ten rail islands on In3. This is the texture of an iterated manual layout.
- Only J3 and J5 are locked in A. B, C and D each have the same 19 locked footprints the job describes, so A did not start from the stripped job file.
- A's rule violations are the kind a legacy human board accumulates (courtyard overlaps from deliberate dense packing, fills a few microns under a later rule), not unrouted nets or parked parts.
- B, C and D share machine traits: regular 0.05 mm placement grids, capacitors in uniform rows or identical regulator cells, and incomplete nets or unusual via technology used to get out of congestion.

## Sources

- [JLCPCB capabilities](https://jlcpcb.com/capabilities/Capabilities)
- [JLCPCB HDI PCB](https://jlcpcb.com/pcb-fabrication/hdi-pcb)
- [JLCPCB HDI capabilities FAQ](https://jlcpcb.com/help/article/hdi-pcb-capabilities-faq)
