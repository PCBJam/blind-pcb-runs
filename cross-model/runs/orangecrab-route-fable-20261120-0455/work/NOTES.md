# OrangeCrab – routing notes

**Status in one line: the board is NOT ready to order.** All supplies, the complete DDR3 interface and about 120 of the 143 signal nets are routed and the copper that exists is DRC-clean, but 23 signal nets are still open (list below), the DDR3 bus is not length-tuned, and a few compromises need review.

Footprints: none moved, added or removed (`bt same`: "nothing locked moved, no parts added or removed, pad nets unchanged").
KiCad DRC against the original board: 0 new errors; 17 warnings (dangling stubs/one via of the unfinished nets); 29 unconnected items.

## Layer stack

| layer | use |
|---|---|
| F.Cu | components, BGA escape of the outer ball rows, short DDR stubs, CK±/CKE, GND pour, small solid pours at the three buck outputs |
| In1.Cu | GND plane, uncut |
| In2.Cu | main DDR3 layer (stripline between In1 and In3), FPGA inner-row escapes; small P1.35V pour under the FPGA core only |
| In3.Cu | GND plane. **Compromise:** at the very end I allowed a few slow nets onto it because nothing else was free: P2.5V, ECP5_VREF, parts of USB D+ (connector side), SD0_CD, LED_B, ADC_SENSE_HI and two short power/ground links. The P2.5V track runs under part of the upper data byte – it should be moved. |
| In4.Cu | split power: P3.3V (base), P1.1V (FPGA core + feed corridor), P1.35V ("C" round the FPGA, strips to the DDR ferrites and to the VREF divider), RAM_VDD (address half of U4 + centre channel + strip between the BGAs), RAM_VDDQ (data half of U4) |
| B.Cu | decoupling, the rest of the DDR nets, SD card, analog/ADC nets, GND pour, VSYS pour under the microSD socket |

Why GND on In1 **and** In3: the DDR bus is the fastest thing on the board and In2 is its main layer; with two ground planes it is a true stripline whatever the fab's dielectric build-up is. The cost is that B.Cu references the split power plane, so the DDR nets on B.Cu were kept over the RAM_VDD/RAM_VDDQ/P1.35V islands.

## Rules and classes (in the .kicad_pro)

- Clearance 0.0889 mm everywhere (needed between 0.5 mm-pitch balls). Board minimum clearance set to the same value (was 0).
- Default class width lowered step by step to 0.089 mm because the router refuses to go below the class width; DDR classes 0.1 mm. RAM_CK± moved into the DDR_CLK class (it was empty).
- Vias: 0.28/0.15 under and next to the FPGA (the only size that fits between 0.5 mm balls), 0.3/0.15 under the DDR3 BGA, 0.45/0.2 and 0.6/0.3 in the supply section. 0.15 mm drills with 0.065 mm annular ring are at the limit of standard 6-layer processes – check with the fab.
- New "Power" class (0.2 mm minimum) for the rails.

## DDR3

