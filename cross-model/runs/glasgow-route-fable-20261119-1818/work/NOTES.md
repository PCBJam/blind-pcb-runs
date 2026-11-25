# Glasgow – routing notes

Board: `/work/glasgow.kicad_pcb` (KiCad 10), 80 × 49 mm, 4 copper layers.
Placement was not touched; only tracks, vias and zones were added. The `.kicad_pro` is unchanged.

## 1. Layer use

| layer | use | why |
|---|---|---|
| F.Cu | components, most signals, GND pour | all parts except decoupling/PLL filter parts are on top |
| In1.Cu | **solid GND plane**, no tracks, no splits | one unbroken return plane directly under the component layer; every signal on F.Cu references it |
| In2.Cu | **power planes** (+ a few slow tracks, see 4) | rails need to reach ~40 parts each; planes keep them low-impedance and leave the outer layers for signals |
| B.Cu | second signal layer, decoupling caps under FX2/FPGA/shifters, GND pour | |

In2 is one +3V3 plane with islands cut into it:

- **VIOA** and **VIOB**: comb-shaped islands. Each of the 16 level shifters has its B-side supply on pin 6;
  the teeth of the comb lie under the two pin-6 columns of each bank, the 3V3 plane stays under the
  pin-1 (3V3) columns. The spine of each comb runs to its LDO (U21/U14 area on the east side) and to the
  connector pins that carry VIO.
- **+1V2**: a polygon from the 1.2 V regulator (U36, south-west) up to the FPGA core balls, with a bar under
  the via-free row of the BGA.
- **+5V**: a strip along the south edge (USB side to the two VIO regulators), plus a wide B.Cu trunk in
  the east.
- **GND island under the USB connector / crystal** (x 50–64, y 90–101): the USB pair runs on B.Cu
  there and gets a ground reference on the adjacent layer instead of a power plane.
- A second small **GND island under the bank-B connector J7/J6** (x 107–117, y 104–108): that pocket was
  cut off from the 3V3 plane by the connector's pin row, so it would have been empty.

The stack-up in the file is KiCad's default (three equal ~0.48 mm dielectrics). I left it alone because the
real one depends on the fab. **Order it as a standard 1.6 mm 4-layer stack with thin outer prepregs
(≈0.1–0.2 mm, e.g. JLC04161H-7628 or -3313).** The LVDS geometry (0.19 mm track / 0.15 mm gap) is
roughly 100 Ω differential on a ~0.2 mm prepreg; on a 0.1 mm prepreg it will come out lower (roughly 80–90 Ω; I did not run a
field solver), which is still workable for these short (<30 mm) links, but if impedance control is ordered, give the fab
the 100 Ω target for the 0.19/0.15 pairs and let them adjust.

## 2. Routing approach, by circuit block

**FPGA (iCE40, 0.8 mm BGA-121).** Via map designed by hand: the two outer ball rings leave on F.Cu between
balls; inner balls get a via in the diagonal position and leave on B.Cu. Power balls have their own via
into In1/In2, with the decoupling capacitors on B.Cu at those vias. Signal vias are 0.45/0.2 mm (0.4/0.2 mm, the board minimum, in about twenty squeezed
places), tracks 0.15 mm – the board's stated minimum; no design rule was relaxed and the net classes are unchanged.

**LVDS connector J5 → FPGA (13 pairs).** Routed first, as coupled pairs (0.19/0.15) straight from the
connector pads to the BGA: seven pairs entirely on F.Cu, six on B.Cu (one via at the connector pad and one
at the ball, placed as a pair), so the fan does not have to be 13 pairs wide on one layer.
Pairs neck to 0.15 only inside the BGA field. No stubs. Lengths 14–29 mm.

**FX2 ↔ FPGA (FIFO bus, clocks, control).** One tight bundle on F.Cu between the two chips, ordered so
that nothing crosses; IFCLK and the 48 MHz reference have their own via lanes. The FX2 exposed pad has
thermal vias into In1 and a ground pad on B.Cu.

**USB.** D+/D− as a pair, 13.5 / 14.2 mm, about half on F.Cu (over In1) and half on B.Cu (over the In2
ground island); VBUS on wide copper.

