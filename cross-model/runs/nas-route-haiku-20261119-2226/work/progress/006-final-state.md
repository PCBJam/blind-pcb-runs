# 006 – final state of this session (not finished)

Picture: `006-final-state.png` (full board: F.Cu red, B.Cu blue, In1 green, In2 amber).

**Where it stands**

- Routing: 2017 track segments (1553 F.Cu, 464 B.Cu), 599 vias, 9 zones (In1 GND plane, 8 In2 power zones).
- `bt check` on the saved board: 0 routing errors (no shorts, no crossing tracks, no clearance errors). 26 DRC errors, all from the original footprints (17 footprint-type mismatches, 9 courtyard overlaps). 13 nets still have open pieces.
- `bt same` against the original board: no locked part moved, nothing added or removed, no pad net changed.

**Open nets** (details in `/work/NOTES.md`): CM4_RUN (the CM4 left-block escape is packed), +3V3 (one link at the R8 pull-up), GND (4–5 pads), USBpico_DN and Net-(R60-Pad2) (RP2040 USB D- end), +1V2 (U12.64), +3.3VA (the switch's power pins), +3.3V_M1 (R20 pull-up), Net-(J7-PadA7), PICO_PWM1, TSENSE_2 (unrouted: the routed version shorted PICO_LED_3, so I removed it), Net-(C10-Pad2), Net-(R24-Pad2).

**What changed since 005**

- The bulk-pass leftovers were retried in several ways: `--all` per net, `--rip --move-board` with only the affected group movable (CM4, RP2040), and single pad routes. SD_CMD, LED_V+, TSENSE_0/3, USB_DP/DN, M2PWR_EN and the J7 A6 side connected. CM4_RUN, PICO_PWM1 and the USB D- pads did not.
- +3V3: the Power class clearance went from 0.2 to 0.15 mm (the 0.2 mm rule blocked a path that passed 0.17 mm from an unconnected CM4 pad), then the CM4 pins 78/84 were joined through the gap between the module's two columns.
- SCL_CM4 and SDA_CM4 had been removed to make room for +3V3; they were re-routed afterwards.
- A board-wide dangling-stub cleanup (`bt cleanup --stub 0.3`, 47 segments tidied, probed) and an IMON stub cleanup.
- TSENSE_2: the routed version shorted PICO_LED_3 and crossed PICO_LED_2 and TSENSE_0 near (209, 133). Removed; the net is open.

**What I would do next** (in order): plan the RP2040 fan-out for the LED, tacho, QSPI and USB nets before routing them; re-plan the CM4 left-block east column (pins 88–100) with `bt escape`; move the buck feedback tracks off the GND pads near R6, R35 and R32; add a second via to each 3.3 V rail's necked pads; then the length matching and the `bt check` clean-up.