- U4: every ball has a dog-bone to a via on a half-row line; tracks run in fixed slots at row ±0.1 mm on In2 (26 nets) and B.Cu (17 nets). A1/A8/A11/A14 and CKE stay on F.Cu with no via. CK± go F.Cu → In2 in front of U4 → ball via → B.Cu → R5/R13 (termination after the ball).
- FPGA side: outer two ball columns leave on F.Cu and drop through one via; inner balls use pre-placed vias on interstitial sites.
- The upper-byte slots at U4 were re-assigned so nets do not cross (D13/D15 reach their balls through U4's centre channel on B.Cu, LDM on F.Cu).
- **Not done: length matching.** Present lengths (track only): address/control 7.6–16.9 mm, CK 17.7 mm to the ball; lower byte D0–D7 8.3–13.5 mm with its strobe pair 12.3/12.9 mm; upper byte 11.3–17.2 mm with its strobe pair 14.2/14.4 mm; RAM_LDM 19.8, RAM_UDM 13.5 mm. Worst skew inside a byte ≈ 6 mm (≈40 ps), address vs. clock up to 10 mm. That works at DDR3-800 timing budgets but is far from the 1 mm the class names ask for, and there is little room left for meanders.
- Naming trap in the schematic: the nets called RAM_UDQS± go to U4's *lower* strobe balls (F3/G3) and sit in the FPGA DQS group of D0–D7; RAM_LDQS± go to the upper strobe. The net classes group them by name, not by byte. Match D0–D7 to RAM_UDQS± and D8–D15 to RAM_LDQS±.
- RAM_RESET# is not routed.

## Power

- Bucks: switch nodes are short 0.4 mm tracks, each output has a solid F.Cu pour over inductor + output caps with vias into its In4 island; VSYS is a B.Cu pour fed through 0.6/0.3 vias.
- FPGA: ground balls are strapped ball-to-ball on F.Cu into a mesh with ~50 vias; every supply ball has its own via, most of them landing in the pad of the matching back-side 0201 cap (via-in-pad on the cap side – needs plugged/tented vias or accept some solder wicking).
- **Weak points:** VBATT is only 0.2 mm wide (router result; should be ≥0.4 mm for charge current). PUSB_VBUS is 0.4 mm. C52 (P1.1V decap, pad 1) and C26 (VREF cap, GND pad) are not connected – both are boxed in by signal tracks. No ground stitching vias were added round the board edge or between the pours.

## Nets that are NOT connected

RAM_RESET#, FPGA_RESET, JTAG_TCK, JTAG_TMS, /IO/_USB_D_N (connector side of USB D−), SD0_CLK, SD0_CMD, SD0_DAT3, LED_G, USER_BUTTON, IO_0, IO_1, IO_5, IO_6, IO_10, IO_MISO, /IO/A1, /IO/A2, /IO/A3, /IO/A4, /IO/A5, Net-(J3-PadB5) (USB-C CC2 pull-down), Net-(R44-Pad1).

So as it stands: no USB, no JTAG clock, no SD card, no DDR reset – the board would not work.

Why they are open: each of them starts on an FPGA ball (or ends on a pad) that is now walled in by copper routed earlier. The FPGA's north side has 18 front-layer lanes at 0.25 mm pitch of which 12 need a via within 2 mm; the south-west corner is similar. They need a planned, staggered via pattern (I worked one out for the north side – lanes jogged 0.03–0.06 mm so each passes its neighbours' vias at 0.28 mm, two via rows at y≈95.85 and 95.35 – but did not get to building it) and rip-up of some of the router-made tracks around them. Their pre-placed escape stubs and vias are still on the board and show up as "dangling track" warnings.

## Other things I know are not good

- Almost all signal tracks are 0.089–0.1 mm wide, also where there is room for 0.15 mm. They should be widened outside the BGA fields.
- USB D+/D− between FPGA and series resistors are short and fine; the connector side is not a matched pair (one half missing, the other partly on In3).
- Router-made detours: ADC_MUX1 (~30 mm), IO_SDA (~30 mm), several /IO/A* and SPI nets with 3–4 vias.
- The In2 P1.35V pour under the FPGA and the In4 islands were drawn as simple boxes; power vias of the "wrong" rail inside an island rely on the other layers.
- GND pours use solid pad connections (also on the header pins) because thermal spokes came out starved.
- Silkscreen, fiducials and courtyards were not touched or checked.

## How it was done

Table-driven Python generators for the two BGA fan-outs and the DDR corner, each checked with `bt probe` / `bt apply --checked`; `bt route` for open areas; `bt zone` / `bt plane` / `bt islands` for planes and supply vias; a small grid maze router of my own for part of the leftovers. The scripts are in `progress/scripts/`. The step-by-step log with pictures is in `progress/`.
