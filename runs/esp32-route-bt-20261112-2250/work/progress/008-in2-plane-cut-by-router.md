# 008 – inner layer used as overflow by the router: +3.3 V plane cut (reverted)

To get the last ~20 long GPIO nets connected I allowed `bt route` to use In2 as a third layer (without shove).
It took the offer generously: ~450 mm of signal tracks on In2 (GPIO16 60 mm, GPI39 40 mm, GPIO3 40 mm …).
After the fill `bt ratsnest` reported the +3.3 V net in 11 pieces: tracks that close loops leave dead islands
(SD-card supply, UEXT pull-ups) and one track runs from EXT1 pin 5 right across the neck between the regulator
(L2/C22) and the rest of the plane – the ESP32 would have had no supply. Picture: In2 at that point.
Fix: all signal tracks stripped from In2 again; each open link is then retried and kept only if the +3.3 V and GND
plane group counts do not get worse (script loops `bt route` → `bt fill` on a copy → `bt ratsnest`).
