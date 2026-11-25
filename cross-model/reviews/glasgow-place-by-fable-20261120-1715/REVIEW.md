# Pre-fab layout review: Glasgow, boards A–D

**Verdict: order A.** It is the only board that is complete, electrically correct and buildable as a plain through-via 4-layer board. B is complete but is an HDI design (microvias and buried vias), D has two shorts and 15 open connections, and C is largely unrouted.

Ranking: **A > B > D > C**

| Board | EMI | SI | Power | Placement | Routing / mfg | Overall |
|---|---|---|---|---|---|---|
| A | 8 | 9 | 9 | 8 | 8 | **8** |
| B | 4 | 5 | 4 | 6 | 3 | **4** |
| D | 6 | 5 | 3 | 7 | 2 | **3** |
| C | 3 | 2 | 1 | 3 | 1 | **1** |

## How this was checked

- KiCad 10.0.8 DRC was run on a copy of each board, once as saved and once with zones refilled; pcbnew/shapely scripts measured the rest (scripts and renders are in `/work/scratch`). The boards in `/work/boards` were not modified.
- No board came with a `NOTES.md`, so the designers' own list of known problems could not be read.
- All four boards have the same netlist and footprint pad geometry, and the locked connectors, mounting holes and fiducials sit at identical positions in all four.
- Coordinates are KiCad mm. "Over void" means the adjacent plane layer (In1 for F.Cu, In2 for B.Cu) has no copper under the track.
- JLCPCB limits used (from their capabilities page): copper to routed edge ≥ 0.2 mm, via hole-to-hole ≥ 0.2 mm, blind/buried vias only through the HDI service, silkscreen text ≥ 1.0 mm high.

Issues common to all four boards, inherited from the starting project and not scored against any one of them:

- 11 courtyard overlaps between locked parts (FID/MK/J2/J3/J5/J6/J8).
- 32 silkscreen texts 0.6 mm high.
- All reference designators hidden.
- 4 footprint-type mismatches (U1, J1, U8, U36).

## Headline measurements

| | A | B | C | D |
|---|---|---|---|---|
| Unconnected items (KiCad) | 0 | 0 | 321 (138 nets) | 15 (11 nets) |
| Shorts / clearance errors | 0 | 0 | 0 | 2 shorts, 2 clearance, 1 hole clearance |
| Vias | 416 through | 666 through, 113 micro, 44 buried | 434 through | 476 through |
| Parts front / back | 178 / 94 | 118 / 154 | 65 / 207 | 160 / 112 |
| In1 GND plane pieces | 1 | 13 | 1 | 1 |
| In1 GND coverage under U30 (±2 mm) | 86% | 34% | 89% | 84% |
| Signal track on In1 / In2 | 0 / 30 mm | 397 / 900 mm | 0 / 0 | 0 / 260 mm |
| F.Cu signal length over void | 7% | 24% | 9% | 8% |
| B.Cu signal length over void | 14% | 36% | 10% | 24% |
| USB P / N length (skew) | 14.1 / 13.0 (1.1) | 16.2 / 15.2 (1.0) | 16.6 / 21.8 (5.1) | 16.6 / 16.2 (0.4) |
| LVDS worst intra-pair skew | 0.65 mm | 0.00 mm | 32.5 mm | 0.97 mm |
| LVDS pair lengths, min–max | 28.5–29.6 mm | 16.1–31.5 mm | 0–65.9 mm | 16.9–34.8 mm |
| xVBUS track width | 0.45 mm | 0.15 mm | 0.25 mm | 0.40 mm |
| +5V main width | 0.75 mm | 0.25 mm | no copper | 0.8 / 0.5 mm + In2 zone |
| Power pin to nearest cap, median | 0.5 mm | 0.8 mm | 1.5 mm | 1.5 mm |
| Power pins > 3 mm from a cap | 8 | 22 | 28 | 11 |
| Plane copper to board edge | 0.05 mm | 0.25 mm | 0.05 mm | 0.05 mm |

---

## Board A — overall 8

