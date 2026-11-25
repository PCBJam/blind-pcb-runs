# 001 — planes set up, BGA zoom

Net classes set in the .kicad_pro (dry run first): Default clearance 0.1499 -> 0.15, via 0.6/0.3 -> 0.45/0.2;
Power clearance 0.15, track 0.25, via 0.6/0.3 -> 0.5/0.25.

Planes: In1.Cu = GND, a full pour inset 0.3 mm from the outline (rounded rectangle, r 3.7).
In2.Cu = +3V3, as four overlapping boxes that leave a window under the BGA
(x 78.0-89.6, y 89.6-101.6). The window is left free so the BGA's interior balls can escape on In2.
Why a window: the back-side caps sit under the balls, so B.Cu alone cannot carry the interior
balls, and an unbroken In2 plane would leave them no channel at all.
