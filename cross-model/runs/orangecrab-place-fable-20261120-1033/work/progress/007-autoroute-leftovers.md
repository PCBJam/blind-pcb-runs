# 007 – autorouting the "easy" rest: mostly a failure

**What I did.** After DDR3, the header IO on the east side and the power planes were laid by
hand/script, about 75 nets were left (SD card, flash, JTAG, ADC mux, LEDs, button, south header
IO, small power pieces). I gave them to `bt route`:

1. `bt route --nets "*"` at 0.12 mm: routed about 35 nets (charger, mux area, USB-C side,
   several short ones) before the job was killed by the 10-minute limit.
2. The same at 0.10 mm with `--neck-min .09`, and again at 0.09 mm: practically nothing new.
   Typical messages: "start is boxed in", "no path", "walls in pad".
3. A per-net loop with `--rip --move-board` and all critical nets `--fixed` (DDR, USB, power,
   east header IO): 32 nets tried, 2 partially routed, everything else failed.

**Why it failed.** Not the router's search, the board state I gave it: my own breakout stubs.
The FPGA's north and south escapes end in rows of F.Cu stubs / vias at 0.4 mm pitch; the
router may not move them (they belong to the nets themselves or to fixed nets) and cannot pass
between them. In the south the flash (bottom) and the copper logo (top, F.Cu at about
159.7,109.3) close the way, in the north-west the SD pull-up column and the 3V3 vias.

**Result.** About 40 nets still open (yellow ratsnest in the picture). Kept what run 1 routed,
everything else is going to be routed by hand, one area at a time: north via row -> SD/LED/ADC,
south stubs -> flash and header J1, west exits -> JTAG/RESET.
