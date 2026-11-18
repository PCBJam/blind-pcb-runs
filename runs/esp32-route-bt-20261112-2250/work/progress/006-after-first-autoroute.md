# 006 – after the first bulk autoroute

`bt route --nets "*" --passes 3` (F/B only) ran 30 minutes and had to be stopped: pass 1 connected 35 of 59 nets in
10 minutes, passes 2/3 took 1–3 minutes per net. Because `--nets` only writes its result at the end, the stopped
run left nothing; a second run with `--passes 1 --seconds 6` reproduced the 36 good nets in 3 minutes.
Kept: the 36 fully connected nets (short local nets, SD card, LEDs, +5VP, USB shell, VBAT).
Open: the long GPIO nets between the ESP32 and the two headers / UEXT.
One of my own hand-drawn tracks (the PHYAD0 strap, which looped through the UEXT pad field) boxed in three UEXT
pads; it was re-drawn round the outside of the pad columns.
