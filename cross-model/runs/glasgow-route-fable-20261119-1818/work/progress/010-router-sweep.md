# 010 – router sweep over everything left

`bt route --nets "*"` (both outer layers, 0.45 mm vias, 2 passes, 6 s per search) on the 63 nets still open:
45 connected on the first pass (355 segments, 59 vias) – LED lines, enables, feedback dividers, test points, VSENSE,
reset, the INA sense filters. I stopped it by pid when it reached GND (120 pieces; I do GND with vias and pours).
Left open: SCL, SDA, four LED lines, D0, D1, ALERT, CY_RESET, ENVB, four nets at the FPGA's south-east corner,
+1V2 at R32, one INA filter net. Typical reason: "start is boxed in" at a fine-pitch pad or a stub of mine.
Not all of what it drew is pretty (ENVA runs along the top edge), but these are slow control lines; see NOTES.
