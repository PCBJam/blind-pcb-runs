# 011 – Power, ground, clean-up, final state (pictures: 011-final-outer / -In1 / -In2)
- In2 islands reshaped twice: the first shapes left the 3V3 areas between the VIO islands and the 5V strip without a way in, and my own
  In2 signal hops (AUX, DA0) had sealed off the 3V3 under the bank-A shifters. Fixed by pulling island edges back, plus three short 3V3 links.
- LDO output → sense resistor → bank rail: the router had drawn these as 0.15 mm tracks with 10–40 mm detours. Redone: via in the overlapping
  pads (U14.5/R7, U31.5/R56), 0.5–0.6 mm B.Cu between the sense resistors, 0.4 mm trunk into the island.
- GND: `bt plane` gave 171 of 209 pads their own In1 via; the rest by in-pad vias placed after `bt probe`, GND pours on F.Cu and B.Cu, 124 stitching vias.
- Failures in this stage (all found by checking, all repaired):
  * I applied a +5V segment that `bt probe` had flagged as crossing SDA (my command chain did not stop on the BAD) – removed.
  * `bt stitch` + `bt fill`: two stitching vias came back as +3V3 next to GND header pins (free vias take the net of the zone they sit in) – removed.
  * `bt route --shove` had moved seven pieces of other nets onto In1/In2 although only F.Cu,B.Cu were allowed – removed and re-routed on the outer layers.
- Result: KiCad DRC (kicad-cli, zones refilled, all severities): 0 unconnected, no violation that is not already in the unrouted original
  (library/silkscreen/courtyard warnings). `bt same`: no footprint moved.
