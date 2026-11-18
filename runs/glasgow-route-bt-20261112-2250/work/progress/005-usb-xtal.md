# 005 – USB, crystal, CC, VBUS, LED strings (left edge)
- `bt route` on USB_P/N gave a connected but untidy result (long B.Cu detour for D-, tracks wandering under the receptacle), discarded.
- Kept: hand-written USB pair. The two D+ pads are joined under the receptacle through TP15 (B.Cu), the two D- pads through TP16;
  the pair then runs side by side on F.Cu over solid In1 GND, *through* the TPD3S014 pads (flow-through ESD), into FX2 pins 8/9. 0.2 mm tracks.
- Crystal, CC resistors, VBUS, VUSB, LED–resistor links routed on F.Cu only, no vias (bt route; VUSB by hand because bt reported the
  start "boxed in" although a 0.2 mm lane existed between U15's pad columns).
