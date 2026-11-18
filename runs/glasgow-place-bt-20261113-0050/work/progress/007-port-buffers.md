# 007 – level-shifter rows

Per buffer a scripted hook-up (`tools/ports.py`): VIO via and GND via under the SC-70 body, 3V3 via and DIR via just outside, the two back-side 0402s
straddling those vias. X/Y nets (FPGA side resistor array -> buffer -> connector side array) were routed by `bt route --nets` on F.Cu with no vias (32/32).
Connector side: ESD arrays are flow-through, then F.Cu to the IDC pins and B.Cu to the DNP socket rows. The pull-up arrays between the socket rows were
hand-scripted (`tools/pulls.py`) after the router left two Z nets stranded there and had again used inner layers in its shove pass (removed).
