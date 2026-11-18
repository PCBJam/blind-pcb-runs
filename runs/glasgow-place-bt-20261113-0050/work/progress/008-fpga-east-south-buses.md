# 008 – buses on the FPGA's east and south sides (QA/QB, DA/DB, port-B X, AUX)

What failed first (all thrown away):
- `bt route --nets` / `bt bus` / per-net `bt route` for QB, DA, DB: 10/24 at best; the router never placed a via in these runs and the
  corridor between the BGA and the first level shifter only fits ~3 tracks per layer.
- Several hand lane plans with the series arrays where they were (north of port B): the DA (north-bound) and QB (east-bound) bundles have to
  cross in that corridor and the ball order is a different permutation from the buffer order.
What worked: moved the port-B series arrays RN1/RN2 directly under the FPGA's south edge, so QB is 2 mm long and the 33 R sits at the FPGA
(source end); their X outputs run as an ordered F.Cu bundle round the corner to the buffers. DA leaves as a via staircase (F.Cu stub = row, B.Cu = lane),
runs east under the QA rows and goes up between the buffers to the DIR vias; DB uses a second staircase to a B.Cu band south of port B.
Three more short In2 hops were needed (DB0, and the two SYNC-buffer nets that must cross this bundle). PLL1 filter (C79 at the balls, R32/C80 just north).
Result: all 40 nets connected, DRC shows no clearance/short errors (`tools/east.py`, `tools/fanout.py`).
