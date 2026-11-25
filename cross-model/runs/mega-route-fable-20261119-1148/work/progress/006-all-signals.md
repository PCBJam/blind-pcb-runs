# 006 – USB, bridge MCU, power, and the rest of the west side

Everything except GND is connected (ratsnest: only GND left).
- USB-C: D+ from A6 straight to the 22R array, B6 joined behind the pad row; D- from A7, B7 by a
  6 mm B.Cu jumper (the four data pads interleave, one crossing cannot be avoided). RD+/RD- as a
  pair into the 16U2. Both VBUS pad pairs leave through the gap under R3/R4, drop to B.Cu and
  run under the connector shell to the fuse (the footprint's pegs block every F.Cu way round).
- 16U2: crystal, UCAP, LEDs, UART resistors all on F.Cu, short. Three nets need a B.Cu hop here
  because the pin order and the header order disagree: MISO2, RESET2 (to its pull-up in RN5, a
  long one, kept in a "slot" east of the 16U2 next to DTR's hop) and DTR (to C9).
- Power: barrel jack → D4 1.2 mm; VCC 1.0–1.2 mm, on F.Cu round the regulator; +5V from the
  regulator tab through three in-pad vias and a 1.0 mm B.Cu track to the USB switch FET, 1.0 mm
  F.Cu lane to C2 and on (0.8 mm) to the 5V header pin; B.Cu "spine" 0.8 mm up to U6/RN4 and a
  0.6 mm trunk on to FB2/AVCC and the bar under the MCU; second trunk from C6 to the MCU's south
  and west supply pins. RESET to the button in the top-left corner: no way through the USB area,
  so it goes on B.Cu along the west board edge (50 mm).
- First probe runs flagged 8+8+1+2 clearance misses in these scripts (pad corners I had taken
  as round, a peg hole under a B.Cu track, two fan-outs too tight); all fixed before applying.
