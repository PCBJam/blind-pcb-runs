# OrangeCrab – placement and routing notes

## Status in one paragraph

**The board is not finished and must not be ordered as it is.** All 163 footprints are
placed (locked ones untouched, verified by UUID), the DDR3 interface is completely routed,
about 95 % of the other signal connections and most of the power distribution are in, and
KiCad DRC shows no clearance, short, hole or courtyard errors beyond the 86 the empty board
already had. But **69 connections in 26 nets are still open** (list in `UNROUTED.txt`,
summary below), among them things the board cannot work without: the 2.5 V / 3.3 V / 1.35 V
ring balls of the FPGA, the USB data lines between connector and series resistors, flash
MISO, one DDR3 VDD ball. I ran out of working budget in the dense areas around the FPGA;
what is missing is listed honestly at the end.

The schematic files mentioned in the task were not in /work; I worked from the netlist in
the board file (and the BQ24232 / TLV62569 / DDR3 / ECP5 pinouts I know).

## Floorplan and why

* **FPGA U3** at 162.25/103.0, rot -90: rows A–D (DDR address + data banks) face the
  DDR3, SD/USB/ADC balls face the top-left, QSPI faces the flash, JTAG faces the header.
* **DDR3 U4** at 174.4/103.0, rot 180: address rows J–T opposite the FPGA address balls,
  data rows opposite the data balls. 2.5 mm between the packages – enough for the escape
  vias of the outer FPGA rows, short enough for 7–18 mm nets.
* **USB / battery / charger** top-left: BQ24232 (U5) directly below the JST, its
  programming resistors and the three bulk caps around it; CC resistors at the connector.
* **3.3 V buck (U7)** top-left below the charger, output next to the 3V3 header pin.
  Input cap directly on VIN/GND, inductor on the SW pin, output caps at the inductor.
* **1.1 V buck (U1)** on the bottom under the JST connector. It was first on the bottom
  above the FPGA; that position blocked the only place where the top FPGA block can get
  through vias, so it moved (progress 007/008).
* **1.35 V buck (U2)**, DDR ferrites FB2/FB3 and DDR bulk caps on the bottom at the right
  end, next to the DDR. Kept clear of the copper date text on B.Cu.
* **Flash U6** on the bottom under the QSPI balls; **mux U9** on the bottom left of the
  FPGA; **2.5 V LDO U10** on the bottom below the FPGA.
* **Button SW1** at the right end so that the copper OSHW logo sits between its pads and
  the silk "btn0" is below it; RGB LED D1 with its resistors next to it; charge LED D2 next
  to the "CHG" silk text.
* **Oscillator** on the top at the upper end of the FPGA–DDR gap, 8 mm from ball A9.
* **Bottom under the DDR is free of parts** to keep the silkscreen crab logo intact; DDR
  decoupling sits at the east edge, in the blank corner of the logo box and just outside it.
  This is a compromise: the caps are 2–3 mm from the balls instead of directly under them.
* **SD pull-ups** on the bottom below the card socket, next to the 3V3 pin.
* FPGA decoupling: 0201 caps on the bottom in the 0.5 mm strips between the centre GND via
  rows (two caps share one rail via), the rest around the ring.

## Layer stack use

| layer | use |
|---|---|
| F.Cu | parts, BGA outer-row escapes, DDR clock, 4 DDR data nets, IO "highway", GND pour |
| In1.Cu | solid GND |
| In2.Cu | signals (main DDR layer), small 3.3 V island under the FPGA core |
| In3.Cu | power: 3.3 V (background), 1.1 V (core + feed from U1), 1.35 V, RAM_VDD, RAM_VDDQ |
| In4.Cu | solid GND |
| B.Cu | parts, signals (second DDR layer), GND pour |

Every signal layer has a GND plane next to it. **Deviation:** In3 also carries signals – 11
short DDR links in the FPGA–DDR gap (A4, A8, A14, A15, BA1, D1, D10, D14, LDM, part of CKE)
and a handful of slow nets near the FPGA top-left. They had no planar slot left on
In2/B.Cu. They reference In4 and the power pours flow around them, but they cut the In3
planes in the gap (see "not good").

## Rules

Net classes: via changed to 0.28/0.15 mm for all classes (the 0.5 mm BGA cannot take
anything larger; min annular 0.065 is kept). Track 0.09 mm inside the BGAs, clearance
0.0889 unchanged. Everything else in the project file is as delivered.

## DDR3 routing

* Clock: F.Cu only, no vias, coupled pair (0.09/0.11) from J18/K18 along the bottom of the
  FPGA, up the centre channel of the DDR to J7/K7 and on to 2×51 Ω + 100 nF above the DDR,
  i.e. the terminator is at the far end of the line (fly-by), not on a stub. The mid node
  crosses on In2. After the balls the pair runs 0.9 mm apart for 5 mm.
* All other nets: one via at the FPGA, one at the DDR (dog-bone into the centre channel or
  an interstitial site), link on In2 / B.Cu / In3; D3, D5, D7, D8 are F.Cu only.
* Every escape via position was chosen by hand (site table per ball: interstitial sites,
  depopulated-ball sites of the csBGA285, vias in the gap for rows A/B) so that no via sits
  in another ball's escape lane.
