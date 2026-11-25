# 005 Top headers J6/J7/J8: top-right group routed

**What:** PA0, PA1, PA2 (N side of U3 to the top rows of J5), TXD1/RXD1 (S side to J8.5/J8.6), TXD2/RXD2 (W side to J8.3/J8.4), SCL and SDA (S side to J8.8/J8.7 and RN1; SCL also to J6.1). One bt route --nets call in background, 193 s.
- 9 of 11 connected. TXD3 and RXD3 (E side pins 63/64 to J8.1/J8.2) gave up: the E-edge corridor below J12 is full. Both shove passes failed as well.
- Applied: 105 segments, 27 vias. Probe of the items: all 132 clear. bt drc --all: no clearance or short errors.

**Picture:** SCL and SDA run as a rail along the top edge above the header row (y about 79.3, 1 mm from the board edge), then drop onto J6.1 and J8.7/J8.8. TXD1/RXD1 come up as B.Cu verticals past the east fan. PA0-PA2 run above the east fan into J5.3-J5.6.

**Notes:** the rail is legal but unusual; it uses the strip above the headers that nothing else needed. The TXD2/RXD2 diagonal across the top (B.Cu and F.Cu) is the longest of these nets (about 40 mm).
