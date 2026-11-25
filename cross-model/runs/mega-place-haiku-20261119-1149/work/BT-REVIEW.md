# BT-REVIEW — how `bt` did on this board

Short version: `bt` was very useful for the mechanical work (fan-out, placement checks, rules, probes,
pictures). It could not close the hard part on its own: the congested corridors around the TQFP, where
two-layer routing needs a planned layer assignment, not a greedy search. Most of the time went into
trying routing orders and layer choices on scratch copies, and into reading `bt query`/`bt render` to
see why a net was boxed in.

## Commands used (approximate counts over the session)

| command | times | verdict |
|---|---|---|
| `bt board`, `bt nets`, `bt part` | ~13 | used to read the netlist and pad maps; `bt board` is long (~230 lines) but was the first thing I needed |
| `bt rules` (set and dry-run) | ~10 | good: the dry run shows exactly what changes; read-back is clear |
| `bt place` (trial and `--apply`) | ~45 | the main placement tool; "TRIAL ONLY" and the courtyard/way-out warnings were right |
| `bt near` (incl. `--each`) | ~10 | good for decoupling caps; the spots it proposes are often tight but legal |
| `bt fan --dogbone` (U3 N/E/S/W, U4) | ~20 | the best tool in the set for this board: 66 vias on the TQFP and 14 on the 16U2 in a few commands |
| `bt escape` | ~6 | `--outside` gave only every second pin on a 0.5 mm side (see below) |
| `bt via --near` | 3 | fine; reports why the neighbours fail |
| `bt route` (single nets, `--nets` groups, scratch runs) | ~70 | useful for local nets; poor for the corridors (see below) |
| `bt render` | ~20 | essential: most diagnosis came from pictures (progress notes 001–011) |
| `bt query` | ~12 | essential: the copper list with uuids made it possible to see what boxed a pin in |
| `bt ratsnest` | ~15 | good; the pour-piece counts made the open-net number look larger than it was (see below) |
| `bt congestion` | 4 | it named the right hot spots early, but did not predict the failing corridor |
| `bt islands`, `bt zone`, `bt fill` | ~12 | useful; the "fills older than the copper" warning caught a real stale-fill case |
| `bt check` | 4 | the single best summary; ~16 s |
| `bt drc` (bt's DRC) | ~6 | noisy (library mismatch and silk warnings); I used kicad-cli for the final numbers |
| `bt same` | ~8 | essential safety check after every stage |
| `bt apply` (`--checked`), `bt rm`, `bt unroute`, `bt cleanup` | ~20 | `--checked` and `--dry` previews were used every time |
| `bt silk --fix` | 2 | moved two references; did not touch the silk-over-pad warnings |

## What helped (and roughly how much)

- `bt fan --dogbone`: the TQFP's four faces and the 16U2 in a few commands, with probes. Done by hand
  it would have taken far longer, and I would likely have got the stubs wrong.
- `bt place` with the trial and "way out" warnings: prevented courtyard clashes and walled-in pins
  throughout; I did not have to check each move by hand.
- `bt render` and `bt query`: the picture plus the uuid list made every failed route explainable.
- Scratch copies with `bt route --order given --layers`: this is how I tested cluster orders and layer
  choices without touching the real board. Each test was about 5–15 minutes.
- `bt route --progress` in the background: a 30-net run takes minutes; the progress log let me watch
  it and stop it early when it was going wrong.
- `bt same`, `bt apply --checked`, `bt check`: kept the locked parts safe and the copper clean.

## What got in the way, or gave wrong or confusing answers

- `bt route` on the congested TQFP corridors: greedy search puts copper where a human would not. The
  J5 bundle went round the inside of the TQFP ring (PC2, PC4), and an ADC lane routed through the
  corridor it was not supposed to use. Pass 2/3 (shove and rip-up) almost never fixed a corridor net; the
  "could not be put back after moving it out of the way" messages did not say what to do.
- "boxed in" messages: correct in most cases, but sometimes they pointed at copper that was not the
  real limit (a stub of the same net, or a pad of another net), and "gave up after N s" gave no hint of
  how close it was.
- `bt escape --outside` on a 0.5 mm QFP side: the planner keeps the way out of neighbouring pins, so
  the odd pins never got a via, even with `--max 3`. A two-row dog-bone (which `bt fan --dogbone` does)
  was the only thing that worked for these pins.
- `bt unroute --box`: removes everything of the nets in the box, including fan stubs and vias that
  sit inside it. I only avoided losing the escapes because I used `--dry` first. Its "comes apart"
  wording is unclear for nets that already have dangling pieces.
- `bt ratsnest` and `bt drc` counts: poured nets are listed by piece ("GND (poured; fills counted)" with
  41 pieces), which made the open-net count jump from 29 to 45 when I added the pours. I had to explain
  that to myself each time.
- Duplicated progress lines in the `--progress` file for some runs (each failure printed twice).
- Background runs created small watcher shells (`kill -0` on a zombie pid) that stay around after the
  run; harmless, but I had to find and stop one.
- `bt drc`'s own output is dominated by library-footprint mismatch warnings (51) and silk warnings.

## What I did myself instead, and why

- Topology analysis of the TQFP: I worked out by hand which pin groups face which headers, and which
  pairs of groups must cross. The router does not do this, and the crossing analysis is what showed the
  ADC bus and the J5 corner cannot both work with the current placement.
- Layer assignment for the J5 corner cluster (PD7, PG0–2, PC0–1): done by hand, then tested with
  `--layers`. The router still did not find a crossing-free solution.
- Placement of Y1/R1, D3, JP1, the decoupling caps: by hand, checked with `bt place`.
- The staircase design for the ADC bus (risers on F.Cu, B.Cu lanes at staggered heights): designed on
  paper from the pad coordinates; not built, because it needs the north-west corner parts moved first.

## What I would change, add or remove

1. Escape: a real two-row planner for 0.5 mm QFP sides, with the second row outside the courtyard, and
   no "kept for it" blocking of the odd pins. `--outside` should not produce a single row.
2. A bus router: route N nets as a nested staircase, with the order at each end given, and report any
   pair that must cross (with the count). `bt bus` is close but needs per-net endpoints.
3. Route ordering from a crossing graph: suggest the order and the layer for each net before routing,
   so that the cluster problem is visible up front.
4. Routing cost: penalise routes through the interior of a part and past neighbouring pads, and say
   so in the summary.
5. Failure messages: say how many candidate paths were found, which blocker is the smallest to move, and
   which net would have to move.
6. Pour joins: `bt stitch` for GND/+5V pads (vias into the pour), with a list of pads that are boxed in
   and what to move; `bt ratsnest` to count pours by piece only when asked.
7. `bt unroute --box --keep-fan`: remove routed copper and keep the escape stubs and vias.
8. `bt drc`: a default filter for library-mismatch and silk warnings (or a severity option), so the
   real errors are on top.

## Verdict

For mechanical work and checking, `bt` is worth using: `bt fan`, `bt place`, `bt render`, `bt query`,
`bt same` and `bt check` each saved a lot of time and at least some mistakes. For the hard routing in
a congested two-layer corner, it did not solve the problem, and I would not trust it on its own there.
The board is not finished; `/work/NOTES.md` lists the open nets and the next steps.
