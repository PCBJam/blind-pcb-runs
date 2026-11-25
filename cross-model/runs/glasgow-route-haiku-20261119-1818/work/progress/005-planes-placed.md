# 005 — GND and +3V3 plane vias for the whole board (kept)

`bt plane --net GND --layer In1.Cu --via-size .45,.2`: 193 of 209 GND pads got a via to In1 (the rest
already sit on GND copper nearby and need a short join). `bt plane --net +3V3 --layer In2.Cu`: 90 of 99
pads got a via into the In2 frame. Left after this: GND 8 pieces, +3V3 7, signal nets, VIOA/VIOB,
+5V, VUSB, VIO_AUX, +1V2.
Why planes before signals: the plane tool keeps fine-pitch pins' escape lanes free, and it is the only
way to place ~190 GND vias before the signal tracks take every spot next to a cap.
Side effect found later: GND vias placed beside U1 blocked the USB corridor (see 007).
