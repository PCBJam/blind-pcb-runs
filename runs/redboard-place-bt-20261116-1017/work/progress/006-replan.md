# 006 – re-plan and staged routing
Changes after the failed batch:
- USB serial/JTAG pair moved to F.Cu all the way (lane between the SD pull-up column and the HS pair), so the bottom layer west of the P4 is open again.
- VDD_MIPI pin 41 <-> pin 73 joined by a short In2 track between their two in-ring vias (inside the 1.1V island), freeing the bottom layer under the chip.
- CSI D0/D1 lanes moved 0.6 mm east in the J5/J6 corridor to open a via column beside J5 for pins 1 (3V3_P) and 3 (SCL).
- SD card: stub + via between each card pad and its pull-up, placed by hand; then routed (21–28 mm, bottom layer).
- Every later `bt route` call goes through `scripts/rt.sh`, which passes `--fixed` for all hand-routed/critical nets.
- Order: SD → I2C/BOOT/LED/CAM → header GPIO bus → analog → the rest; first F/B only, then leftovers with In2 allowed as a third layer (2.5x cost, so only short hops… in practice UART0 RX/TX, IO7 took 12–25 mm on In2).
Picture: the board at the end of this phase (taken after the later clean-up, so it also shows the pours).
