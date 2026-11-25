# 004 South bus (MCU S side to J5 lower rows) routed

**What:** nets PL0..PL7 and PD7, from the S edge of U3 to J5 rows 10-16. One bt route --nets call, escapes-first, 32 s.
- 9 of 9 connected; PL4 has a 3.47 mm section necked to 0.127 mm (boxed-in end; flagged for review).
- Layers: mostly B.Cu horizontal runs, one via at each MCU pin (each net takes 3 vias). The planar check said 4 of these nets must change layer (PL0, PL2, PL4, PL6), and the router moved them to B.Cu with a via at the pin, so the other five share F.Cu.

**Check:** probe of the 9 nets: all 105 clear. bt drc --all: no clearance or short errors; 12 courtyard overlaps only.

**Picture:** the horizontal B.Cu runs leave the south edge in order and reach J5 without crossing each other. The E-side runs are above them. PB2 and PB0 (red, from the ICSP area) still cross the bus diagonally on the other layer.

**Next (not in this entry):** the top-right group (PA0-PA2, TXD1/RXD1, TXD2/RXD2, SCL, SDA) was routed next and 9 of 11 connected; TXD3 and RXD3 gave up on the E edge (see 005).
