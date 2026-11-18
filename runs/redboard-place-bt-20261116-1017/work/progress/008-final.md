# 008 – final state
`008-final.png`: all layers. `008-final-in2.png`: the power layer alone (3.3V plane, 1.1V island, and the signal/power tracks that ended up on it).
KiCad DRC on the delivered file: 0 unconnected, 0 shorts/clearance errors, 0 schematic-parity issues; 10 `track_dangling` warnings (dead-end stubs the router left, 0.04–2.5 mm);
the 7 courtyard overlaps and 4 silk-edge warnings are between locked parts and were there at the start.
Last fixes before this: GND pours on F.Cu/B.Cu (islands removed), 5V_BAR pour under the LM1117 tab, 5V/3.3V_P re-routed at 0.4–0.5 mm (the batch had laid them at 0.15 mm),
jumper JP5 moved next to its header pin (it kept colliding with VIN/SD_CMD where its label is), via-in-pad for two stranded ground pads (J6.22, C40.2), dangling vias removed.
