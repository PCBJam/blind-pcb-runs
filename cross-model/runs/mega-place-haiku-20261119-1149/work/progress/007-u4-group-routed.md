# 007 — 16U2 / USB / LED group routed (real board)

Routed on the real board, nets: RD+/RD-, D+/D-, USHIELD, CC1/CC2, the 16U2 crystal nets,
UCAP, 8PB4–7 (to J3), MISO2, MOSI2, RESET2 (to J2), M8TXD/M8RXD, RXL/TXL, DTR, L13 and the
LED nets. Command: `bt route --nets ... --order escapes-first --passes 2`.
Result: 27 of 29 connected in 83 s.

Two failed, both boxed in by neighbouring copper at the pads:
- SCK2 (16U2 pin 15): its only way out ran between the MOSI2 track and the NC pad PB0. The
  MOSI2 fan stub and via sat right on that path. Fix (scratch copy first): remove only MOSI2's
  dangling east stub and via (MOSI2 stays connected through its north route), then route SCK2
  alone. SCK2 now connects in 20.7 mm with no via. Applied to the real board.
- Net-(D5-A) (RN3 pin 2): the DTR track runs 0.2 mm from RN3's west pads. Not yet fixed.
  (Moving RN3 east by about 1.5 mm, or re-routing DTR, should free it.)

The picture (007-u4-group-routed.png) shows the USB pair running to RN2, the crystal caps
C16/C17 and R2 in place, and the LED and RESET2 routes.
