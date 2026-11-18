# 007 – net-by-net `bt route --shove` run (discarded)

After two bulk runs left ~22 long GPIO nets open (first with the default 0.05 grid, which timed out on every long
net; `--grid 0.1` fixed the timeouts), I ran the remaining nets one at a time with `--shove --layers F.Cu,B.Cu`.
It connected 8 more nets, but the shove pass re-routed the nets it pushed aside on **In1/In2**, ignoring the layer
list: USB_D- ended with 29 mm on In1, the RMII clock with 28 mm on In1, TXD0/TXD1/TX_EN on In1+In2 with 3–7 vias.
That cuts the ground plane to pieces (picture: In1 after the run) and undoes the hand-routed lanes.
Thrown away; board restored to the state before this run. Remaining nets are routed without shove.
