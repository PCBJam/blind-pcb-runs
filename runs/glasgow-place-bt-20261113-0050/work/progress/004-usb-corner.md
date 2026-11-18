# 004 – USB corner routed by hand

D+/D- run straight from the A6/A7 pads into FX2 pins 8/9 (3.5 mm, F.Cu). B7 is looped to A7 round the pad ends, B6 joins D+ through one via.
U15 (TPD3S014) sits on the back right under the pair with one small via per line as ESD tap; TP15/TP16 hang on those back stubs.
CC resistors sit on top and return their GND straight into FX2 AGND/GND pins. VBUS: both pad pairs -> vias -> back -> FB1 -> U15.
Also lowered the Default net-class clearance from 0.15 to 0.125 mm (needed to pass one track between 0.4 mm vias under the 0.8 mm BGA).
Result: probe clean (58 items).
