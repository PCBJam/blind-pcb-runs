# 008 – Remaining signals, clean-up, final checks

- West/south FPGA signals, flash, analog header nets, east-side IO: routed in several passes (`bt route` staged per group, my own maze router for the rest, each net applied only if `bt apply --checked` accepted it).
- A router-made track for an LED net ran across mounting hole H1's pad (KiCad: "shorting items") – ripped up and re-routed with a keep-out round the hole.
- GND pours switched from thermal to solid pad connection after KiCad reported four starved thermals on header pins.
- A bug in my own maze router (via-site test far too conservative, then a 1 µm rounding error in the ball-gap test) cost two full passes before I found it; after the fix it confirmed that the still-open nets are trapped by copper routed earlier, i.e. they need rip-up of neighbours, not just another order.

State at the end: see NOTES.md for the exact list of nets that are not connected.
