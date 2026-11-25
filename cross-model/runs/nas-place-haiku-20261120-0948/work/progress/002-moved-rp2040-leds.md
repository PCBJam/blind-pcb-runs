# 002 moved RP2040 block, CM4 strip parts and PCIe LEDs

**Problem seen in 001 (bt congestion):**
- CM4 left-column pins (x 89.7) can only leave to the west. The LEDs/resistors/TMP117 parked in that strip blocked ETH_LED, RPI_ACT and LED_1..4 pins.
- The RP2040 sat in the middle of the route from the CM4's PCIe pins (x 126.7, y 110-116) to the ASM, so it had to be moved.
- PCIe activity LEDs D3/D5/D7/D8 and their resistors sat directly under the M.2 lower row (3.3V pins), where the power connections must come down.

**Change:**
- RP2040 (U18) moved to (200,118) on the front side, in the free area next to the fan headers, USB-C J15 and the buttons (the CM4 link is long, but it is 8 signals and this place has most of the RP2040's other connections). Flash (U17) and crystal (Y1) moved next to it; decoupling and pull-ups re-placed round it.
- CM4 strip parts (LEDs D4/D6/D9-D12, R14/R15/R18/R19/R52-R55, U6, R50/R51, TMP117 U5 with R7-R9, C7) moved to the bottom side under the strip, so the front-side exits stay free.
- PCIe LEDs D3/D5/D7/D8 + R12/R13/R16/R17 moved to the bottom side at the top band.

**Still open:** the RP2040 decoupling caps still sit close to its pins; B.Cu vias will be needed for some of those pins.
