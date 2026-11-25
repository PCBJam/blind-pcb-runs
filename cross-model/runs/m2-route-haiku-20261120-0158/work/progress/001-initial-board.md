# 001 — starting point (no copper, placement as given)

What I looked at: the placement as delivered (fixed), the netlist, the stackup
(F.Cu / 0.12 prepreg / In1.Cu / 0.51 core / In2.Cu / 0.12 prepreg / B.Cu, 0.876 mm),
and the project rules (Z85_PCIE class for the 8 PCIe pairs: 0.185 mm track, 0.145 mm gap).

Key facts from the layout:
- J2 is the M.2 M-key fingers on the left edge (x 106.2). All PCIe lane pins are on the
  B side (odd pins, x 107.65); the even pins are F side (3V3, PERST#, CLKREQ#, WAKE#, NC).
- J1 is the PCIe x4 socket hanging off the bottom edge. Its A row (IN lanes, GND, 12V,
  3V3 ...) is on B.Cu, its B row (OUT lanes, GND, 12V ...) on F.Cu, both at 1.0 mm pitch,
  pads 0.7 x 4.2 mm, reached only from the north (y < 116.7).
- Both connectors list the lanes in the same order (D3, D2, D1, D0, REFCLK, top to bottom
  on J2; west to east on J1). Left-edge-to-bottom-edge with the same order means the lanes
  must cross each other: no single layer can carry them.
- All passives (decoupling, 0R jumpers) are on the B side above the socket's right half.

`bt planar` said the IN group is not planar on one layer (24 crossing pairs) and says two
IN pairs (D2, D3) are planar. A B.Cu-only test routing of those two pairs failed (the second
is walled in by the first), so that "planar" answer is wrong for this pad geometry.
