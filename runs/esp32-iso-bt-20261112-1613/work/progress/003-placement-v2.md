# 003 – placement v2 (PHY moved)
Change of plan. `bt congestion` listed the LAN8710A pins on the two sides facing the strip edges as "one way out" at x=90.2 / 97.1 –
i.e. into the board edge and into the isolation band. A 5 mm QFN cannot be escaped inside the 6.5 mm strip left of the barrier.
- PHY moved to the bottom side between the header rows (97.9,136), pair pins facing south. The two Ethernet pairs can now run on
  B.Cu only, from the PHY pins under the USB connector (between its shell legs) down the left strip into the jack "finger" – no vias.
- Buttons and the LiPo charger moved to the now free left strip (charger next to the battery connector).
- USB-UART chip stays on the back next to the USB connector; auto-reset transistors on the back, east half.
- KiCad DRC after placement: only the pre-existing kind of issue remains – ESP32 pads inside the 1.55 mm keep-out of mounting
  holes MH2/MH3 (the module cannot move up because its thermal vias must clear the microSD pads on the back).
