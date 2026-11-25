# 001 – starting point

Board as received: six switches (hot-swap sockets on the back) and their six reverse-mount LEDs
locked in a 3 x 2 grid; an L-shaped outline 89.15 x 38.1 mm with a 30 x 27 mm block left of the keys;
every other part parked below the outline on the front side; no copper.
Read the schematic: RP2040 + W25Q flash, 12 MHz crystal, USB-C with ESD and fuse, AP2112K LDO,
six direct key inputs, SK6812 chain behind a 74AHCT1G125 level shifter and a TPS22917 load switch.
Plan: flip everything to the back, keep only a narrow strip left of the keys, use the free
pockets between sockets and LEDs for the LED power parts, the bulk cap and the BOOTSEL button.
