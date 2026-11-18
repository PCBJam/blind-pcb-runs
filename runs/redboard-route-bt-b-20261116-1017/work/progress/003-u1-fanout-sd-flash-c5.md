# 003 – U1 fan-out: flash, C5 SDIO, SD card, core power
- `bt route --nets` on F.Cu only for the short decoupling links worked for ~20 nets, but it also drew long fat 3.3V tracks on the top layer (walling in U1's east side) – removed those, 3.3V goes through vias to the In2 3.3V region instead (`bt plane`).
- Flash: pin order is not planar on one layer (R33 and the VDD_FLASH caps are in the way): WP/Q/CS on F.Cu, D/CLK/HOLD through ring vias on B.Cu.
- C5 SDIO: six lines hand-drawn on F.Cu under U4 and diagonally up to the module pads (`bt bus` put the first two on the pin rows and left no room for the rest).
- SD card: ring/outward vias alternate along U1's south-west corner, bus on B.Cu to vias under the socket; the order problem (D1) solved by giving each wrap-around line its own via column west of the pads.
- UART0 TX/RX are boxed in on B.Cu by the SD bus, so they hop east on In2 under U1; 1.1V core: In2 spine west of U1 + In2 link along the top + B.Cu branch to pin 91.
Picture taken before the UART/1.1V changes.
