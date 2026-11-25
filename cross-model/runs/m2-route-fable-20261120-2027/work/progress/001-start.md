# 001 – starting point
Board as received: all 20 footprints placed, no tracks, vias or zones. Stackup read from the file:
0.876 mm, F/B 18 µm over 0.12 mm prepreg to In1/In2 (35 µm), 0.51 mm core. Net class Z85_PCIE
(0.185/0.145) is the 85 Ω pair geometry for that 0.12 mm prepreg, so pairs belong on F.Cu/B.Cu
with the inner layers as their reference planes.

Finding: the pin order of the 9 pairs at J2 (top→bottom) is exactly reversed at J1 (left→right),
and P/N inside each pair is reversed too. No single-layer route exists; every pair needs a layer
change that also swaps P/N.
