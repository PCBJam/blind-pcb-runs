# 004 – first copper: under-chip links, QSPI, USB

Hand-planned, written with `bt apply --checked` (probe first, nothing written on a clearance miss).
- Under the RP2040 on B.Cu: +1V1 from pin 45 to 50 and round the exposed pad to 23;
  +3V3 link pins 1-10-22 and pins 44-43-42-33-26. No vias, nothing crossing.
- QSPI: flash turned so SS/SD1/SD2 go straight up into pins 1-3; SD0/SCLK/SD3 wrap round the
  west end of the flash to pins 5-7. All six on B.Cu, no vias (planar by pin order).
- USB: B6/B7 straight into U102, A6 joins D+ round the A7 via, A7 hops on F.Cu (2 vias, 2.4 mm).
  D+/D- flow through U102 (under its body), then to the 27R resistors and pins 46/47, all B.Cu.
- CC1/CC2 to their 5.1k, VBUS pads joined by a 0.4 mm F.Cu link under the connector, shell stakes
  tied to the GND pads.
First probe run found 3 clearance misses at 45° corners next to QFN pads (0.183 < 0.2); squared them.
