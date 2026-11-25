# 007 – ground: vias at every ground pad, pours on both layers, stitching

- `bt escape` placed a stub + via at 20 of 25 SMD ground pads in one call. It found no spot for
  C18.2, U6.2, U7.4, U3.62 and U3.81; I placed those by hand (U3.62 had free spots 1.7 mm from
  the pad that the tool did not offer). Two earlier +5V B.Cu segments had to move 0.3–0.8 mm to
  make room (the bar under the MCU's north row and the spine past U6).
- Four vias in the 16U2's exposed pad, pairs at U1.1 / C1 / C2 grounds, one on the resonator's
  ground track.
- GND pours on F.Cu and B.Cu (0.25 mm clearance, thermal reliefs on through-hole pads only,
  islands removed). Picture: the first B.Cu fill — one piece, with slots where the ADC bus, the
  UART/I2C runs and the +5V trunks go.
- DRC round 1: 4 new errors, all "starved thermal" on header ground pins (J6.4, J2.6, J12.6)
  boxed in by neighbouring pads and tracks. Fixes: AREF re-routed so it no longer passes J6.4
  (C5 now has its own via); thermal gap/spoke reduced to 0.3/0.45 mm; J12.6 got a small
  solid-connected F.Cu patch tied to B.Cu by a via.
- Failed step: `bt zone --delete --at x,y` and `--replace --at x,y`, aimed at the small patch,
  both also removed the main F.Cu pour (92 "dangling via" warnings showed it). Re-created the pour
  each time.
- Stitching: `bt stitch --pitch 3` proposed 106 vias on a plain grid; I dropped the ones under
  the crystal and right beside SMD pads and added one inside the MCU footprint: 94 applied.
  (F.Cu islands were set to "keep" for that call so pockets between the lanes could be tied down,
  then back to "remove".)
