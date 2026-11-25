# 008 — FPGA area at the end of the session

Zoomed view of the FPGA (U30, centre), the FX2 (U1, left), the Port A buffers (F side, top right of the FPGA) and the Port B buffers (B side, below). What to look at:
- The FPGA ball field: dog-bone vias and stubs. The inner balls (H7, J7, J9, K10 — the FX2 data pins D0..D3) are boxed in by the fan-out stubs of other nets; this is the main reason the FX2 bus is still open.
- The bank A/B stubs (DA/QA on the right, DB/QB on the bottom) and their RN networks.
- Decoupling caps on the B side, and the +3V3 and GND vias they connect through.
