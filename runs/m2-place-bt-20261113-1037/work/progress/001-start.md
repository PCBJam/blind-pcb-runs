# 001 – starting point
Board as received: connectors and logos locked, 13 passives parked below the outline, no copper.
Read the netlist (`bt board`) and found the key fact of this design: the nine differential pairs
(4 TX, 4 RX, REFCLK) leave the M.2 edge in the *reverse* order of their PCIe socket pins, and each
pair is also P/N-mirrored. No single-layer route exists; every pair needs a layer change.
