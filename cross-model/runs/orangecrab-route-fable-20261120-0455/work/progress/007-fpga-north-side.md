# 007 – FPGA north side (SD card, USB, LEDs, ADC mux, analog IO)

This was the second hard spot after the DDR corner.

What failed:
1. `bt route --nets` straight from the balls: 21/29 in 7 min, the inner-row balls (rows 3/4) were walled in by the first-routed nets.
2. Hand-planned escape (every row 3/4 ball gets either a front-layer lane between the outer balls or its own 0.28 mm via with a free inner-layer column) + `bt route` for the rest: 15–18/29 per run, 8 minutes each, and each run boxed in different lane ends ("start is boxed in for a 0.1 mm track").
3. My own grid maze router (0.025 mm grid, exact clearance check, 45° smoothing): 16/23 of the fan-out nets in under a minute, but the same handful of lane ends stay trapped whatever the order (10 random orders tried in the background, none better).

Why: 18 front-layer lanes leave the north edge at 0.25 mm pitch, 12 of them need a via within ~2 mm, and a 0.28 mm via blocks both neighbouring lanes. A staggered two-row via pattern that works was worked out on paper (lanes jogged by 0.03–0.06 mm so each passes its neighbours' vias at exactly 0.28 mm) but I did not get to generating it.

What is on the board: the hand-planned escape, and the nets that routed cleanly from it. The nets still open at this stage are listed in NOTES.md.
