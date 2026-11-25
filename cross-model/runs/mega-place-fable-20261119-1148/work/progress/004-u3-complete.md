# 004 – everything round U3 connected

- PL0-7 fan to J5 redrawn by hand (the router's PL1 had walled in PL0 next to the XTAL1 track); the eight lines
  leave at 45° and step apart with staggered jogs so the long parallel run has 0.24 gap instead of 0.15.
- ADC bus continues on B.Cu: A0-A5 turn west on 0.6 mm-pitch lanes, A6/A7 pass east of the mounting hole,
  A8-A15 fan straight down to J9. Nothing crosses.
- SPI: B.Cu legs from the under-chip vias to the ICSP header J12, one via on each leg, then F.Cu under Y1/R1 and
  on to J5.31-34 south of the PL fan. PB0 (SS) leaves the chip southwards on B.Cu and joins them.
- RESET: F.Cu from pin 30, via, B.Cu round J12.6 to J12.5.
Open at this point: PE0/PE1 legs to RN4, PB7 to U7, and the +5V trunks.
