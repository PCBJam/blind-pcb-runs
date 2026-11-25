# 012 — final DRC round, and a stale-fill catch

Ran KiCad's DRC on the saved file (`kicad-cli pcb drc`, not the bt check copy). It reported three clearance errors: the 0.3 mm LDO-output runs I had just widened sit 0.15-0.19 mm from the saved F.Cu GND fill, which was still the 0.2 mm version. `bt check` had said "fills were up to date" and CHECK OK at this point, which was wrong for the saved file.

Fix: `bt fill` (fills in place), then kicad-cli DRC again: 0 violations, 0 unconnected items, one warning (footprint U103 differs from the library copy; left as is, footprints are not to be changed). `bt check` now agrees.

Picture 012-final-drc.png is the finished board after the refill.
