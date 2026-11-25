# 013 – final state of the power layer (In2)

Picture of In2 only, as delivered: the +3V3 plane with the VIOA island (north-east comb), the VIOB island
(south-east comb), +1V2 (FX2/FPGA south-west), +5V strip along the south edge, the ground island under
the USB connector and crystal, and the small ground island under the bank-B connector.

Also visible are the five tracks that had to go on this layer (brown lines): `~ALERT` under the FX2's top
pin row and up at x = 66, `CLKREF` and `~CY_RESET` in the FX2–FPGA channel, the SYNC direction line and
the +1V2 feed for R32 east of the FPGA. They are the weakest point of this layout – see NOTES.md §4.

Footprint check at the end: position, rotation and side of 264 of the 265 named footprints compared
against the part listings printed at the very start of the job – all identical (the remaining one was
never listed; the seven graphic `REF**` footprints cannot be told apart by name).
