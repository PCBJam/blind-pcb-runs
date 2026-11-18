# 004 – stitching, first DRC round
`bt stitch` for +12V (F<->B) and GND. The GND run also dropped vias through the +12V and +3V3 pours
(they do land on the inner GND planes, but they only perforate the power copper) -> removed 39 of 69.
DRC then showed 3 real errors:
- a stitch via touching the copper text "M.2 PCIe x4 adapter" on B.Cu (bt does not see gr_text copper) -> removed;
- the 4.2 mm solder-mask opening at the right edge (the M.2 mounting-screw land) exposed GND on top
  and +12V on the bottom. That would have put +12V under the screw head. Pulled the +12V pours back
  >3 mm from the land, so it is GND on both sides, and stitched it.
Also 17 silkscreen warnings from reference designators on pads.
