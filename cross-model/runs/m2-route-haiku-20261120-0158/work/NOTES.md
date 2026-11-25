# NOTES — M.2 PCIe x4 adapter, 4-layer routing

## Status: NOT ready to order yet

- `bt check` on the saved board: **0 DRC errors, 0 bt findings**, zones filled.
- **Ground is not complete: 9 KiCad unconnected items (10 pads)**:
  M.2 (J2) ground pins 9, 21, 27, 33, 39, 45, 51; PCIe (J1) pad A15 and the pair A27/A28.
  These are the open item. Details and why below.
- Everything else is routed: all 18 PCIe lane legs (IN, OUT, REFCLK), PERST#/PWRGD, WAKE#,
  CLKREQ# (with R2/R3/R4 as in the schematic), +12V, +3V3, +3V3_AUX, +5V, and the decoupling
  caps' power pins. Each lane pair is length-matched to within 0.003 mm.
- Progress log with pictures and notes: `progress/001` … `progress/006`.
- Tool notes: `BT-REVIEW.md`.

## Layer stack use (decision)

| layer | used for |
|---|---|
| F.Cu | GND pour (reference for In1 lanes), lane landing stubs for OUT pads, control and +3V3 finger links, short power tracks |
| In1.Cu | GND zone (whole board, carved by the lanes) and most lane legs |
| In2.Cu | GND zone (whole board, carved) and the rest of the lane legs |
| B.Cu | lane exits from the M.2 fingers, IN landing stubs, decoupling, power tracks, GND pour |

- **No power planes.** In2 carries lanes, so a 3V3/12V plane there would put lanes over a
  non-GND reference and cut the GND they need. 12V and 3V3 run as tracks (0.6-0.8 mm) and
  the decaps sit at the pins. The current paths are the weak point (see below).
- **Why lanes sit on inner layers.** On this footprint the lanes come out of the M.2 edge
  (left) and go into the socket (bottom), and both connectors list the lanes in the same
  order. A same-order chord set must cross itself, so no single layer can carry them.
  Tests: all 18 lane nets on F/B only got stuck at the M.2 fan-out (progress 001); on
  F/B/In1/In2 the greedy router routed 16 of 18 (progress 002).
- Reference planes: In1 lanes are referenced to the F.Cu GND pour (0.12 mm); In2 lanes to the
  B.Cu GND pour (0.12 mm). The inner GND zones are the second reference.

## Lanes

- **D3 pair (top) routed first on explicit corridors**: `bt route --batch` with waypoints and
  paired via points on B.Cu/In1.Cu. Each leg goes down the west edge of the fan on In1 (x
  110.2-111.2), then east at y 107-108, down to y 117.9-119.25 under the two west landing
  pads on In1, and rises to a via 0.35 mm above its pad. The four legs are nested so none
  crosses. Lengths: IN P 45 mm, IN N 45 mm, OUT N 40 mm, OUT P 40 mm (then tuned).
  The top pair must travel the whole bundle; this is the price of the crossing.
- **D2 … REFCLK**: routed by `bt route` around the D3 structure (shortest first; 16 of 18 in
  the one run, the last two by shove/rip-up).
