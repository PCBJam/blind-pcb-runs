# 004 – Ethernet pairs, centre-tap supply and USB data routed by hand

* RD pair: bottom layer from the RJ45 pins through the middle of the ESD array (TVS1), past the 49.9R
  terminations and into the PHY; 0.127/0.127 mm as the Zdiff=100R class asks (0.127 mm prepreg stackup).
* TD pair: with the PHY on the bottom side the pin order of the jack and of the LAN8710A cannot both be
  met on one layer (TD is above RD at the jack, below RD at the PHY). TD therefore leaves the jack on
  the top layer, crosses over RD there (two ground planes in between), and drops to the bottom with one
  via per line next to TVS1; TD+ has one extra stub via to reach its TVS pad.
* Terminations sit 9 mm before the PHY, each resistor lying alongside its own line so no line has to
  cross the other; the two inner resistors share a VDDA via, joined to the ferrite on In1.
* Centre taps go 6 mm on In1 to C13/C11.
* USB D+/D-: 2 mm from the connector pads to the CH340 directly underneath.
* Had to move: TVS1 (twice), C7 to the top side, CH340 caps, SD pull-up array, to make the channel.
DRC after this step: 0 errors (267 connections still open - the rest of the board).
