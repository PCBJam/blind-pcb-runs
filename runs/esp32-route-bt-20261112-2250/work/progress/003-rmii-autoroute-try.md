# 003 – RMII trial with `bt route --nets` (thrown away)

Let `bt route --nets ... --prefer F.Cu --max-vias 2` route the nine RMII nets unguided. 7/9 connected in ~4 min;
TX_EN and RXD0 ended boxed in at the PHY. The result drops vias right at the ESP32 pads and runs the 50 MHz clock
and MDIO for 35 mm on B over the 3.3 V plane, and the PHY escapes block each other. Not kept.
Next: same nets, fixed order (clock first), vias forbidden north of y=127 so they stay on F over the solid GND
plane, one via each next to the PHY.
