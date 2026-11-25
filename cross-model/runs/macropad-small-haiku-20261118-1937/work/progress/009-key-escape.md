# 009 escape vias for the six key pins

`bt escape U103.31 .. U103.37` for the six key pins: a stub and via per pin, staggered in two rows (three vias inside the RP2040 body, three just east of the pins). Applied.

Why: the pin row is at 0.4 mm pitch, so greedy routing from the pads boxed the neighbours in. With the vias in place every key starts from its own via.