**Level-shifter banks (2 × 8).** Every shifter has the same local pattern: 3V3 via at pin 1, VIO via at
pin 6, GND via between the pads, two 100 nF on B.Cu directly underneath. FPGA-side nets come in on F.Cu
from the series-resistor arrays; port-side nets go through the 33 Ω arrays and then through the ESD arrays,
which sit in line on the way to the connector (the protection parts are not on stubs). Direction lines (DA0–7, DB0–7) are bussed on B.Cu.

**Power.** Regulator input/output paths are short and wide (0.4–0.8 mm) and connect into their plane with
0.5/0.25 or 0.6/0.3 vias; small-signal power pins use 0.25–0.3 mm stubs to a via at the pin.

**Ground.** In1 is the return path. F.Cu and B.Cu are flooded with GND (0.2 mm clearance, isolated
islands removed, zone outlines pulled back 0.4 mm from the board edge – as are the In1/In2 planes) and
ground pads get a via into In1 next to the pad (165 ground vias, 30 of them 4 mm-grid stitching vias);
the pours are an extra, not the connection. Exceptions are listed in section 4.

## 3. Order of work

LVDS pairs → BGA escape → FX2–FPGA bundle → USB/clock → shifter blocks → I/O connectors → power → the
rest. The auto-router (`bt route`) was used for uncongested point-to-point nets (roughly half the nets,
mostly in the I/O and LED areas); everything dense was drawn from scripts and checked with `bt probe`
before it went into the board. See `progress/` for pictures of each stage, including the attempts that
were thrown away.

## 4. Things that are not good, or not finished

Please read these before ordering.

1. **Five nets have pieces on the power-plane layer (In2).** The area between the FX2, the FPGA and the
   shifter banks is completely full on both outer layers, and these nets had no other way through:
   - `/CLKREF` (48 MHz FX2 → FPGA): 4.6 mm on In2 under the FPGA's west edge. This is the one I like
     least, because it is a clock; it is short and its return path is In1 two layers away.
   - `Net-(R10-Pad1)` (SYNC buffer direction, static): 11 mm, with a **via in pad on R10.1**.
   - `+1V2` feed for the PLL1 filter resistor R32: 6.5 mm, 0.25 mm wide.
   - `/~{ALERT}` (open-drain interrupt): 18 mm under the FX2's top pin row and across its WR/RD tracks.
   - `/~{CY_RESET}`: 10 mm down the FX2–FPGA channel. It runs 0.5 mm beside the B.Cu IFCLK track for
     2 mm; the slot in the plane is close to that clock's return path.
   Each of these cuts a 0.5 mm wide slot in the +3V3 plane. Signals on B.Cu that cross the slots do so
   at right angles (WR, RD, FLAGD, DA0/DA2), and all of them are ≤48 MHz logic. A 6-layer stack would
   remove every one of these; on 4 layers with the placement fixed I did not find a cleaner answer.
2. **Via-in-pad** (0.2–0.25 mm holes, not filled): on IC pins U5.2, U5.15 and U19.15; on R9.1, R10.1,
   R7.1, R41.2, R56.1, C22.1, C84.2, C87.2; on LED pads D1/D3/D5 pin 1; on four test points; and on
   the decoupling capacitors under the FPGA (C18, C21, C23, C24, C25, C33, C81). Fine for reflow at a fab
   that tents or plugs small vias; for hand assembly expect some solder wicking. There is no via in a BGA
   ball pad or in an FX2 pin.
3. **LVDS length matching was not tuned.** Intra-pair skew is 0.8–1.0 mm on 10 of the 13 pairs
   (≈6 ps); the pairs themselves are 14 to 29 mm long, not matched to each other. Adequate for the few-hundred-Mbit/s the iCE40
   can do; not matched for a source-synchronous bus that needs tight pair-to-pair skew.
