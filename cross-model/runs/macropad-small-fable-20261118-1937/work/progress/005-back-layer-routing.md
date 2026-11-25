# 005 – back layer routing (signals, LED chain, power)

- Crystal: XIN/XOUT run 6-8 mm east in the strip between the key rows to R105/Y101/C109/C113.
  First try ran XIN 0.02 mm inside the LED window cut-out of D201 (it is a board edge); the three
  caps beside the MCU were shifted 0.15 mm down and XIN/XOUT drawn 0.15 mm wide to clear it by 0.2+.
- Key fan-out at the MCU south side with 0.15 mm traces (the auto-router gave up at 0.2 mm):
  KEY4 straight to its socket pad, KEY5/KEY6 east on B.Cu under the SW501 socket, KEY1-3 to vias.
- LED supply: U105 (load switch) sits between D501 and D601. +5V_LED runs east above the bottom
  LEDs, up the right board edge and back west under the top LEDs (one loop, no crossings with the
  key traces); a short branch feeds D501. LED data chain D201→D301→D401→D701→D601→D501 all B.Cu,
  D601→D501 passes under U105 between its pin rows.
- +5V trunk 0.5 mm along the bottom edge from the fuse to U105 and the 10 uF bulk cap C101.
- Regulator U101 right beside the fuse; EN tied to VIN under the body.
Still open: front-layer hops (KEY1-3, +3V3, +5V to U102, LED_EN, BOOTSEL, U106 supply), all GND.
