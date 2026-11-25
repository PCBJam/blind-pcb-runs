# 006 – last nets, ground pours, checks

- Remaining nets round the power-select cluster (RN5, U7, Q1, D3, D7) took three attempts. bt route kept
  boxing in RN5 (it routed RESET2 to both sides of the array, then shoved DTR into a 3-via detour, then could
  not put it back). Final state: RESET2 through the array's channel, VIN sense and DTR by the router with
  rip-up of only those nets, the 3V3 reference line and the +5 V link over U7 drawn by hand.
- GND: zones on both layers (clearance 0.25), 100 stitching vias on a 4 mm grid, a via at every ground pad
  that the pours did not reach, 4 vias in the 16U2's exposed pad. Three islands needed thought:
  * the caps north of U3 sat in a back-side pocket closed by the J8 lanes – removed the thin +5 V link there
    (C8/pin 10 are now fed from the back with a via in C8's pad) and tied the pocket to the J8.6/J8.7 gap;
  * RN5.4 sat in a pocket closed by RESET2 on the back – tied to J6.4 on the front;
  * J12.6 had one thermal spoke – the RESET run was moved 0.8 mm away and two stitching vias dropped.
- bt cleanup merged 47 runs; silk: references moved off pads, LED/RESET-EN/GitHub labels moved to where the parts
  now are, three decorative lines shortened/moved.
Result: 0 unconnected, 0 new DRC errors (the 4 courtyard errors are between locked parts and were in the
board as delivered), silk warnings remain (see NOTES.md).
