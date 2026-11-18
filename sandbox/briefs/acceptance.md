

How the result will be checked, after you finish:
- KiCad 10 DRC (with schematic parity): no errors, nothing left unconnected. The violations already in the board you received don't count against you.
- Locked footprints are where they were; no footprint added or removed.
- The number of vias and the total track length, compared with a human layout of the same board.
- Ground: how whole the pour is, and whether signal tracks cross splits in it.
- Decoupling: how close each capacitor sits to its supply pin, and how directly it connects to it.
- Buses (key lines, QSPI, LED data): whether the tracks run together and in order.
- USB D+/D− run as a pair; the crystal tracks are short.
- NOTES.md: whether what it says matches the board.
