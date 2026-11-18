# 003 – Inner layer planes
- In1.Cu: solid GND, whole board.
- In2.Cu: +3V3 base pour; VIOA island (top right, comb over the VCCB columns of the bank-A shifters, tongue up to J2.2);
  VIOB island (mirror, tongue to J3.2); +5V strip along the bottom edge and up the right side to both VIO LDOs.
- The 3V3 "finger" between the two VCCB columns feeds the VCCA pins at x=99.15 and is open to the 3V3 corridor at y≈95.
- +1V2 is deliberately NOT a plane island (it would wall the FX2 off from the 3V3 regulator); it goes on B.Cu as a wide track.
