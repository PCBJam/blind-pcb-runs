# 010 – All signal nets connected
- Leftovers after the bulk pass were finished one by one:
  * VDAC, LED U3/U4: router with a longer time limit / local shove.
  * LED U5: boxed in on B.Cu south of the BGA → In2 hop from its BGA via to a via west of the knot (DB0's In2 lane moved to make room).
  * R10/U32-DIR net: no sane path exists (FPGA ball on the north-east, target on the far side of the DIR columns); kept the router's
    68 mm F/B route, which runs under the right-hand shifter column. It is a static direction line, so only ugly, not harmful.
  * Pocket north of the FX2 (4 LED lines, ENVA/ENVB, CY_RESET, ALERT pull-up): three router attempts tangled it (LEDs with 2–4 vias, one unroutable),
    so it was scripted: LEDs straight on F.Cu, ENVA/ENVB/ALERT drop to B.Cu and leave west on three lanes, CY_RESET runs on In2 down the west edge.
  * ENVA and ALERT go round the top edge on B.Cu (waypoints given to `bt route --through`), ENVB/SDA/SCL round the bottom/right.
  * I2C: router did most links; two In2 links it reported as "ok" stopped short of their via (caught with `bt ratsnest`, patched by hand).