Complete, correct and conventional. It needs a few CAM-level fixes before ordering, none of them electrical.

### EMI — 8
- In1 is one solid GND piece of 3433 mm² with no tracks in it; 93% of F.Cu signal length runs over it.
- In2 is a +3V3 plane with a +1V2 island under U30. It also carries 260 mm of track, mostly power: +5V 102 mm at 0.75 mm, VIOA/VIOB 34 mm each, +1V2 41 mm, and CLKREF 17 mm.
- The +5V trunk on In2 runs along the bottom edge at y = 118.4, 1.2 mm from the edge, and cuts the +3V3 plane off from that edge strip.
- B.Cu signals reference +3V3 for 86% of their length; the return has to transfer through decoupling capacitors, which are plentiful.
- The USB shield has its own /SHLD island on all four layers under J1, tied to GND through R3/C13. The USB pair crosses the SHLD/GND moat on In1 for about 1.1–1.7 mm near x = 57–58.
- No signal track is within 1 mm of the board edge.
- Only 3 of the 121 GND vias are within 3 mm of the edge, and both planes run to 0.05 mm from the outline.

### Signal integrity — 9
- USB: 0.19 mm tracks at 0.15 mm gap, coupled over most of the run, on F.Cu over GND. Each line has two vias, both for the back-side test points TP15/TP16 (about 1 mm stubs). The pair passes U15 pins 5/6 in line, without a stub.
- Crystal: XTALIN 8.3 mm and XTALOUT 6.4 mm, F.Cu only, no vias, 100% GND beneath; load caps are 1.5 mm from Y1. /ENVB and /~{CY_RESET} cross under Y1 on B.Cu, two planes away.
- LVDS: all 13 pairs are length-matched to 28.5–29.6 mm with serpentines; intra-pair skew is ≤ 0.05 mm except Z0 at 0.65 mm. Coupling is 85–95%.
- FX2–FPGA FIFO: 7–21 mm, at most 2 vias per net; CLKIF is 25 mm with 2 vias, over GND and +3V3.
- The stackup in the file is still the KiCad default (3 × 0.48 mm). The 0.19/0.15 USB geometry only makes sense on a thin-prepreg stackup (about 0.1 mm), so that choice has to be made on the order form; it is not recorded in the board.

### Power — 9
- Input path: xVBUS at 0.45 mm, then FB1, U15, and a wide +5V track to C87 (150 µF).
- U8 and U36 have small copper pours on input and output, 4.7 µF caps 1.4–2.0 mm from the pins, and 4-via arrays into the In2 +5V trunk.
- VIOA/VIOB are distributed on 0.45–0.75 mm trunks with local pours; the shunt nodes (R6/R56) are poured on both sides, with separate ISNS_H pours for the sense connection.
- Decoupling: every U1 supply pin has a 0.1 µF cap 0.1–0.4 mm away on the back; each level shifter has both caps 0.2 mm away; U30 caps are 0.5–1.3 mm from their balls (H6 is 2.4 mm).
- Weak spot: U15 pin 4 (+5V out) is 6.2 mm from C87, its nearest +5V cap.

### Placement — 8
- All ICs are on the front; back-side parts are mostly decoupling directly under the pins they serve.
- ESD arrays D20–D23 sit between the IDC headers and the series resistor networks; LEDs are in a column at the left edge; regulators are grouped at the lower left near the 5 V entry.
- Dense: 57 courtyard overlaps beyond the inherited 11. About half involve the DNP sockets J6–J9; the rest are real, tight 0402/SOT spacings (C12/Y1, C16/U7, D18/U14, D19/U31, R39/R43, R48/R7 and others).
- The smallest gap between pads of different parts and nets is 0.16 mm (C77.2 to C21.1, back side under U30).
- 94 parts on the back means two-sided assembly.

