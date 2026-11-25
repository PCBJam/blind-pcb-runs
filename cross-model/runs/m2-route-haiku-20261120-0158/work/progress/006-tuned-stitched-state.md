# 006 — lanes length-matched, GND stitched, board checked

- Length tuning (bt tune, bumps on the short leg): D3 IN (4.5 mm), D1 OUT (1.6 mm), D0 IN
  (0.8), REFCLK (0.75), D0 OUT (0.6), then D1 IN, D2 IN, D2 OUT, D3 OUT (0.3-0.4).
  Every pair is now within 0.003 mm of its partner. The D3 legs are 45 mm and 40 mm long,
  so the pair is 45 mm; the others are 31-34 mm.
- Stitching: 139 GND vias (bt stitch, pitch 3 mm, free positions only) between the GND
  pours and the In1/In2 planes.
- bt check: 0 DRC errors, 0 bt findings. 10 GND pads open (see NOTES.md).

Final numbers for this state: 199 vias (155 at 0.45/0.25, 44 at 0.6/0.3); 371 track
segments; copper length F.Cu 273 mm, B.Cu 405 mm, In1.Cu 211 mm, In2.Cu 70 mm; 4 zones.
Decap GND pads C5.2 and C6.2 got vias to the planes (they had been islands).
Open GND pads now: J2 pins 9, 21, 27, 33, 39, 45, 51; J1 A15; J1 A27+A28 (see NOTES.md).
