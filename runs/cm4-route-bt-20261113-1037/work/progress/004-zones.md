# 004 – Planes, power pours, switch (ASM1184) power fan-out
- In1: solid GND. In2: GND, with three islands placed where no B.Cu PCIe pair runs: +5V (U1 buck → CM4/fan M4), +12V patch (feeds the 1V2/3.3VA bucks), +1V2 (neck from buck + square under the ASM1184).
- F.Cu pours: +12P (jack→TVS→eFuse), +12V bus (y 82–84.4 with fingers up to every M.2 buck), four +3.3V_Mx pours (inductor → both ends of each M.2 socket), +5V, +1V2, +3.3VA at their bucks.
- ASM1184: every 1V2 pin has a via inside the pin ring into the In2 island and a direct F track to its decoupling cap; 3.3VA pins go to a B.Cu ring under the chip fed by a 0.8 mm B.Cu finger; 9 GND vias in the EP.
- +5V to the fans/LDO on the right: 0.8 mm F.Cu track along y=88.3 (crosses the PCIe trunks on the other outer layer).
First try used several overlapping rectangles per net: KiCad connects them but flags the overlap, so I merged them into single polygons.
