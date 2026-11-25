# 003 left block placed (full first pass)

Placed: LDO U101 + bulk C101 (10 uF) + caps C102/C104; load switch U105 (TPS22917) and level shifter U106 (74AHCT1G125) at the upper left of the MCU; BOOTSEL SW101 (rotation 90) at the left.

Problems found on this render:
- The bottom of the RP2040 is crowded: QSPI, USB and the +3V3/+1V1 pins all leave from the south edge.
- The crystal's load parts and +1V1 caps block the north-west corner.
- Decoupling caps C114, C117, C118, C110 do not fit close to their pins without blocking the USB or QSPI lanes.

Decision: the USB connector moved 2 mm further south (origin y 128.7) and the block bottom went to y 133, so the ESD, series resistors and fuse have room between the RP2080 and the connector. The remaining decoupling caps went to the nearest legal spots; the rest are recorded in NOTES.md.
