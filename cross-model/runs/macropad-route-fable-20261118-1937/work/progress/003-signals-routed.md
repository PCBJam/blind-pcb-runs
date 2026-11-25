# 003 – keys, LED power and LED data
- Keys: six lanes fan out of the QFN top row on F.Cu, each drops through one via east of the chip, then runs on B.Cu to its socket pad (KEY1-3 along the top, KEY4-6 down the x≈119 channel and along the corridor between the rows). The via positions do the reordering the pin order would otherwise force as crossings.
- First try put the KEY4-6 vias at (119.8,105.6): 0.09 mm from SW201's pad, and KEY6's first bend 0.165 mm from pin 30. Probe caught both; cluster moved 0.3 mm north.
- +5V_LED: F.Cu from the load switch along the bottom of the MCU section; one via at (116.9,124.2) feeds the bottom row on B.Cu, one at (124.5,117.4) feeds the top-row trunk on B.Cu. Each LED's 100 nF sits on the spur between trunk and LED pad.
- LED data: DIN on F.Cu to a via beside D201, chain links on B.Cu round the caps.
Result: only GND left in the ratsnest.
