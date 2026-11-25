# 006 USB, VBUS, +5V and +3V3 routed

Routed with `bt route` (one net at a time, `-o` items file, then `bt apply`):
- /USB_D+ and /USB_D- on B.Cu from the series resistors to both connector pads of each polarity. D- needs two vias (ESD pin 6 is on the far side). The D- pad on the connector's back row is reached around the row.
- CC1/CC2 from the pull-down resistors to the connector's CC pads (CC2 had two vias).
- VBUS: the connector's VBUS pads tied by a short F.Cu bridge across the back row (two vias), then to the fuse.
- +5V: fuse out to the LDO input/enable, the load switch input, the ESD VBUS pin and the bulk cap. One segment necks to 0.127 mm on the ESD VBUS pin, which is boxed in; ESD VBUS draws only leakage.
- +3V3: all 22 links routed. Nine segments neck to 0.127 mm at MCU pins that are boxed in (usual fab minimum).

Render shows the RP2040 bottom still crowded: the +3V3 stubs there block USB D+ (see 007).
