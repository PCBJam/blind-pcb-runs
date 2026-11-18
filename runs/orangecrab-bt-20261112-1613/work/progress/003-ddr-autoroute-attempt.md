# 003 – DDR3, first try: let `bt route` do everything (thrown away)
Batch of 47 DDR nets, F.Cu first then F+In2 with router-chosen vias. 32/47 routed.
Why it failed: greedy shortest paths wander diagonally across the FPGA-DDR gap and box in later nets; router-chosen vias land in BGA escape lanes; vias for east-column balls were put outside the DDR. Not a result a designer would keep.
