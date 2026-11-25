# 003 – BGA breakouts (scripted) and first DDR lanes

What: wrote small generators (/tmp scripts) for the ECP5 and DDR3 breakouts and checked every
item with `bt probe` before applying.
- ECP5 (0.5 mm pitch): rows A/B leave on F.Cu between the balls (0.09 mm track, one per gap),
  inner balls use the depopulated row E / column 5 / column 14 sites or 0.28/0.15 interstitial vias.
- DDR3 (0.8 mm): column 8/7 pads reached from the west through the row gaps on F.Cu, column 3 pads
  dog-boned into the centre channel, column 2 pads to interstitial vias, power balls to row-aligned
  vias outside columns 9 and 1 so that two In2 lanes still fit between vias.
- Address/control and data nets whose RAM pad is on the FPGA side run on F.Cu only (no vias);
  the rest go F.Cu -> via at the FPGA edge -> In2 -> via in the RAM channel.

Failed attempt kept in mind: the first try used `bt fan` (a via per ball incl. every GND ball) and
`bt route --nets` for the In2 group; the router took straight lines at the source height and left
no room for the second lane in each RAM row gap, so I laid the In2 lanes out explicitly instead.
