# 003 – ground vias, slow signals, power, first pour (one open)
Added (scripts/gen_misc.py, gen_power.py, each batch through `bt probe` then `bt apply --checked`):
ground vias at every J2 ground finger and between J1's ground pads, stitching between the F.Cu pair
lanes, PERST#/WAKE#/CLKREQ#, 3V3_AUX, the +5V track, cap stubs and pour vias. Then the zones:
In1 = GND, In2 = GND + 3V3 + 12V islands, F.Cu = 3V3 pour (left column, top, middle) / GND / 12V,
B.Cu = GND with local 3V3 and 12V pours.

Probe caught three mistakes before anything was written (0.4 mm stubs too close to NC fingers,
two vias clashing in the cap cluster).

Result: DRC clean but **1 unconnected**: the F.Cu pour of +3V3 fingers 70/72/74 was walled in by
the PERST# track and its via sitting exactly on the zone's lower edge (picture: bottom-left).
