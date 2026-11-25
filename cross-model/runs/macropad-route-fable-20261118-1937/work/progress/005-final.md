# 005 – final state
Quality pass after the first clean DRC:
- Moved one 3V3 via (pin 1 → C114) 0.1 mm so its hole no longer sits inside the capacitor pad's mask opening.
- Looked at `bt cleanup`'s proposal and did not apply it: it wanted to add 0.0005 mm segments at two vias and move the USB jogs right against the pads.
- Final checks: `bt check` OK (0 errors, 0 unconnected, fills up to date); `kicad-cli pcb drc --severity-all --schematic-parity`: 0 unconnected, 0 parity issues, 1 warning (U103 footprint differs from the library copy; the unrouted board had it too); `bt same`: no part moved, added or removed.
Totals: 399 track segments, 128 vias (114 × 0.6/0.3, 10 × 0.5/0.3, 4 × 0.8/0.4), two GND zones.
