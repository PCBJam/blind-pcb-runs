# OrangeCrab (Feather, 6 layers) – placement and routing notes

## Status in one paragraph

**The board is not ready to order.** All parts are placed, the DDR3 interface, flash, USB, SD,
JTAG, header IO, LEDs, the three bucks and most of the power distribution are routed, and
every piece of copper I wrote was clearance-checked before it went in. But KiCad's DRC still
reports **27 unconnected items** (the 2V5 rail is the important one), 4 real errors, and
several nets are routed in ways I would not sign off (signal tracks in a ground plane, thin
links through the core plane, DDR not length-matched). The list is in "Not finished / not
good" below; please read that section before anything else.

Locked footprints were not touched (`bt same` against the original: nothing locked moved, no
parts added or removed, pad nets unchanged). The `.kicad_pro` differs from the original only
in net-class values (below).

## Layer stack use

| Layer | Use |
|-------|-----|
| F.Cu  | parts, BGA escapes, the DDR nets that need no via, short local routes |
| In1.Cu | solid GND plane (reference for F.Cu and In2) – no tracks |
| In2.Cu | signal: DDR address/control/data lanes, clock pair, SD, header IO bus, USB |
| In3.Cu | GND plane. **Six slow ADC nets run in it in the north-west quadrant** (see below) |
| In4.Cu | power islands: 1V1 under the FPGA, 3V3 north/west/south-west, 1V35 on the right end, a column east of the FPGA and the south edge, RAM_VDD / RAM_VDDQ under the RAM; plus LED lines and a few slow nets inside the 3V3 island |
| B.Cu  | parts (decoupling, bucks, flash, LDO), the DDR nets whose pin order forces a crossing, header IO on the east |

Why this order: In2 carries most of the DDR bus, so it sits between two ground planes whatever
prepreg/core thicknesses the fab uses. The price is that B.Cu is referenced to the power layer;
the DDR nets on B.Cu run under the RAM_VDD / RAM_VDDQ islands only. A stack with thin
dielectric F.Cu–In1 and In2–In3 (e.g. a JLC-style 6-layer with 0.1 mm prepregs outside and
between In2/In3 a core) is what the 0.09–0.1 mm tracks assume; I did not compute impedances.

