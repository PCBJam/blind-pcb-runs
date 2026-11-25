# 003 – PCIe pairs routed (hand-generated geometry)
All 15 differential pairs (CM4 <-> switch, switch <-> 4 sockets) are in, from `scripts/cells.py` (socket entry) and `scripts/pairs.py` (long runs).
- Top layer over the solid In1 ground plane for every long run; 0.2/0.2 mm pairs.
- The switch pinout puts each port's clock on the wrong side of its data pairs and the data pairs P/N-mirrored against the socket. Solved once in a repeated "socket cell": RX/TX dive to the back just south of the socket and swap P/N at their up-vias between the pad rows (equal length by construction); the clock stays on top, crosses over them and enters through the M-key notch. TX coupling caps sit in the back-layer lanes of the cell.
- CM4 side: clock dives under the H10 standoff pad; CM4-TX hops under the CM4-RX pair once.
- First attempt with `bt pair` for the long runs was thrown away: the two halves took different paths (not a coupled pair). `bt tune` then removed the 0.6–1.3 mm skews.
Result: 0 unconnected PCIe nets, probes clean.
