# 000 — placement as received (unrouted)

Starting point: 272 footprints placed, 0 tracks, 0 vias, 0 zones. Board 80 x 49 mm,
4 copper layers, stackup 0.48 mm dielectrics; both inner layers are typed `power` in the file.

Main parts: U30 ICE40HX8K BGA-121 (0.8 mm pitch, centre); U1 CY7C68013A QFN-56 (0.5 mm, left);
J1 USB-C (left edge); J5 LVDS 2x22 header (top); J2/J3/J6-J9 IO ports; 16 SN74LVC1T45 level shifters
and 2 PCA6408 expanders at the right (IO banks A and B); TPS73101 / TLV75533 / TLV73312 regulators
and DAC081C081 + INA233 power/monitor blocks at the right and bottom.

Around the BGA the back side holds about 15 decoupling caps and the PLL filter parts, which
sit right under the balls. That is the main routing constraint of the board.
