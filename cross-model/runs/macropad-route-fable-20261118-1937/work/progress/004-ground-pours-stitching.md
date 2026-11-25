# 004 – ground
- GND zones on both layers (0.25 mm clearance, thermal reliefs 0.25 gap / 0.4 spoke, islands removed).
- First fill left 6 pads without ground (TVS pin 2, one connector ground pad, four LED caps boxed in by the chain links). Rather than patch those six, every ground pad got its own via: each LED VSS, each LED cap, two per socket ground pad, and (with `bt escape`) each decoupling/IC ground pad in the MCU section.
- MCU: the exposed pad's five vias land between the four centre cap pads on B.Cu; that island is tied out at all four corners of the cap array (widened to 0.4 mm) so the chip's ground does not hang on one neck.
- KEY2/KEY3 moved 0.45 mm away from the top edge so the pour strip above them is wide enough to stitch; 45 stitching vias added (top strip, edges, between sockets, beside the QSPI lanes where they cross B.Cu slots).
- `bt check`: 0 errors, 0 unconnected. KiCad's own DRC at all severities: only the footprint-library mismatch warning the board came with.
- Tried raising copper-to-edge to 0.3 mm in the project; the .kicad_dru's JLCPCB rule (0.2) wins, so nothing changed and I put it back.
