# 001 – starting point
Board as received: 292 footprints placed, no copper. Surveyed nets with `bt board`.
Found the outline lives inside footprint H1; `bt` treats that as "no outline" (everything inside reads as a board-edge violation),
so I work on a copy where the 9 Edge.Cuts lines are board-level graphics (`scripts/edge.py to_work`) and put them back at the end (`to_final`, byte-identical round trip tested).
Added net classes (Power 0.4, USB 0.14/0.15 ≈ 90 Ω, MIPI 0.127/0.2 ≈ 100 Ω over the 0.1 mm prepreg to In1).
