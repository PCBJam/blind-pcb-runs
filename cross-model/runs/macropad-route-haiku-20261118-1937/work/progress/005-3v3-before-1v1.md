# 005 — +3V3 applied on a scratch copy, before +1V1 (what +1V1 had to fit)

With +3V3 in place, +1V1 failed: pin 50 (DVDD) and C117 were walled in. bt congestion showed RP2040 pins 31-37 (keys) with one way out, pins 43-50 boxed in.

Lesson: the router routes whichever net is first, and the first net takes the chip's escape space. The RP2040 pin groups have to be routed in an order that keeps their exits open: keys, then QSPI, then +1V1 with explicit via sites, then +3V3.