### Routing and manufacturability — 8
- 0 unconnected, 0 clearance errors. 416 through vias: 364 at 0.6/0.3, 46 at 0.4/0.2, 6 at 0.5/0.3.
- Before ordering:
  - In1 and In2 plane copper is 0.05 mm from the outline; JLCPCB wants ≥ 0.2 mm. The +3V3 and GND planes are both at the routed edge.
  - 16 same-net via pairs have a 0.20 mm hole-to-hole web; two have 0.15 mm (VIOB at 97.05/97.5,106.95 and 107.3/107.75,105.4), below the JLCPCB 0.2 mm limit.
  - One dangling via in the DNP R40 pad at (70.61,113.31).
- 26 silkscreen items are clipped by pads (the A0…B7 labels against the level-shifter pads).
- The serpentines are drawn as many tiny segments (2055 segments under 0.15 mm); harmless, but there are 24 acute or doubled-back corners.

---

## Board B — overall 4

Electrically complete and DRC-clean under its own rules, but those rules allow microvias and buried vias. It cannot be ordered as a standard 4-layer board, and its two "plane" layers are used as routing layers under the FPGA.

### EMI — 4
- In1 (GND) carries 438 mm of track, 397 mm of it signal, from 51 nets. The plane is in 13 pieces and covers only 34% of the area under U30 (±2 mm); one connected void spans roughly (64.5,84.7)–(103.3,107.5).
- In2 carries 1109 mm of track from 96 nets. The +3V3 plane is in 14 pieces and covers 14% under U30.
- 24% of F.Cu signal length and 36% of B.Cu signal length has no copper on the adjacent plane layer.
- CLKIF (48 MHz) runs 24 mm inside In1 and CLKREF 24 mm inside In2.
- Mitigations that are real: GND pours on F.Cu (2293 mm²) and B.Cu (2573 mm²), 201 GND vias with 32 of them along the edge, a GND island on In2 under the LVDS area, all pours pulled back 0.25 mm from the edge, and a declared thin-prepreg stackup (0.135 mm).
- The shield pins of J1 are joined by a 0.15 mm track, partly on In2 (21.8 mm).

### Signal integrity — 5
- USB: 0.19/0.15, 16.2/15.2 mm, mostly on F.Cu over GND. U15 is on the back, so each line drops through a via to it; N has 4.2 mm on B.Cu.
- Crystal: XTALOUT is 11.6 mm with 2 vias and 8.5 mm of it on B.Cu; LED_ERR runs under the crystal body on F.Cu for 2.8 mm.
- FIFO bus: 42% of its length is in the plane layers and 21% is on F.Cu over void. D0 has 7 vias, D7 has 6, RD and WR have 5 each.
- LVDS: every pair is tuned to 0.00 mm skew, which is good. Coupling is 62–89% and pair lengths range from 16.1 to 31.5 mm (no pair-to-pair matching).
- I2C: SDA has 20 vias and SCL 18.

### Power — 4
- xVBUS, the board's supply input, is a 0.15 mm track for 10.1 mm, with 2 vias and 3.7 mm of it on In2.
- All +5V distribution is 0.25 mm track (132 mm) with no pour, including the feed to the 3.3 V LDO U8.
- The LDO output nodes Net-(R6-Pad1) and Net-(R56-Pad1) are 0.15 mm.
- Capacitor distances at the regulators: U36 (+1V2) output cap C27 is 7.1–7.6 mm away; U31 pin 1 (+5V in) is 7.6 mm from its nearest +5V cap.
- Other long decoupling paths: U19.1 11.1 mm, U5.1 8.1 mm; 22 supply pins are more than 3 mm from a cap.
- Good: U1 caps 0.5–0.8 mm on six pins, level shifters 0.4–0.5 mm, U30 core caps 0.4–0.5 mm.
- The +3V3 plane is too fragmented near U30 to act as a plane there.

### Placement — 6
- Grouping matches the circuit: FX2 and crystal by the USB connector, level shifters in their silkscreen grid, regulators at lower left, VIO regulators at the right.
- No courtyard overlaps beyond the inherited 11, and only 4 silkscreen-over-pad items; the cleanest board in that respect.
- 154 parts are on the back, including U15 and five resistor networks, so the back side is a full assembly pass.
- Several bulk and decoupling caps ended up far from the regulator they serve (see Power).

