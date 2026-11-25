# 005 - Power rails, DDR3 supply, ground vias: state after the first full pass

**Rails (bt route --all, layers In4/F/B/In2, 0.3 mm, vias 0.28/0.15, avoid the FPGA microvias):**
- P1.1V 15 of 18 links, P3.3V 29 of 31, P1.35V 13 of 18, P2.5V 5 of 9. Failures are the pads boxed in by the
  B.Cu decoupling and the fan tracks (e.g. U9.18, a P2.5V pad between P1.1V and P1.35V pads on the back, boxed in).
- RAM_VDD 14 of 14, RAM_VDDQ 15 of 15 (after the DDR3 ground and power vias, see 003).

**Ground:**
- `bt plane --net GND --layer In3.Cu --ref "C.*|R.*|L.*|FB.*|TP.*|D.*|OSC1|U1|U2|U5|U6|U7|U9|U10|J.*|SW1|FID.*"
  --via-size .28,.15`: 86 of 117 small-part ground pads got a stub and via to the In3 GND zone. The other 27 have no spot
  (the charger and SD card side is congested). `--ref` takes a regular expression, not a glob list (the glob list gave 0/0 silently).
- The 126 FPGA ground balls are on microvias F.Cu->In1.Cu (see 002).
- `bt islands --net GND --fix`: 2 joins added; 14 pieces stay boxed in (mostly B.Cu decoupling ground pads under the FPGA).

**Power-in:** VSYS, VBATT and PUSB_VBUS: the charger and regulator pads are boxed in by the tracks already there.
Tried a 0.5 mm route first: 'the start is boxed in'. Not done; planned zones on F.Cu (the pads are all on F.Cu).

**Picture:** `005-power-and-ground-state-in4.png` (In4 teal: the FPGA power network and the DDR3/power tracks).
