# 013 outline set, final checks

- Outline set by hand: left block x 89.55..117, y 97.35..133 (the top and left edges from `bt outline --fit`, the bottom at 133 so the USB-C front face sits on the edge); key area x 117..176.15, y 100..138.1 untouched.
- The `--fit` box itself was rejected: it would have cut the key area (right edge 174.65, bottom 136.05). Not used as written.
- The GND zone was replaced with the new outline (`bt zone --replace`) and refilled; the old outline had caused a copper-to-edge error.
- Checks: `bt check` CHECK OK (0 DRC errors, 2 warnings, 0 unconnected); kicad-cli DRC on the saved file: 0 errors, 2 warnings, 0 unconnected, 0 schematic-parity issues. `bt same` against the original: no locked part moved, no part added or removed, no pad net changed.
- Area: block ~27.5 x 35.7 mm plus the key area 59 x 38 mm, about 3230 mm2 against about 3070 mm2 for the original outline. The board is slightly larger than the original, not smaller. See NOTES.md for why.