- **Vias**: 0.45/0.25 at the M.2 fan-out (fingers 0.5 mm apart; 0.6 mm vias don't clear the
  next lane's exit), 0.6/0.3 elsewhere.
- **Length matching** with `bt tune` (45-degree bumps on the short leg): D3 IN +4.5 mm, D1 OUT
  +1.6, D0 IN +0.8, REFCLK- +0.75, D0 OUT +0.6, the four smallest +0.3-0.4. Every pair now
  matches to 0.003 mm. The bumps sit next to GND pours; the zones were refilled.
- **Impedance**: the Z85_PCIE geometry (0.185 mm track, 0.145 mm gap) on 0.12 mm prepreg
  estimates at about 90-95 ohm (closed-form, not a field solve). Within the PCIe 85 ohm
  ±15 %, but not verified. Please run a field solver before the stack is released.

## Power and control

- +12V: 0.8 mm tracks from the Molex pin 1 (J3.1) to J1 A2/A3/B1/B2/B3, C1, C2, and the J4
  test pad.
- +3V3: 0.6 mm from the nine M.2 3.3 V fingers (2, 4, 12, 14, 16, 18, 70, 72, 74) to J1 A9/A10/B8,
  R1, and decaps C3/C4/C7/C8/C9. Three finger links were necked to 0.18 mm where the
  neighbouring fingers leave 0.15 mm (2.6 mm in total).
- +3V3_AUX (0.4 mm) and +5V (0.5 mm, Molex to the J5 test pad only).
- CLKREQ# (J2.52 -> R2.1): R2 sits in the middle of the lane fan. The D2 OUT P leg was
  rerouted around R2 so CLKREQ could get a via.
- Net class `Power` (track 0.6 mm, via 0.6/0.3, clearance 0.145). Its first setting of 0.2 mm
  caused four false clearance errors against the NC finger pads; set back to 0.145.

## Ground

- GND zones: In1.Cu and In2.Cu (whole board), F.Cu and B.Cu (whole board), clearance 0.2 mm.
- 139 stitching vias (pitch 3 mm, `bt stitch`, free positions only).
- Vias at the J1 ground pads (`bt escape`), and vias for the decap GND pads C5.2 and C6.2.

## Open items — what is wrong and why

1. **M.2 ground pins 9, 21, 27, 33, 39, 45, 51 (J2) are not connected.** The 14 M.2 ground
   fingers sit between the lane fingers at 0.5 mm pitch, on the B side. Their only way out is
   a via in a column 0.6-2 mm east of the fingers. That space is taken by the D3 corridors
   (x 110.2-111.2, a via at x 109.8 would be 0.08 mm too close) and by the lane vias (x 111.4)
   and their inner routes (crossing rows 94-103 at x 112). I tried to free the column by
   moving the whole fan 2 mm east (progress 003-004); the greedy router could not place the
   remaining lanes in that layout, so I rolled back to the complete lane set. Pins 3 and 15
   are connected (vias at x 112.0). The fix is a deliberate re-layout of the fan-out: lane
   exits that run horizontally for about 2 mm before turning, D3 corridors outside the
   ground column, and vias placed by hand. I did not finish it.
2. **J1 A15 and A27/A28 are not connected.** Each sits in a column that a lane landing via
   already uses. `bt probe` found no legal via spot within 2 mm, and the 7.9 mm track join
   that `bt islands` offers would cross lanes.
3. **Power is by track, not by plane.** The 3V3 path from the M.2 is the top fingers (2, 4) and
   the 0.6 mm bus, plus the two necks. A card drawing 3 A on 3V3 may run a few tens of degrees
   warm and see a few tens of mV drop. Check the IR drop before ordering.
4. **The D3 pair is 40-45 mm long** (the others 31-34 mm). It is matched and tuned, so skew is
   fine, but total loss is about 30 % more than the other lanes. A better fan-out (item 1)
   would shorten it.
5. **Impedance** is estimated, not solved (see Lanes).
6. **Stub on the landing pads**: the D3 IN/OUT legs drop onto their pads through short F/B
   stubs 0.35-0.8 mm long. Those stubs are inside the pad footprint, as the router made them.
7. KiCad shows 20 warnings "footprint library 'antmicro-footprints' not configured". This is
   the environment's library setting; it does not affect the board.
8. `/work/.bt-undo/` holds bt's undo history for the board (last 20 writes). Delete it if not
   wanted.
9. Silkscreen and solder-mask were not reviewed beyond the bt/KiCad checks.

## Not verified

- No 3D or field-solver check, no thermal check, no mask/paste review, no SI simulation.
- The lane and power routing was checked by KiCad DRC (through `bt check`) only.
