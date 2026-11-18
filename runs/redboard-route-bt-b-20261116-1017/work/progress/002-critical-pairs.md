# 002 – MIPI and USB-HS pairs first
Worked out by hand that the U1 pinout vs. the J5/J6 staggered FPC pads cannot be routed planar:
- DSI: CLK (west channel) and D1 (round the east side of J6) stay on F.Cu over the In1 ground; D0 has to cross CLK, so it drops through vias in the ring between U1's pin row and its EPAD and runs on B.Cu to two vias between the J6 pad columns.
- CSI: D1 and D0 on F.Cu (through the gaps between the 0402s north of U1); CLK must cross D1 to reach R24/R25, so it goes via ring vias on B.Cu. The CSI REXT pin also hops on B.Cu to free the gap for D1.
- USB HS: ring vias, B.Cu trunk, stub vias into the TVS D2 (F link pad-to-pad), staggered via column at J11.
`bt pair` could not start from 0.35 mm-pitch pins (it adds the pair gap as extra clearance), so the pairs are drawn from centre lines with my own offset helper and checked with `bt apply --checked`.
Skew still to tune (DSI CLK/D1 ~3.6 mm because of the staggered connector pads).
