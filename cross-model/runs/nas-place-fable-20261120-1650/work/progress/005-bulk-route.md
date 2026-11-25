# 005 – bulk auto-route of the slow nets (partly thrown away)
`bt route --nets "*" --order escapes-first` on F.Cu/B.Cu, 33 minutes: 105 of 120 nets connected, 15 given up (long RP2040 nets timing out at 20 s a search, pins boxed in by earlier routes).
What was wrong with the result (visible in the picture, left edge and around the RP2040):
- ETH_LED1/2 were run down the LED column *between* each resistor and its LED, so every R–LED link became two vias and a back-side jumper; a +3V3 track ran under all 16 LEDs between their pads.
- A +12V branch for the two eFuse LEDs was cut diagonally through the +12P input pour and split it (jack/TVS on one side, eFuse input on the other).
- Thermistor and LED lines were laid 0.16–0.22 mm beside PCIe pairs for up to 30 mm.
All of that was ripped up again in step 006. Lesson: the router keeps only the class clearance, so sensitive areas need keep-out boxes before it runs.
