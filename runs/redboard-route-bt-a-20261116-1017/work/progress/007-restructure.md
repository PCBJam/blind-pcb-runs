# 007 – restructured escape, ordered re-route
After ripping the failed batch:
- Flash Q/WP moved from B.Cu to In2 (0.15 mm, 8 mm) so the east side of U1 is open on B.Cu.
- Right side of U1: pins 1–8 and IO0 now fan out on F.Cu as a 0.3 mm-pitch bus south of the SDIO bus, ending in a diagonal via row ordered like the header pins, so the B.Cu legs to J10/J9 run north side by side without crossing. IO11 passes north of C19; only POCI/SCK/LED/CAM_IO keep ring vias.
- ADC pins: ring/pocket vias re-assigned so the six lines leave the chip in header order.
- Lesson: one stray `bt route` process (killed shell, node child survived) rewrote the board from its own memory and undid a rip; killed it and repeated the rip.
Then `bt route --passes 1 --order given --max-detour` group by group (no shoving). Result in the next entry.
