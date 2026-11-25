# 003 PCIe lanes to the M.2 slots and the ASM1184; Ethernet escape

**Problem:** the M.2 upper-row PCIe pins (0.5 mm pitch, 0.3 mm pads) and the ASM1184 pins (0.5 mm pitch) cannot be
escaped by a 0.4 mm track: the neighbour lanes at 0.5 mm pitch leave room for 0.2 mm only. The first routing
attempts (plain bt route / bt pair) boxed in the second line of each pair, and the router's greedy order put lanes in
the wrong nesting (a lower pin's lane crossing the exits of the upper pins).

**What worked:**
- ASM1184 decoupling and straps moved to the bottom side; AC-coupling caps moved 3-6 mm out along their lanes
  (C48/C49 south, C58/C59 south-east, C56/C57 north of the ASM, then to the bottom side at the J4 escape).
  Flash U17 moved out of the lane path (212,108).
- M.2 upper-row PCIe pins fanned out with `bt escape` (stub + via per pin, vias staggered between y 56.6 and 59.6, i.e.
  between the pad row and the connector's inner channel). Done for J4 and J5 (ports 3, 4). J2 and J3 were routed direct.
- Lanes then routed from the escape vias with `bt route --batch` (one request per net, `through` = the nested corner
  points, lowest ASM pin's lane turning north furthest west), and the two clock lanes last with `--move-board --shove`
  limited to port-3 nets (`--fixed` for everything else).
- Upstream (CM4 PCIe pins at x=126.7 -> ASM south/west pins) routed TX first, then RX (RX has to cross under TX via
  a layer change), CLK via the west side.

**Result:** every PCIe lane is connected (ports 1-4, upstream, the AC caps). The lanes are NECKED to 0.2 mm where they
pass the 0.5 mm pitch pin rows and, because the router uses the neck width for a whole run, for much of their length
(see NOTES). Port 4 and the upstream lanes are long (60-90 mm) because they go round the ASM.

**Ethernet:** the CM4 ETH pins (0.4 mm pitch) got `bt escape` vias (one per pin, staggered), the ESD parts U8/U9
moved to the bottom side and turned 0 deg (their long axis across the lanes: pins 1-5 and 6-10 on opposite edges),
and the eight pairs were routed on the bottom side from those vias. 8/8 connected.

**Picture:** 003-pcie-escape-eth.png shows the stage after ports 1 and 2 were routed (before ports 3 and 4 and before
the ground vias): the lanes come down the corridors between the M.2 pin fields, the port 1 and 2 lanes are on F and B.
