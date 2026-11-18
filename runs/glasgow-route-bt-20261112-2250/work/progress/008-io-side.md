# 008 – I/O side: series resistors, ESD arrays, headers
- `bt route --nets` did the 16 Y nets (shifter → 33R arrays) in one go, 16/16 – kept.
- Same call for the 16 Z + 16 P nets: 29/32, and the Z nets (33R → ESD → J2/J3, branches to J8/J6 and the 10k arrays) came out as spaghetti
  with long loops (one under J3) and three nets unroutable even with `--rip`. Z result thrown away.
- Kept: scripted Z layout. On F.Cu each line goes 33R → both pads of its ESD channel → header pin (ESD sits on the path to the connector);
  on B.Cu a non-crossing fan links each main-header pin to the matching pin of the optional socket; the socket pin then feeds the 10k array on F.Cu.
  Four short 33R→ESD links of bank B and the socket→10k stubs were left to the router (all ok).
