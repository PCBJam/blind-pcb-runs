# 004 — FX2 moved up 2 mm; FX2-to-FPGA bus re-routed (in progress)

**What happened**
- First pass of the FX2-to-FPGA nets (13 of 24 routed; 11 ok). The rest failed: the FX2's bottom-edge bus pins (D0-D7, y 102) had to cross the FX2's right-edge control lanes to reach the FPGA's west exit stubs (y 94-101). Re-routes after clearing the corridor (moving 6 decoupling caps, 2 I2C pull-ups, 2 test points) still failed: the FPGA-side inner balls (H7..K10) were boxed in by stubs and vias of nets routed earlier in the wrong order.
- Unrouted all FX2-to-FPGA nets (172 items) and tried `bt bus` and `--rip --move-board`: both failed.
- Diagnosis: the FX2 bottom bus pins sit 4 mm below the FPGA's left-side exit lanes, so every bus net has to cross the control nets.

**Change of plan**
- Moved the FX2 (U1) from (66, 98) to (66, 96). Its bottom bus pins now sit at y 100, level with the FPGA's west exits (y 98.4-101.2), and its right-edge control pins level with the upper exits.
- Side effects: TP6 and C16 moved off its footprint; C9 and R19 and R18 (FX2 top-edge pull/decap parts) moved to the bottom side; the USB pair re-routed to the new pin positions (5.3 mm, nearly straight, 0.3 mm, skew 0.05 mm). Bridges, U15 taps and both test-point links re-made; all USB-area nets now connected.

**Still open at this point**
- The FX2-to-FPGA bus re-route (background run, see next entry).
