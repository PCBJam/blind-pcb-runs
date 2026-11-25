# 001 – starting point
Board as received: 54 parts placed, no copper. Read the netlist with `bt board`, rendered the whole board and the MCU corner.

Floorplan decided here (before any copper):
- Key field (x > 120): every pad is on B.Cu (hot-swap sockets, reverse-mount LEDs, their caps), F.Cu has only NPTH holes. So F.Cu becomes the unbroken ground plane there and all key/LED routing stays on B.Cu.
- MCU corner: parts on F.Cu, decoupling caps on B.Cu under the QFN. 3V3 pins are tied by a ring track on F.Cu inside the pad frame, each cap group gets its own via, so B.Cu ground can still get in between the cap groups to the exposed pad.
- Net classes added: Power (5 V nets, 0.5 mm, 0.8/0.4 via), Supply (3V3/1V1, 0.3 mm), USB.
