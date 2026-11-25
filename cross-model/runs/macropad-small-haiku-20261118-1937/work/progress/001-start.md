# 001 start: the board as received

Rendered before any change (`bt render`).

- All 42 unlocked parts sit below the board outline (y > 138), off the copper.
- Locked: the 6 MX hot-swap switches (SW201..SW701) and their 6 reverse-mount SK6812 LEDs (D201..D701).
- Outline: rounded rectangle 87..176.15 x 100..138.1 with a bottom-left notch (x < 117, y > 127.3).
- Key area (x 119..176.15, y 100..138.1) is the part that must stay inside the board.

Note for later: the switch footprints carry no 14 mm cutout in Edge.Cuts (only Dwgs.User corner marks). The six "cutouts" bt counts are the LED light holes in the LED footprints. I did not add switch cutouts (see NOTES.md).
