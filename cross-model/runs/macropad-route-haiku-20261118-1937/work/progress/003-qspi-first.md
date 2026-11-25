# 003 — QSPI, first pass (applied)

Six QSPI nets routed with bt route (escapes-first). Flash pins 1-4 face the RP2040 bottom edge, pins 5-8 face away from it, so the bottom-row pins (SD0, SCLK, SD3) wrap round the flash's west side and south edge. Two B.Cu runs in the gap between the chip and the flash (SD1, SCLK). 4 vias. Lengths 10-22 mm.

Why it is like this: the flash sits where its far pins must go round the body; the RP2040's QSPI pins are on the west edge, nearest the flash's north-west corner.

Problem found later: the SD3 run passes at y=108.39, just south of RP2040 pin 50 (+1V1), which then has no west exit. Fixed later by moving pin 50's escape (see 007).