* Lengths (mm / vias / layers) – `tools/ddr_lengths.txt`:
  * address/control 6.6 … 18.0 (WE# 18.0, A5 17.2, ODT 16.6 are the long ones)
  * byte lane on DDR rows A–D (D8–15, "LDQS", "UDM"): 9.4 … 16.6
  * byte lane on DDR rows E–H (D0–7, "UDQS", "LDM"): 7.2 … 12.4
  * clock 28.4 / 30.6
  **No length tuning was done.** In-lane spread is up to 7 mm (~45 ps) and the clock is
  ~17 mm longer than the strobes. That is inside what DDR3 at the 300–400 MHz an ECP5 can
  do tolerates with write levelling, but it is not what I would release; meanders on the
  short data nets and a 2 mm fix of the CK+/CK- mismatch are still to do.
* The schematic names of the strobes/masks are swapped against the physical byte lanes
  (LDQS/UDM sit with D8–15); I grouped by the physical lanes.
* The two strobe pairs each end up with P and N on the same layers except UDQS (both In2).

## Other routing

* The eight balls in the middle of the DDR side (IO_5…IO_11, SCL, SDA, REF_CLK) cannot
  leave on inner layers (address bundle north, data bundle south), so they run north on
  F.Cu through the gap as a hand-drawn 7-track group; IO_9 and SDA change to In2 at the top.
* Top and bottom-left FPGA blocks: hand-placed stubs/vias, then `bt route` in a chosen
  order. These routes are legal but not pretty (router-made, several are longer than needed).
* Switch nodes of the three bucks are short 0.4 mm tracks on the component layer.
* GND: 16 vias in the FPGA centre (one per four balls), one via per GND pad elsewhere
  (`bt escape`), solid planes In1/In4, pours on F/B.

## Not finished / not good

Open connections (full list with coordinates in `UNROUTED.txt`):

* **FPGA supply ring** – P2.5V (10 links: none of the four VCCAUX balls E6/E13/N6/P13 is
  connected to U10 yet), P3.3V (D7, D12 ring vias, R31, R39, R40, C67/C69), P1.35V (C6,
  K15, M14, D17, B18 ball vias and C66 – i.e. the address-bank VCCIO is not fed), P1.1V
  (three stubs: U9 pin 17, TP32, one ball pair). The via walls around the FPGA core leave
  no room for the router; this needs B.Cu links drawn by hand between the decoupling caps.
* **USB** – `/IO/_USB_D_P` and `/IO/_USB_D_N` between the connector pads (incl. joining
  A6/B6 and A7/B7), TP26/TP27 and R21/R29. FPGA side of the resistors is routed.
* **Flash** – SPI_CONFIG_MISO (T18 → U6 pin 2).
* **DDR** – RAM_VDD ball D9 (no layer has a free path to the VDD plane, see below), C30/C34,
  one RAM_VDDQ ball link, ZQ resistor R19, RAM_RESET#, 7 ECP5_VREF links (B4 and most VREF caps).
* **Analog / misc** – /IO/A1, /IO/A2, /IO/A4, /IO/A5 to the mux U9, VBATT divider R32/R33,
  IO_0, IO_1, JTAG_TDO, EXT_PLL± to their test points, one LED resistor (R23–D1), one EN stub.
* 8 "zone" items: small GND pour islands on F/B that are not stitched yet; U9 pin 12 on B.Cu.

Known weaknesses in what is routed:

* **VSYS to the 1.35 V buck is a 0.2 mm, 39 mm long track** (In3 + In2). ~0.1–0.2 Ω; it
  will work at the expected 0.15 A but it should be a 0.5 mm+ trunk. The In3 band along
  the bottom edge that I had planned for it was taken by router-placed IO tracks.
* **In3 is cut by signal tracks in the FPGA–DDR gap**, so the 1.35 V pour there is in
  pieces and the VCCIO ball C6 / G5 / H5 side has no plane feed at all yet.
* RAM_VDD/RAM_VDDQ share In3 under the DDR (north/south split); D9 (VDD) lies in the VDDQ
  half behind signal tracks on every layer.
* DDR decoupling is at the package edge, not under the balls (logo). 
* Tracks are 0.09 mm almost everywhere, also outside the BGAs, because the router cannot
  change width along a route. Power stubs are 0.12–0.25 mm.
* Router-made routes around the FPGA top-left, the flash and the mux wander; a few slow
  nets have 3 vias. 26 dangling vias / 14 dangling track ends from the hand escapes whose
  nets were re-routed differently are still on the board (DRC warnings).
* No teardrops, no silkscreen clean-up (49 silk-over-pad warnings, 3 silk overlaps), no
  stitching vias along the board edge, no thermal vias under U5 beyond the pad's own.
* DRC "errors" that remain are the ones of the delivered board: 84 edge-clearance errors of
  the castellated header pads, J5 courtyard, H4/FID6 courtyard overlap.

## Files

* `OrangeCrab.kicad_pcb` – result, zones filled. `OrangeCrab.kicad_pro` – only the via
  size of the net classes changed. `orig/` – untouched copies of the delivered files.
* `UNROUTED.txt` – every open connection as reported by KiCad DRC.
* `progress/` – numbered pictures and notes, including the attempts that were thrown away.
* `tools/` – the scripts I wrote (placement checker `fit.py`, DDR lane router `bus2.py`,
  zone builder `zones.py`, rip-up `rip.py`, …) and `tools/stages/` with intermediate boards.
* `BT-REVIEW.md` – review of the `bt` tool.
