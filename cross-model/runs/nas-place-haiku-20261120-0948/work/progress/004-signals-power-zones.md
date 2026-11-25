# 004 Signals routed, M.2 3.3V zones, +12V bottom zone, ground planes filled

**Done in this step**
- Signal routing with `bt route --nets` (background, one net at a time): CM4 control, I2C, SD card, UART, Pico/fan
  nets, TSENSE, QSPI, USB (CM4 D+/D- via L7 to J7; RP2040 D+/D- to J15), CLKREQ pulls and LED nets. Each batch was
  applied with `bt apply --checked`, so nothing was written where a clearance was broken; batches that conflicted
  were routed again on the board as it then stood.
- RP2040 decoupling capacitors moved to the bottom side (they boxed in the pins; this freed the front-side exits).
- Ethernet: 8/8 pairs (escape vias on the CM4 pins, routing on the bottom side).
- Flash U17 moved to (212,108) to clear the south-east lane path of PCIe port 4.
- +12V: a bottom-side zone over the converter band (x 112-226, y 73-98) with a via from the DC input output
  (U3 pin 10). The zone is cut into several pieces by existing bottom-side copper; those pieces still need joining.
- M.2 +3.3V_M1..M4: a front-side zone under each slot's lower row of 3.3V pins, with a finger reaching
  the converter. Each converter inductor's output pad (L3..L6 pin 2) is joined to a point in that finger by a
  short bottom-side track and one via (8-9 mm each).
- Ground: In1.Cu and In2.Cu are both GND, filled.

**Still open at the time of writing**
- GND pads: superseded. `bt route --net GND --all` was stopped (it makes pad-to-pad tracks); the ground pads were
  done with `bt escape` (see 005).
- +3V3, +3.3VSTB, +5V, +1V8, +3.3VA, +1V2, +12P: not yet connected (see NOTES when done).
- Many 2-pin `Net-(...)` nets (converter SW / feedback, LED resistors): not routed yet.
