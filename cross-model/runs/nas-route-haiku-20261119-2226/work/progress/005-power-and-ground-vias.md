# 005 – zone connections (power vias and GND vias)

Picture: `005-power-and-ground-vias.png` (x 116–230, y 54–100, pads shown). Note: I did not save a picture at the moment this step finished. This one is the board as it is at the end of the session, so it also shows the later edits (CM4 and RP2040 routing) in the same area; the vias and zone connections described below are all visible in it.

**What I did**

- `bt plane` (stub + via per SMD pad into the net's own In2 pour), then `bt apply --checked`. Pads the planner could not reach were routed to the pour with `bt route --from PAD` (the router drops a via into the pour).
  - +12V: 20 vias planned, 13 applied directly. The eFuse output pins U3.10–12 sit above the +12V zone's old top edge (y 75.6), so I extended the +12V zone with a 3 mm protrusion to y 66 at x 125.9–128.8. Those pins then took vias. Net fully connected.
  - +3.3V_M1..M4: 8–10 of 15 pads planned per rail with 0.45 mm vias. The bottom-row power pads of each socket are boxed in by the PCIe escapes, so the rest were routed one by one (`bt route --from J2.2`, ...). 3 pads of M1 needed hand-placed vias (`bt via --near`). Several joins run through short 0.127 mm necks at the pads (0.5–6 mm of neck in total); flagged for review.
  - +1V2: 23 of 29 pads by plane vias, 5 routed to the pour; U12.64 still open (no legal via within 2.5 mm: the PCIe_CLK_N_4 track sits against it).
  - +3.3VSTB: 22 of 26 by plane vias, 4 routed.
  - +5V: 10 of 14 by plane vias in the west zone, then the east pins (fans M1–M3, U4, C8) routed to the net's copper: the east part is connected to the west zone through B.Cu/F.Cu tracks. No east +5V zone was added.
  - GND (In1.Cu): 227 of 268 pads planned, 197 new vias, applied with `--checked`. The 28 pads without a spot (CM4 GND pins and several R/C/J pads) were routed to the In1 plane; 24 succeeded, R6.2, R35.2, U9.8, R32.2 still open.
- The fills were refreshed with `bt fill` after the vias went in. Stale fills had been making the ratsnest look connected.

**Open after this step** (background retry of each in progress, with `--all` and 40 s per link): +3.3VA (rejected by the guard in the bulk pass, now the +1V2 vias exist), +3V3 (CM4 3.3 V output, boxed in by SDA_CM4 and SD_DAT0), CM4_RUN, SD_CMD, M2PWR_EN, LED_V+, PICO_PWM1/4, TSENSE_0/2/3, the two CM4 USB nets, the two USB-C pairs (RP2040 side and J7 side), Net-(C10-Pad2), Net-(R24-Pad2), the R20 piece of +3.3V_M1, and four GND pads.
