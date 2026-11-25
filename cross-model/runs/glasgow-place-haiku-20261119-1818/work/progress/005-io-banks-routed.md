# 005 — IO banks: buffers, RN networks, FPGA bank pins (first routing pass)

**What I did**
- Routed the bank nets (DA/QA/DB/QB and the buffer X/Y/Z/P nets, 105 nets) with `bt route --nets ... --order escapes-first`. The first attempt with the default passes ran for 18 minutes and only finished 6 nets (every failed net goes through shove and rip-up passes), so I stopped it, applied what it had (12 vias), and re-ran the rest with `--passes 1`.
- Result: 361 segments and 47 vias applied; 48 of 105 nets of this group complete after the single pass. 54 IO nets are still open.

**What fails and why**
- Port B's Z and P lines (J3 odd-pin row): the gap between the bottom-side buffers and the J3 pin row is ~2 mm, shared by eight Z lines, eight P lines and the RN networks. Routes wall each other in.
- Several QA/DA lines on the FPGA's inner balls (the same congestion as the FX2 bus).
- Next step: move the Port B Z/P RN networks off the buffer row (they sit between the buffers and J3), then re-route; or accept those lines as the last items.

**Other notes**
- A bt route run with `--budget` does not stop at the budget inside one net; a 15-second per-net limit with three passes can take 15+ minutes for 100 nets. `--passes 1` made it about 5x faster.
