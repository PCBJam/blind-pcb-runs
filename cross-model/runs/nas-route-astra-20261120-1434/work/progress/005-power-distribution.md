# Power distribution and ground returns

Both inner layers carry ground. On the outside layers I added overlapping 12 V and 5 V buses, separate front copper for each SSD converter output, and local supply regions for the switch and RP2040. I routed connections from supply pins toward adjacent bypass capacitors before filling. Ground stubs and through vias connect surface pads to the reference planes. The next checks are continuity after signal routing and the connections between bus sections.
