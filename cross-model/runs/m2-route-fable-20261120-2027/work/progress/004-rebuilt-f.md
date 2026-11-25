# 004 – corner reworked, plane voids, reproducible build
Fix for 003: moved the PERST# and WAKE# vias up and left (PERST# via first, WAKE# passing under it
on F.Cu and above it on B.Cu), which leaves a ≥1 mm F.Cu corridor from fingers 70–74 round the
WAKE# via into the main +3V3 pour.

Also added rule areas (scripts/add_voids.py, pcbnew, because bt cannot make keepouts) that keep
the adjacent plane out from under the high-speed pads: In1 under J1's PET pads, In2 under J1's PER
pads and under the J2 finger row. 004-in2.png shows In2 with the voids and the power islands.

Everything now rebuilds from the unrouted board with scripts/build.sh.
Result: `bt check` → CHECK OK, 0 errors, 0 unconnected.
