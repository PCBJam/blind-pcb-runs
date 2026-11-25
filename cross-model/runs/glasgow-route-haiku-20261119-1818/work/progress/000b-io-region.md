# 000b — IO buffer region (close-up, unrouted)

Level shifters sit in two columns (x ~95 and ~101). On each one the +3V3 pin (VCCB) is on the outer
column and the VIO pin (VCCA) on the inner column, so an In2 VIO island would have to leave channels
for the +3V3 vias. Decoupling caps are on the back side in the same columns.
This is why the VIO rails are planned as tracks/islands only after the signals are in.
