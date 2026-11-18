# 004 – first autoroute of the remaining signals (partly thrown away)
`bt route --nets "IO*,C5_*,…" --layers F.Cu,B.Cu` connected 38 of 51 nets in ~20 min, but the east side of U1 came out badly:
GPIO to the headers took 5-via, 55 mm detours, tracks ran under the C5 module on the top layer, and five of the six ADC lines plus UART0, IO0, IO6 could not get out at all.
I kept the autoroutes on the west/north (LEDs, buttons, CC lines, C5 UART/boot/reset) and removed everything for IO0–IO11, UART0 and IOA49–54.
