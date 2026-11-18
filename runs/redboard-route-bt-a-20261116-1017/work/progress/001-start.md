# 001 – starting point
Board as received: all 292 footprints placed, no copper. 4 layers, stackup F.Cu / 0.1 mm prepreg / In1 / 1.24 mm core / In2 / 0.1 mm prepreg / B.Cu.
Findings: the board outline lives inside the locked H1 footprint, which `bt` cannot read (it reported an infinite box, then every probe failed with "board edge gap -0.064"). Work-around: H1's nine Edge.Cuts lines are parked on User.5 and an identical board-level outline added while routing; this is reverted before delivery.
Plan: In1 = solid GND, In2 = GND under the high-speed B.Cu area (top-left) + 3.3V plane elsewhere, F/B signals. Net classes added (Power, USB 0.15/0.13 ≈ 90 Ω, MIPI 0.127/0.173 ≈ 100 Ω on the 0.1 mm prepreg).
