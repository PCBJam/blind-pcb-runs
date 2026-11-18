# 004 – QSPI, 3V3 trunk, 5V and LED supply
- Flash turned so SD2/SD1/SS run straight into its left pin column; SD3/SCLK/SD0 rise west of the flash and wrap over its top
  to the right column (no crossings, no vias). C301 was moved from under D301 to above it because it forced a dip in all six lines.
- LDO out -> column of 100nF in the SW601/SW701 channel (the 3V3 trunk) -> flash VCC and a rail under C105/C111/C114 to MCU pin 1.
- 5V: fuse -> under BOOTSEL -> C102/U101 -> C101 -> up the right edge -> C119/U105. LED supply from U105 over D401/P2 on B.Cu,
  then one F.Cu hop across the MCU pocket to D201/U106.
Lesson: `bt probe` does not check the items of one batch against each other – three parallel 45° jogs were 0.08 mm apart and
only KiCad DRC showed it. From here on DRC ran after every stage.
