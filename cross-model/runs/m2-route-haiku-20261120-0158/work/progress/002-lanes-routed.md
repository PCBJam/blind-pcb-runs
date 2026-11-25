# 002 — all 18 lane nets routed (IN, OUT, REFCLK), written to the board

Result: 18/18 lane nets connected, 30 lane vias in total, no ratsnest left for lane nets.
Lengths: most legs 31-34 mm; the D3 pair 45-47 mm (its corridor is longer, see below).
Intra-pair skew still to fix: D3 ~0.8 mm, D1 OUT 1.6 mm, D0 ~0.8 mm, REFCLK 0.75 mm.

What I did and why:
- Tried all 18 nets on F/B only (001b): greedy routing jammed at the M.2 fan-out
  (an OUT via at x 111.4 walled off the next nets). Gave up on outer layers only.
- Tried all 18 on F/B/In1/In2 in shortest-first order: 16 of 18 routed. D3 OUT N and
  D3 IN P (the top pair) could not reach their pads: the pads at x 117-120 are walled
  off by the diagonal OUT/IN bundle, and rip-up could not free them.
- Routed the top pair first on explicit corridors (bt route --batch with waypoints and
  paired via points on B.Cu/In1.Cu): down the west edge of the fan on In1.Cu (x 110.2 to
  111.2), along y 107-108 to x 117-120, then under the west pads on In1.Cu at y 117.9-119.25,
  each leg rising to a via 0.35 mm above its pad. The four legs are nested so none crosses.
- Routed the other 14 nets around that structure: all connected, no rip-up needed.

Caveat: the D3 pair is about 12 mm longer than the rest; it is the price of the crossing.
Lane vias are 0.45/0.25 at the M.2 fan-out (the pins are 0.5 mm apart), 0.6/0.3 elsewhere.
