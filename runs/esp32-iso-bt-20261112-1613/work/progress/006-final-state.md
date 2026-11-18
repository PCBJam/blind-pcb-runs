# 006 – state at hand-over (NOT finished)
Zones poured (GND on F/In1/B and the south part of In2, +3.3V on the north part of In2, Earth on all four layers inside the
inner isolation line, antenna keep-out), 55 stitching vias from my own generator, shield and Earth-neck tracks by hand.
KiCad DRC at this point: 33 errors (29 mounting-hole keep-out, of which 8 are ESP32 pads that cannot be avoided; 2 fiducial
clearance; 2 mask bridges) and 48 unconnected items in 21 nets. See NOTES.md for the list. Pictures: all layers, top, bottom, In2.
