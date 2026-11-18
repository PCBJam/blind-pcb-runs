# 002 – placement v1 (all 42 parts on B.Cu, outline cut to x=119)
- J101 on the bottom edge between D501/D601, body flush with the edge; U102 (ESD) + R103/R104 in the channel between
  the SW501/SW601 sockets straight above it; RP2040 in the pocket above that.
- RP2040 rotated so QSPI pins face right -> flash U104 in the next pocket, crystal pins face left -> Y101/C109/C113/R105
  in the strip under D201.
- LDO U101 + C102/C104 and BOOTSEL in the bottom pocket right of USB, fuse under D601, C101 bottom-right, LED switch U105
  top-right pocket, level shifter U106 next to the first LED D201.
- One 100nF next to each LED; MCU caps where they fit around the QFN (only 1.7 mm between QFN and LED courtyards).
Result: no courtyard overlaps, only silkscreen-overlap warnings. Locked parts unchanged (bt same).
