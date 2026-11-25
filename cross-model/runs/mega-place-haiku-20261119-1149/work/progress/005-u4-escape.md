# 005 — ATmega16U2 dog-bone escape (written to the board)

Picture: 005-u4-escape.png (rendered from the board as it is now; the 16U2's escape copper
is the same as when it was written).

Moved D3 (RESET2 clamp, 1206) from (125.3, 90.9) to (132.0, 90.5). It sat on the north exit
of the 16U2 and walled in pin 21 (PB7 of the 16U2, net 8PB7).

Command: `bt fan U4 --dogbone --via-size .6,.3 --width .2 -o items` then `bt apply --checked`.
Result: 18 nets fanned out (45 segments, 14 vias), probe clear.

Left for later:
- SCK2 (pin 15, east side): its stub would sit 0.14 mm from the MOSI2 stub; the router has to find
  its own way out. (Solved later, see 007.)
- +5V (pin 4), +5V (pin 32), GND (pins 3, 28): power pins with no via room.