Vias: 0.28/0.15 mm inside the FPGA ball field, 0.3/0.15 around both BGAs and for plane stubs,
0.45/0.2 elsewhere. That needs a fab with 0.15 mm drills and 0.065 mm annular ring (the
board's own minimums). Tracks are 0.09 mm in the FPGA field, 0.1 mm for DDR outside it.

## Placement

* The ECP5 ball map decides the floorplan: at -90° all DDR balls face the RAM on the east,
  JTAG faces J6 on the west, SPI/config and the J2-side header IO face south. FPGA at
  y = 102.30 and RAM at y = 103.75 so that the FPGA's row A/B escape lanes meet the RAM's
  row gaps almost straight on.
* Bottom: 3V3 buck north of the ball field, 1V1 buck west of it (the west three ball rows are
  ground, so the core plane is fed without crossing another rail), 1V35 buck with the RAM
  ferrites on the right end, flash south-west under the configuration pins, 0201 decoupling
  inside both BGA shadows between the vias.
* Top left: charger next to the battery connector, analog mux with its RC parts, SD pull-ups.
  Oscillator and RGB LED north-east of the FPGA, button on the right end.
* **A placement mistake I only understood late:** with this rotation the SD, ADC/mux and
  A0..A5 balls are on the FPGA's *north* edge while their parts are west and south-west. About
  20 nets have to turn round the north-west corner of the ball field, exactly where the 1V1
  buck's vias and the 5-pin JTAG header (through-hole, 12 lanes between its pins per layer)
  stand. Everything that is ugly below comes from that. Putting the mux and its RC parts
  north of the FPGA (and the 2V5 LDO next to the FPGA instead of the south-east strip, where
  the DDR bus cuts it off on every signal layer) would have avoided most of it.
* Late moves to make routing possible: R31 (flash clock pull-up) next to the clock track,
  TP19/TP20 right below the FPGA south vias, R6 next to R49, R27 next to J6 pin 4,
  TP30/TP31/TP32 (TP31 to the right end on the 1V35 island).

## Routing approach

* Both BGA breakouts, the DDR bus, the flash fan-out, the south header bus and the JTAG fan
  were generated as explicit coordinates and checked item by item (`bt probe`) before writing.
  The rest was done net by net with `bt route` after I had opened the escapes by hand.
* DDR3: address/control and the lower data byte mostly on In2 in two 0.1 mm lanes per RAM row
  gap; nets that need no via stay on top; nets whose FPGA/RAM pin order crosses go to the
  bottom (A3, RAS#, LDM, UDM, D8, D10, D11, D12, D15). CK± on In2 with the 100 Ω termination
  at the RAM. RAM_RESET# takes the long way (38 mm) along the south edge on In2.
* Net-class edits: `RAM_LDQS±` moved to the class of D8..D15 and `RAM_UDQS±` to that of
  D0..D7 – in the schematic the two strobe names are swapped relative to the RAM balls they
  go to (B7/C7 is the upper-byte strobe, F3/G3 the lower-byte one). Netlist untouched. DDR
  classes set to 0.1 mm / 0.3-0.15 vias, default via 0.45/0.2.
* South side: 15 FPGA stubs end in two staggered via rows in the 0.65 mm strip between the
  last ball row and the flash's exposed pad; SCK and MOSI stay on top (one via at the flash),
  seven nets run as an In2 bus under the flash to J2 / the RAM / the button. Lane order was
  made to match the J2 pin order so nothing hops.
* North side: five lanes through the ground-via lattice under the FPGA (3 tracks fit between
  two via columns); LEDs on In4 inside the 3V3 island (their own supply) and through the gap
  between the oscillator's pad rows.

## Not finished / not good

### Not connected (KiCad DRC: 27 unconnected items)

* **P2.5V (VCCAUX): not distributed.** The LDO (bottom, south-east strip) reaches only its own
  capacitor and TP30. The four FPGA 2V5 balls with their decouplers and mux pin U9.18 are
  not fed (7 pieces). The DDR bus blocks every signal layer between the LDO and the FPGA;
  the LDO has to move next to the FPGA (or the rail needs an In4 island). Without it the
  FPGA does not work.
* **P1.35V:** FPGA balls G5/H5 (with C64) and the group G14, H14, K15, K16, K17, M14, N14
  (with C66/C68) are not tied to the 1V35 island; mux sense pin U9.19 open.
* **ECP5_VREF:** a 1.25 mm gap between the FPGA-side and the RAM-side piece near
  (166.8, 100.7).
* **VSYS:** D2 pin 1 is not connected to the charger output (3.9 mm missing).
* **P1.1V:** mux sense pin U9.17 and TP32 open (the core rail itself is complete).
* **GND:** the charger's thermal pad (touches bottom ground copper but has no via), the mux's
  exposed pad, FPGA balls E12, L16, L17 and U14 (U14 lost its link when JTAG TCK was
  re-fanned), the second GND pad of SW1, J5's mounting pads and some SD-socket shield pads.

### DRC errors that are mine

* 2 × starved thermal on J2 pin 4 (GND) on In1/In3.
* 1 × "shorting items": the GND via of R35 sits in the copper of the open-hardware logo
  (a no-net graphic) – electrically harmless, but it should move.
* 55 silkscreen-over-pad warnings and 8 silk overlaps: I did not clean the silkscreen.
* Dangling: a handful of stub tracks/vias (e.g. vias at (176.0,109.35), (169.3,100.15)).
  (84 edge-clearance errors and one malformed courtyard come from the locked connectors and
  were there before.)

### Connected, but not the way it should be

* **Tracks in the In3 ground plane:** ADC_CTRL0, ADC_CTRL1, ADC_SENSE_LO, ADC_SENSE_HI,
  ADC_MUX2, ADC_MUX3 each run 13–16 mm in In3 in the north-west quadrant (not under the DDR
  bus or the RAM). They are slow, but they slot the plane under SD and analog-header tracks.
  This was a last resort after the lanes round the north-west corner were full.
* **Thin links through the core plane:** `bt islands --fix` joined the 3V3 balls in the
  middle of the FPGA (D7, D12, N13, P14, T14) with 0.089 mm In4 tracks, one of them a 4 mm
  slot across the 1V1 island at y = 103.4. These balls deserve a proper feed.
* Slow nets on In4 inside the 3V3 island: SD0_CD (15 mm), SD0_DAT2 (6 mm), IO_A2, IO_A4,
  ADC_CTRL1, /IO/A4 and /IO/A5 (along the island's south edge), LED_R/G/B.
* **DDR3 is not length-matched.** Lengths (mm): lower byte D0 14.4, D1 9.1, D2 12.0, D3 7.7,
  D4 10.9, D5 7.0, D6 11.9, D7 7.9, LDM 13.7, strobe 11.6/10.6; upper byte D8 11.5, D9 16.3,
  D10 12.6, D11 17.2, D12 15.5, D13 13.8, D14 15.0, D15 15.5, UDM 15.2, strobe 14.2/15.5;
  address/control 6.5–14.5; CK 17.2/18.4. The strobe pairs and CK are 1.0–1.3 mm skewed
  inside the pair; CK± is not coupled for its last ~3 mm. Tuning was planned and not done.
* SD lines are 20–34 mm with 2–4 vias each; the mux and analog-header nets 19–53 mm
  (ADC_MUX2 is the worst, 27 mm of it on the bottom).
* The comparator pair ADC_SENSE_HI/LO is not routed as a pair.
* LED_R and LED_B pass on top between the oscillator's pad rows; I removed a redundant 3V3
  link between its pads and one 3V3 stitching via near the 3V3 buck output for that – the
  buck output should get a second via to the plane again.
* The shield pad J4.MP is tied to ground by a 15 mm track.
* No impedance calculation, no simulation, no check of the fab's real stack-up.

## Files

* `progress/` – numbered pictures and notes, including the attempts that were thrown away.
* `BT-REVIEW.md` – notes on the `bt` tool.
