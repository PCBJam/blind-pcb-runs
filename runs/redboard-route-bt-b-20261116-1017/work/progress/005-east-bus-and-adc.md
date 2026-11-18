# 005 – planned east bus, ADC bundle, second autoroute
- IO1–IO8 fan out of U1 on F.Cu, drop to B.Cu in a via staircase south of the C5 SDIO bus, run north as one ordered bundle (x 168.8–172.8, under the module's pad row where B.Cu is free) and fan to the D-header through-hole pads; IO9/IO0 join through ring vias, IO10 through one via.
- UART0 TX/RX and IO11 have to end up east of that bundle, so they cross it on In2 (short hop under U1 and U4), come up west of the bundle and run on F.Cu to J9.
- IOA49–54: ring/outward vias, six parallel B.Cu rows, 45° to A0–A5; IOA49/50 end on vias + F stubs so IOA51 can pass underneath (order fix).
- Crystal traces shortened (XTAL- no longer loops round C22).
- Second `bt route --nets` pass: 7 of 13 left-over nets; 6 still open (NET_RST, IOB35, JP2-B, ALRT, BAT_ST, part of SDA).