### Routing and manufacturability — 3
- 0 unconnected and 0 clearance errors, with the saved zone fills current.
- Via technology:
  - 113 microvias (F.Cu–In1 and In2–B.Cu, 0.3/0.15 and 0.35/0.15).
  - 44 buried vias (In1–In2, 0.4/0.2).
  - 7 places where a microvia is stacked on a buried via, for example (84.5,97.5).
  - The project file has blind/buried and microvias enabled.
  - This is an HDI build with a drilled and plated inner core plus laser drilling on both sides. JLCPCB only does that through its HDI service, not as a standard 4-layer order.
- 14 microvias and 4 through vias sit in U30 BGA pads, and 19 through vias sit in small SMD pads (U5.14, U5.15, U1.29, RN1.5, C24.1 and others). The through ones need filling and capping or they will wick solder.
- 823 vias in total; 626 mm of track at 0.127 mm.
- 16 acute corners.

---

## Board D — overall 3

The architecture is sound and close to A's, but the file is not finished: it contains two shorts and 15 open connections, so boards built from it would not work.

### EMI — 6
- In1 is one solid GND piece (3459 mm²) with no tracks; 92% of F.Cu signal length is over it.
- In2 is split into +3V3 (1560 mm²), VIOA (281), VIOB (235), +5V (187) and GND (484, under the LVDS area), and carries 285 mm of track (260 mm signal).
- B.Cu signals cross those splits: 24% of B.Cu signal length is over void. The IO-port Z nets run 17% over VIOA, 15% over VIOB and 16% over void.
- No signal track is within 1 mm of the edge; planes are 0.05 mm from the outline, as in A.

### Signal integrity — 5
- USB: 0.19/0.15, 16.6/16.2 mm, skew 0.44 mm; each line has about 4.5 mm on B.Cu and 2 vias.
- Crystal: 6.9/6.7 mm on F.Cu, no vias, over GND.
- CLKIF: 21 mm, 14.5 mm of it on In2.
- LVDS: coupling 83–94%, but 8 of 13 pairs have an untuned 0.97 mm skew and pair lengths range from 16.9 to 34.8 mm.
- Open signals: DA0, DA1 and DA2 never reach U30 (stubs end on In2 near (89,87–90)), and SCL is broken between (86.6,97.4) and (88.9,99.9).

### Power — 3
- **Short, +1V2 to GND:** the B.Cu +1V2 track from (77.15,104.75) to (78.64,104.75) runs through C14 pad 2 (GND) on its way to pad 1.
- VCCPLL1 and GNDPLL1 have no copper at all (U30 C6/C5, C79, C80, R32), and +1V2 does not reach R32. PLL1 is unpowered.
- +1V2 runs 26.9 mm at 0.127 mm.
- What is good: xVBUS at 0.4 mm, +5V at 0.8/0.5 mm plus an In2 zone, VIOA/VIOB on In2 zones, 4.7 µF caps 1.4–2.0 mm from U8/U36.
- Decoupling is adequate: U1 0.7–0.8 mm, level shifters 0.4 mm on +3V3 and 1.5 mm on VIO (caps shared between pairs), U30 mostly 0.2–1.5 mm. VIO_AUX is the exception at 4.1–5.5 mm.

### Placement — 7
- Essentially the same floorplan as A: ICs on the front, decoupling on the back, ESD arrays at the headers, LEDs on the left edge.
- 13 courtyard overlaps beyond the inherited ones (C77/C14 and others) and 42 silkscreen-over-pad items.

### Routing and manufacturability — 2
- 15 unconnected items on 11 nets. Besides those above: /~{CY_RESET} is split, so U1 pin 42 only sees C88 and the FX2 reset is not driven; Net-(R10-Pad1), Net-(D13-Pad1) and Net-(R45-Pad1) are open.
- **Second short:** a +3V3 via at (89.61,106.9) overlaps R45 pad 1 (hole clearance 0.08 mm), tying U32 pin 3 to +3V3.
- 13 dangling track ends, 1 dangling via (/FLAGD at 75.2,93.25), and a DB0 stub on In2 that changes layer with no via at (93.45,98.35).
- The saved zone fill is out of date (14.7 mm² differs after refill, mostly near (88.5,96.5) on In2).
- Via technology is standard: 476 through vias, mostly 0.45/0.2. 40 acute corners.

