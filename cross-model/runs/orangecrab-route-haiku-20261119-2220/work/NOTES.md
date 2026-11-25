# OrangeCrab 6-layer routing - notes

**Status: NOT finished. Not ready to order.** 63 nets are not fully connected (120 unconnected items), and the
board has 153 DRC errors. None of the errors are shorts, track clearance violations, track crossings or track-width
violations; the errors are (a) copper that touches the board edge at the Feather headers, (b) courtyard overlaps in the
placement, and (c) one malformed courtyard, all from the fixed placement. The open connections are listed below.

Files: `OrangeCrab.kicad_pcb` (the board), `OrangeCrab.kicad_pro` (net classes changed, see below), `progress/` (numbered
steps 001-007 with pictures), `scripts/` (my helpers, see the end), `BT-REVIEW.md` (feedback on `bt`), `.bt-undo/` (bt's
undo copies of the board from its writes; `bt undo` uses them, delete it if you don't want them).

## Layer stack and what it is used for

| Layer | Use | Why |
|---|---|---|
| F.Cu | components, FPGA/DDR3 escape stubs, short links | surface |
| In1.Cu | GND zone (whole board, 0.2 mm clearance) + I/O microvia landings | blind microvias from F.Cu land here; the GND zone is cut where a route crosses it |
| In2.Cu | signals: DDR3 (escape from the BGA, most of the byte lanes), FPGA escape, the power jump vias in the FPGA field | between two GND references (In1 and In3) |
| In3.Cu | GND zone (whole board, 0.2 mm) | reference for In2 |
| In4.Cu | power: tracks only (no zones yet); rails P1.1V, P1.35V, P2.5V, P3.3V, RAM_VDD, RAM_VDDQ | the FPGA field is too dense for a split plane (see below) |
| B.Cu | decoupling capacitors, some signals, back-side connectors (SD card, U9 mux) | surface |

Stack-up: not written into the board (there is no `(stackup)` block in the file). Please add the fab's stack
(6 layers, 1.6 mm, 1 oz outer / 0.5 oz inner, the prepreg of your fab) before ordering; I did not impedance-control
the DDR3 tracks.

**Blind microvias F.Cu->In1.Cu (laser, 0.25 pad / 0.10 drill):** 75 in total: 16 on FPGA ground balls (one per group of
bridged ground balls) and 59 on FPGA I/O balls. The fab must support 1+4+0 (one-sided) laser microvias. Through vias are
0.28/0.15 (fine-pitch escape, power balls, DDR3 ground/power, decoupling ground pads) and 0.45/0.2 (Default class).

## Why the FPGA field is built this way

The FPGA (csBGA285, 0.5 mm pitch, 0.23 mm pads) has 127 ground and 36 power balls in its middle, and the decoupling
capacitors sit on the bottom layer under it. Through vias on every ground ball would perforate In2, In3 and In4, and then
no power ball could reach its plane. So:
- Ground balls are bridged on F.Cu (adjacent ground balls joined by 0.089 mm tracks, `scripts/gnd_bridges.py`). One
  blind microvia F.Cu->In1.Cu per connected group: 111 bridges and 16 groups. Before this there was one microvia per ball
  (126), which closed In1 for the I/O escape.
- Power balls each get a through via at an interstitial site (`scripts/bga_sites.py` + `bga_assign.py`, a small
  constraint search). The power rails are then routed on In4 (and In2 for jumps) between those vias. That worked for
  P1.1V (all links), P3.3V and most of P1.35V and P2.5V (see the open list).
- DDR3 (BGA-96, 0.8 mm): the same site search for its ground and power balls was blocked by the escape copper, so
  `bt via --near` placed 38 through vias (ground and VDD/VDDQ). The signals escape with `bt fan` on F.Cu and In2.

## Routing that is done

- FPGA escape (`bt fan`) for 103 signal nets (F.Cu rows, In2 and B.Cu dog-bones), then re-done for the I/O nets with microvias.
- DDR3: 41 of 50 signal nets routed, VDD (14/14) and VDDQ (15/15) routed. Routes go round the FPGA's top and bottom edges
  because the fan exits on the far side of the DDR3 array wrap round the BGA: **the DDR3 is not length-matched at all** and
  several byte-lane routes are long detours. No `bt tune` has been done.
- Ground: In1 and In3 zones; 86 of 117 small-part ground pads have a stub and via to the In3 zone; the FPGA ground balls
  reach In1 through the 16 microvias; the bridged groups were checked with `bt probe`. 16 ground groups stay boxed in on
  the back-side decoupling pads under the FPGA (`bt islands --net GND`), and 2 of them were joined automatically.

## Still open (63 nets) - the important ones

- **FPGA I/O, the whole west and north-west edge and the Feather headers' IO:** RAM_D11/D12/D15 (DDR3 byte lane 1),
  RAM_CK+/-, RAM_CAS#, RAM_A10, RAM_A13, RAM_BA0, /DRAM/RAM_ZQ, ECP5_VREF (5 pads), IO_6, IO_SCL, IO_SDA, IO_A0/A2/A3/A4,
  IO_MISO, IO_MOSI, IO_0, EXT_PLL+/-, USB_D+, SD0_CMD, SD0_DAT1, SD0_DAT2, QSPI_D2, JTAG_TCK, SPI_CONFIG_*, LED_B/R/G,
  ADC_MUX0-3, ADC_SENSE_HI/LO, EN, /IO/AREF, /IO/A2-A5, Net-(R32-Pad2). These are blocked by the 51R resistors and the
  decoupling pads on B.Cu at the west edge, by the fan's F.Cu exit combs (north and east), and by the charger area.
- **Power-in:** VSYS (2 unconnected pads plus 12 pieces), VBATT, PUSB_VBUS. All their pads are on F.Cu round the
  charger and the buck converters, and the pads are boxed in by the tracks already there. The plan was zones on F.Cu;
  not done.
- **Rails:** P1.35V (4 links, one is D17, boxed in by DDR3 escape copper), P2.5V (3 links; U9.18 is a mux supply pad
  between P1.1V and P1.35V pads on B.Cu and I could not get out), P1.1V (2), P3.3V.
- **Ground:** 45 unconnected items (16 groups boxed in on B.Cu decoupling pads under the FPGA, the rest small).

## Things that are not good

- DDR3 routing: long detours, no length matching; the byte-lane and CK skew requirements are not met.
- FPGA escape: the fan's F.Cu exit combs (0.25 mm spacing) and the B.Cu decoupling under the FPGA close off most of the
  periphery. This is the main reason the I/O is not routed.
- Net classes: Default via is now 0.45/0.2; the DDR3 DQS classes and the DDR3 clock class use 0.28/0.15 (the clock pair
  was moved into DDR_CLK_LM1.0, which had no nets). Power is 0.3 mm, PowerIn (VSYS, VBATT, PUSB_VBUS) 0.5 mm.
- Power tracks on In4 are thin (0.15-0.3 mm) in the FPGA field. Current capacity of the rails is not checked.
- Track widths: the board minimum is 0.0889 mm; many of the routes are at that width, which is below the 0.127 mm
  "usual fab" minimum that `bt` mentions. Widen the non-critical ones before ordering.

## Placement problems I could not fix (placement is fixed)

- 84 copper-to-edge errors: the Feather headers J1 (top) and J2 (bottom) have pads that touch the outline (actual 0.00 mm
  against 0.25 mm). The outline must move out or the headers must move.
- 68 courtyard overlaps (for example U4 with C74, U5 with C13, R7 and R8) and 1 malformed courtyard (J5).
- Library warnings: the footprint library `gkl_housings_bga` is not configured in this project.

## What I would do next

1. Fix the outline at the headers and the courtyard overlaps (placement), then re-run `bt check`.
2. FPGA: either move the B.Cu decoupling away from under the BGA or accept a stronger escape (HDI second order).
   Then re-fan the I/O on F.Cu with spacing and route the open list with `bt route --nets` in order.
3. Power-in: F.Cu zones for VSYS, VBATT and PUSB_VBUS round the charger, then `bt islands` and fix the pieces.
4. DDR3: re-route the byte lanes with `bt bus`/`bt pair`, then `bt tune` to match lanes and CK.
5. Add the stack-up to the board, widen the tracks that carry current, and re-check.

## Helpers in `scripts/` (not part of the board)

- `bga_sites.py`, `bga_assign.py`: site search for ball vias/microvias (used for the FPGA power balls and the first
  ground microvias).
- `insert_microvias.py`, `strip_microvias.py`: write / remove `(via micro ...)` blocks as text (pcbnew writes them the same way).
- `rail_mst_batch.py`, `route_rails.sh`, `route_power_rest.sh`: MST batches for the power rails and per-net routing.
- `near_vias.sh`: `bt via --near` for a list of pads.
- `gnd_bridges.py`: ground bridges and group microvias.
- `io_mst_batch.py`: MST batch for I/O nets from the microvia points (did not help; see 004).
