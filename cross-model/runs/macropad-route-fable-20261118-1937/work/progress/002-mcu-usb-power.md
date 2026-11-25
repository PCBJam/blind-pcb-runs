# 002 – MCU corner, USB, power entry
Three hand-placed stages, each checked with `bt probe` and written with `bt apply --checked`:
1. QFN power: 3V3 ring on F.Cu inside the pad frame, five vias down to the B.Cu caps, five ground vias in the exposed pad, 1V1 from pins 45/50/23 to C116/C117/C115 with a B.Cu link along the top of the chip.
2. USB: D+/D- through the USBLC6 (flow-through under the body) to the 27R resistors and pins 46/47; CC resistors; VBUS from both connector pad pairs to the fuse (top pair by a B.Cu link); +5V to LDO/load switch/bulk cap; 3V3 trunk on B.Cu to the MCU caps and the flash.
3. QSPI on F.Cu with no vias, crystal, LED_EN/LED_DIN_3V3 on B.Cu to the load switch and level shifter.

Result: all clear in probe (two clearance misses of 0.01-0.02 mm fixed before applying). Left: keys, LED chain, LED power, ground.
