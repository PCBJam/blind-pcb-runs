# 012 — IO channels routed one at a time (in progress)

The batch router over all IO nets at once failed on most of them (about 40 of 187 signal nets came back,
each failure costing 20 s). The IO banks are regular: channel k of bank A has QA/DA (FPGA to RN and to the
level shifter), X and Y (RN to the shifter's A and B pins), P (PCA6408 to RN to J9) and Z (J2 and ESD to RN
to J8). Routing one channel at a time, short nets first, works: channel A0 routes 5 of 6 in about 20 s, and
its failure is the interior BGA ball DA0 (boxed in on the FPGA side).
So channels A0-A7 and B0-B7 are routed in sequence (`bt route --nets <channel> --order short --passes 2`),
each applied with `bt apply --checked` before the next channel starts.