---

## Board C — overall 1

Not a routed board: 321 connections on 138 nets are missing, including every supply rail except parts of +3V3 and GND.

### EMI — 3
- In1 GND and In2 +3V3 are each one piece, but only because almost nothing was routed.
- Two signal nets run within 1 mm of the board edge: ISNS_H (buffer B) for 15.5 mm and Z3_N for 14.3 mm.
- Planes are 0.05 mm from the outline.

### Signal integrity — 2
- USB: P 16.6 mm, N 21.8 mm (5.1 mm skew), widths mixed 0.2/0.3 mm against a 0.45 mm net class, only 2.6 mm coupled, 4 vias on N, about half the length on B.Cu.
- XTALIN, XTALOUT, CLKIF and CLKREF have no copper; the crystal sits 6.6/8.5 mm from its pins.
- LVDS: several pairs are unrouted or partial; skew reaches 32.5 mm (Z9) and most pairs are under 20% coupled.
- Only 8 of the 19 FIFO nets are routed.

### Power — 1
- +5V, VIOA, VIOB, VIO_AUX and the PLL supplies have no copper at all; +1V2 has 2.3 mm.
- U30's decoupling and PLL filter caps are lined up at y = 84–90, 6–17 mm from the balls they serve.

### Placement — 3
- LEDs D1–D10, D14 and D15 are on the back, inside the J5 expansion-header area (y = 72–78).
- 207 parts are on the back, including 15 ICs (the port-B level shifters, U12–U14, U2, U3).
- The level shifters ignore the existing silkscreen grid, giving 199 silkscreen-over-pad items; labels such as A0…B7 no longer sit next to the right parts.
- Six different-net pad pairs are under 0.2 mm apart, for example J3.7 to D20.1 at 0.157 mm.

### Routing and manufacturability — 1
- 321 unconnected items, 33 dangling tracks, 5 dangling vias. Nothing to order.

---

## Ranking

1. **A** — the only board that can be sent to a standard 4-layer fab and expected to work. Solid ground plane, matched LVDS, clean USB and crystal, wide power distribution, tight decoupling. Fix the plane pull-back and the close via pairs first.
2. **B** — complete and self-consistent, and would work if built by an HDI fab, but it depends on 157 microvias and buried vias, shreds both planes under the FPGA, and has a 0.15 mm supply input track. Converting it to through vias means re-routing the FPGA area.
3. **D** — better architecture than B (solid GND plane, through vias only, sensible power widths), but as saved it has a dead short on +1V2, a second short on the SYNC buffer, and 15 open connections including the FX2 reset. It is closer to a good standard board than B is, but it cannot be ordered today, which is why it ranks below B.
4. **C** — placement only partly thought through and routing barely started.

## Which board is the human's

**A, about 93% confident.** This guess was made after scoring and did not change the scores.

- A's lock state differs from the other three. B, C and D all have the same 29 locked footprints; A has 25, with C1, C15, C17, U2 and U3 locked and J6–J10 and the panel tab unlocked. That looks like a pre-existing design the task was derived from, not a result produced from the task's starting file.
- A contains hand-built structures none of the others attempt: an isolated /SHLD island and a /SWSH island on all four layers, separate ISNS_H sense pours at the shunts, per-regulator input/output pours with via arrays.
- All 13 LVDS pairs are matched to each other within 1.1 mm using smooth serpentines drawn from thousands of tiny segments, and vias are a conservative 0.6/0.3.
- Its flaws are the kind a person leaves: courtyard overlaps from packing parts tightly, a few via pairs too close together, a stray via in a DNP pad.
- The others read as agent output. B fits rules to the tool (a `.kicad_dru` with named rules, microvias enabled to make the BGA escape work). C and D stop partway, with dangling stubs, open nets and, in D, a track drawn through a pad.
