# 008 – all signals connected, but In2 round U1 is a patchwork
All signal nets are connected. The last dozen needed short hops on In2 (router with In2 allowed, plus hand routes for UART, I2C clock, C5 reset, USB CC2). Picture: In2 round the processor.
Problem found here: the 1.1 V island under U1 does not work as a plane. The ring vias round the exposed pad wall it in (their antipads merge), and the In2 signal hops cut the feed tongue and the tabs. `bt ratsnest` shows 1.1 V in five pieces. Decision: delete the island and route 1.1 V explicitly as wide tracks.
