# 003 — greedy batch route of the 98 BGA nets (partial, discarded)

`bt route --nets <98 BGA nets> --order escapes-first --passes 3 --layers F.Cu,B.Cu,In2.Cu` on the
planes-only board. About 1 net per 20 s when a net fails; stopped after 21 nets. The picture shows the
north exits going up to J5 on F with long diagonals, and the centre still empty.
Why discarded: the greedy order walled in the interior power balls (see 004) and the north exits of the
Z pairs were blocked by each other. The power balls have to go first.