4. **Long detours.** `DB1` goes ~100 mm round the south of J3; `DB0` has 4 vias; `ENVA`, `ENVB` and
   `~ALERT` run ~100 mm round the board edge (west of J5, along the top, down the east side); `VIO_AUX`
   runs 40 mm at 0.3 mm. All are static or slow, but they are long tracks next to the board edge.
   Copper is at least 0.4 mm from the board edge everywhere (the project's own edge rule is 0.05 mm, which I did not rely on).
5. **Minimum geometry is used a lot**: 0.15 mm tracks at 0.15 mm clearance in the FX2–FPGA bundle,
   around the BGA and through the gap between the two shifter banks. This is inside the board's rules and
   normal fab capability, but there is no margin.
6. **I/O tracks are thin.** Port signals are 0.15–0.2 mm; they are protected by the 33 Ω arrays and ESD
   parts, but a wider track would be more robust where the board allows it.
7. **SMD ground pads connect to the pours solidly** (no thermal reliefs). Good electrically; for hand
   soldering 0402 parts thermal spokes would be kinder.
8. The stack-up record in the file is still KiCad's default (see section 1).
9. **Ground connections that are weaker than the rest:** C81.2 (3V3 decoupling at the FPGA's south-west
   corner) reaches its via through 2.3 mm of 0.15 mm track on B.Cu, C20.2 through 1.5 mm of 0.2 mm track –
   there was no room for a via at the pad. The lower-row ground pins of J5 have their via ~1 mm beyond the
   pad end. The 16 shifter blocks share one ground via per shifter with its two decoupling caps (more
   vias there cut the 3V3 strip on In2 – tried and removed, see progress/012).
10. **Narrow plane necks.** The 3V3 strips between the VIOA/VIOB comb teeth, and the webs feeding the
   FPGA's inner 3V3 balls, are only as wide as the via fields allow (down to ~0.3 mm in the BGA). They
   are connected (checked on the filled zones) and each load has its capacitor at the pin, but anyone
   adding vias in those areas later must re-check the fill.
11. **DRC leftovers that are not about routing** (they are in the supplied footprints/placement and I
   did not touch them): 4 × `footprint_type_mismatch` (U1, J1, U8, U36 are flagged "through hole"),
   and warnings for library mismatch, courtyard overlap (68), silkscreen (95). The schematic-parity
   check reports 421 items, e.g. net names `+3V3` on the board against `+3.3V` in the schematic – the
   board's own netlist was used as given.
12. `/work/.bt-undo/` (the last 20 board snapshots kept by `bt`, ~60 MB) is a left-over of the work and
   can be deleted. My own scratch files are removed.
13. **Check of "footprints not moved".** My copy of the original board was in /tmp and was lost when the
   sandbox restarted between two sittings. All edits were made with tools that only add or remove tracks,
   vias and zones, and I compared position, rotation and side of the footprints with the part listings
   printed at the very start of the job (result in section 5), but a byte-level comparison with the
   original file was not possible.

## 5. Verification

Final state of `/work/glasgow.kicad_pcb` (file format 20260206, KiCad 10.0):

| check | result |
|---|---|
| `bt ratsnest` (filled zones counted) | 0 nets unconnected |
| KiCad DRC, `kicad-cli pcb drc --severity-all --refill-zones` on a scratch copy | 0 unconnected; **0 clearance / short / hole / dangling / thermal violations** |
| remaining DRC errors | 4 × `footprint_type_mismatch` (supplied footprints) |
| remaining DRC warnings | 414, all library / courtyard / silkscreen (supplied placement) |
| footprints | 272 on the board. Position, rotation and side of 264 of the 265 named ones compared with the listings from the start of the job: all identical; one was never listed, and the 7 graphic `REF**` items cannot be told apart by name |
| `glasgow.kicad_pro` | not written by me: its modification time is still that of the delivered schematic files, and it is identical to the copy I took before the last day's work (rules and net classes untouched) |

Numbers: 475 vias (384 × 0.45/0.2, 23 × 0.4/0.2, 19 × 0.5/0.25, 49 × 0.6/0.3; 165 on GND), about 2400
track segments, 2.08 m of track on F.Cu, 2.05 m on B.Cu, 51 mm on In2, none on In1; 10 zones.

What was *not* checked: impedance (no field solver run – the pair geometry is the net class's), signal
integrity or power-integrity simulation, and manufacturability beyond KiCad's DRC with the project's rules.
