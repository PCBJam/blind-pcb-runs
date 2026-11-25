# 007 — last try on the PCIe ground pads A27/A28 and A15 (rolled back)

Picture: the J1 landing row, x 113-137, y 108-121, final board.

What I tried: moving the OUT P landing via 0.7 mm up (to y 115.2) so that a ground via
could sit at (119.75, 116.3) between the OUT N and OUT P landings, with B.Cu stubs to A28 and
A27. The probe found the new OUT P F-stub runs through that spot (gap -0.17 mm), so the via
was refused. The OUT P leg was restored to its previous route.

Result: unchanged. A27/A28 (one piece) and A15 stay open. A15 has no legal via site within
2 mm (the probe checks around 132.7 and 131.7 fail against the landing vias of OUT N and REF N).

Lesson: the landing row is full. A ground connection there needs the landing vias moved
(a re-layout of the last four landings), not a single via.
