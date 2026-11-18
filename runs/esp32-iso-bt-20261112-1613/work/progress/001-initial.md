# 001 – starting point
Board as received: outline, mounting holes and connectors locked; 122 other footprints parked below the outline; no copper.
Read the netlist (`bt board`) and found the designer's isolation barrier drawn on User.Eco1: a 3.56 mm wide band that separates the
PoE (primary) corner at the Ethernet jack from the rest of the board. That drawing drives the whole floorplan.
