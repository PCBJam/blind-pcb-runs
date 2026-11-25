# Glasgow revC3 – placement and routing notes

(Status section at the end says what is finished and what is not.)

## What the board is

USB-C → FX2 (CY7C68013A, USB 2.0 HS) → iCE40HX8K (BGA-121, 0.8 mm) → two 8-bit level-shifted I/O
ports (A on J2, B on J3) with ESD arrays, 33 Ω series arrays, selectable 10 k pulls (PCA6408),
per-port adjustable LDO + DAC + INA233 current/voltage monitor, plus a 13-pair LVDS connector (J5),
SYNC (J4) and AUX (J10).

## Floorplan – driven by the silkscreen that was already on the board

The board file still carried its silkscreen (function boxes and labels), a back-side
"wave soldering keepout" drawing around the through-hole connectors, and back-side test point labels.
I treated these as the mechanical/ID constraints of the product and placed every part in its labelled
box, instead of inventing a new arrangement that would make the printed labels wrong:

- status LEDs / user LEDs with their resistors in the two boxes left of the USB connector;
- FX2 right of the USB-C connector (USB pins facing it), crystal and its caps at the XTAL pins;
- FPGA right of the FX2, rotated so that: LVDS balls face J5 (north), port-A balls face east,
  port-B balls face south, FX2 FIFO balls face the FX2 (west). With this rotation the 13 FIFO/flag
  signals that sit in the outer two ball rows reach the FX2 as one planar fan without a via;
- level shifters in the 2 x 8 grid the silk prints (A0..B7), ESD arrays right below/above the IDC
  headers, 10 k pull arrays between the two pin-socket rows, PCA6408s in the PU/PD boxes;
- INA233 / LDO / DAC per port in the "ADC / VREG / DAC" boxes on the east edge;
- 3V3 and 1V2 LDOs, supervisor, EEPROMs, reset switch in their boxes at the bottom left;
- back side: only decoupling and small passives, none inside the wave-solder keepout, none on the
  back-side artwork; rear test points next to their printed labels.

Both sides carry parts (the board has fiducials on both sides). Back-side parts are: two 100 nF per
level shifter directly under it, FX2 and FPGA decoupling, PLL filters, the passives of the east
strip that do not fit in the printed boxes, shield RC, and the rear test points.

A few silkscreen texts were moved by a millimetre or so (or shrunk) to stay readable next to the
parts they name: CLKIF, 1V2/SDA/SCL, 3V3/5V (test points moved), SYNC, AUX, IO PULL-UP/DOWN,
ESD PROTECTION, FX2, FPGA/iCE40HX8K, and the rear VDAC / test point labels.

## Layer stack use

| layer | use |
|---|---|
| F.Cu | parts, most signals, the 7 LVDS pairs of J5's lower row, USB pair |
| In1.Cu | solid GND, never cut |
| In2.Cu | +3V3 plane, with islands: VIOA (top right, reaches J2 pin 2), VIOB (bottom right, reaches J3 pin 2), +5V (left column + band along the bottom edge), GND under the LVDS run (so the B.Cu pairs have ground above them). A few short signal tracks under the FX2/FPGA (see below) |
| B.Cu | decoupling, the 6 LVDS pairs of J5's upper row, connector buses, crossings, GND pour |

+5V goes from the bottom band to the two VIO LDOs as a 0.8 mm B.Cu trunk at x = 118.5 (inside the
wave keepout, where no part may sit anyway). +1V2 is a routed net (no plane): it has four balls,
each with its 100 nF.

## Design rules changed (and why)

- Net class clearance 0.15 → 0.127 mm, minimum track 0.15 → 0.127 mm, hole clearance 0.25 → 0.2 mm.
  Reason: the 0.8 mm BGA. With 0.4/0.2 mm vias a 0.127 mm track passes between two vias (0.1365 mm
  gap); with 0.15/0.15 rules nothing passes and inner balls cannot be reached on a 4-layer board
  without blind vias. Outside the BGA and the level-shifter channels the hand-drawn copper keeps
  0.15 mm or more; autorouted copper may use the 0.127 mm.
- Vias: 0.4/0.2 mm under the BGA, 0.45/0.2 mm for signals, 0.6/0.3 mm for power feeds. All inside the
  board's own minimums (0.4 / 0.2).

## Routing decisions

- **USB**: D+/D- leave the A6/A7 pads as a pair (0.19/0.15) and run 8 mm straight into the FX2. The
  B6/B7 pads are tied in on the back side through the rear D+/D- test points (two small vias per
  line). The TPD3S014 (ESD + VBUS switch) sits 1.5 mm off the pair on short stubs. Both VBUS pad pairs
  are joined on the back through the VBUS test point; ferrite, switch and the 150 µF bulk cap are in
  line before +5V reaches the plane.
- **FX2 ↔ FPGA**: PKTEND, A0, A1, OE, ALERT, FLAGA-C, D3-D7 on F.Cu, equal pitch, 45° fan, no vias.
  FLAGD, RD, WR, DONE, RESET on B.Cu. D0-D2, IFCLK and the CLKREF branch to ball D5 run on In2 under
  the two chips, because B.Cu there holds the decoupling caps; they are short and sit between the
  GND plane and the caps' ground.
- **FPGA**: outer two ball rings escape on F.Cu through chosen gaps, so that each bus leaves in the
  order its target needs (QA/QB/DB in resistor-array order, LVDS pairs side by side). Inner balls on
  dog-bone vias. Six 100 nF under the BGA (one per 1V2/3V3 centre ball where it fits), the PLL
  100 nF caps directly at the PLL balls with the 4.7 µF + 100 Ω next to the BGA edge.
- **LVDS (J5)**: the pinout sorts itself: all pairs for the lower pad row come from the outer ball
  rows (F.Cu), all pairs for the upper row from inner balls (B.Cu, vias between the two pad rows).
  Lanes are stacked so no pair crosses another; 0.19/0.15 mm, In2 is GND above the B.Cu pairs.
  No length matching between pairs was done (see below).
- **Ports**: IDC pin → ESD array on F.Cu (a few mm), IDC pin → pin-socket row as a B.Cu bus,
  socket pin → 10 k array → socket pin on F.Cu. Level-shifter cells are identical: 3V3/GND/VIO vias
  at fixed spots, caps under the part, and the three signals of each shifter in the 1.1 mm channel
  between rows (three tracks per channel). Direction lines come up through one via column left of
  the grid.
- **Power**: every regulator has its input and output cap at the pins; LDO feedback dividers are at
  the FB pin; the INA233 shunt sense lines are Kelvin tracks from the shunt pads through the 4R7 +
  100 nF filter.

## Status

(filled in at the end – see bottom of file)
