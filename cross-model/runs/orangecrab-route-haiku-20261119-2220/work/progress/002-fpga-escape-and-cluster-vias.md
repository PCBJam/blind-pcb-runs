# 002 - FPGA (U3) escape, ground microvias and power vias

**Stack decided (see NOTES.md):** F.Cu signal, In1 GND (solid zone), In2 signal, In3 GND (solid zone), In4 power (split), B.Cu signal.
Blind microvias F.Cu->In1.Cu are used for the FPGA ground balls, so the inner layers stay open.

**What was done**
1. GND zones on In1.Cu and In3.Cu (whole outline, clearance 0.2).
2. `bt fan U3` run on a scratch copy with the ground and power balls cleared, so only the 103 signal nets were fanned out (185 segments, 25 vias, 0 poured pads). Applied after `bt probe` said all clear against the real board.
3. The FPGA centre (ground and power balls) cannot take a through via per ball: 127 ground vias would perforate In2 and In4 at 0.5 mm pitch, and the power balls then could not reach their planes. A small solver (`/work/scripts/bga_sites.py` + `bga_assign.py`) picks one interstitial site per ball, with a 0.089 mm stub on F.Cu:
   - 126 ground balls -> microvia F.Cu->In1.Cu (0.25/0.10) at the site (inserted with `insert_microvias.py`).
   - 35 power balls -> through via 0.28/0.15 at the site.
   - Two balls left unassigned (see below).
4. Net classes set with `bt rules`: Power (0.3 mm, via 0.28/0.15), PowerIn (VSYS, VBATT, PUSB_VBUS at 0.5 mm), DDR_CLK gets RAM_CK+/-, DQS classes via 0.28/0.15, Default via 0.45/0.2.

**Result:** `bt probe` clears all stubs and through vias; the microvias were checked as through vias and 44 of 126 hit only B-side resistor pads, which a microvia does not reach. Not yet checked by KiCad DRC.

**Open:** D17 (P1.35V) is boxed in by DDR3 escape copper (RAM_D0, RAM_D3, RAM_UDM on F and In2). V15 (GND) is boxed in by the W-side escape. Both are handled later.
