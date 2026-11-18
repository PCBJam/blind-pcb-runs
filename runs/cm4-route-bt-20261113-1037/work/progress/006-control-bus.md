# 006 – SD bus, RP2040↔CM4 control bus (hand-routed after two failed autoroute attempts)
Failed: (a) `bt route --nets` on all remaining long nets ran 10 min in shove/rip passes and was killed without output;
(b) per-net autoroute of the SD bus boxed in CM4 pins (SD_DAT1, RUN/RST could not escape) and gave 4-via paths for control nets; ripped up.
Now: SD CLK/CMD/DAT0/DAT1/DAT2 run on F.Cu between the two CM4 pin columns and into the socket in pad order (DAT2 from below); only DAT3 uses B.Cu.
RUN/RST/BOOT/EN/UART run as a 6-lane bus on F.Cu along the bottom edge (y 137–138.8) to the RP2040; BOOT/EN/UART hop to B.Cu only at the CM4 end.
