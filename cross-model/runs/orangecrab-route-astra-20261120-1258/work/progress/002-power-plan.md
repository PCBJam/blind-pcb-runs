# Power distribution and the first clock/strobe trial

The image shows the split power layer. The three buck switch nodes now have short, 0.36 mm top-layer connections to their inductors. In1.Cu is reserved for ground. In4.Cu distributes the FPGA rails, system supply, and the two independently bead-filtered DDR supplies. Remaining area carries 3.3 V.

A first `bt pair` trial escaped LDQS+ on top but boxed in LDQS− at the FPGA. I discarded that trial and switched to paired dogbones with a coupled inner-layer trunk. The FPGA ground-ball field has a local top-layer pour.
