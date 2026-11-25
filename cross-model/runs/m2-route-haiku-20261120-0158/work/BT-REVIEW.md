# BT-REVIEW — `bt` on the M.2 PCIe x4 adapter (4 layers, routing from bare copper)

Short version: `bt` carried the bulk of the routing and checking. The lanes were the hard part,
and there the greedy router and the planar check both misled me at times. I did the planning
myself (corridors, via order, which layers) and used `bt` to place copper and check it.

## Commands used and how often (approximate counts from this session)

| command | uses | what for |
|---|---|---|
| `bt route` (single net, `--nets`, `--batch`) | ~45 | lane legs, control links, power nets, GND stubs |
| `bt apply` (one or several item files) | ~25 | writing every step to the board, merging results |
| `bt unroute` (with `-o`) | ~8 | taking lanes out for re-routing, keeping the items |
| `bt check` | ~12 | the DRC + bt check loop; the main quality gate |
| `bt ratsnest` / `bt islands` | ~15 | finding unconnected pieces, what would join them |
| `bt tune` | ~12 | length matching (all pairs ended within 0.003 mm) |
| `bt zone` / `bt fill` | ~15 | GND zones on all four layers, refills |
| `bt probe --vias` | ~6 | checking candidate via sites in one call |
| `bt via` (`--near`, placed by hand) | ~8 | decap and pad vias |
| `bt escape --net GND --ref J1` | ~5 | ground vias on the PCIe pads |
| `bt cleanup` | 3 | removing 0.35 mm dangling stubs left by corridor routes |
| `bt stitch --net GND` | 1 | 139 stitching vias |
| `bt length` / `bt nets` / `bt board` / `bt part` | ~20 | reading the netlist, pads, lengths |
| `bt render` | ~10 | the progress pictures and checking geometry by eye |
| `bt rules` | 4 | the Power class (and the clearance I got wrong once) |
| `bt planar` | 3 | the lane crossing question (see "got in the way") |
| `bt congestion`, `bt fan`, `bt escape --side`, `bt pair`, `bt bus`, `bt drc`, `bt silk`, `bt outline`, `bt place`, `bt near`, `bt offset`, `bt seg`, `bt undo`, `bt free`, `bt gap`, `bt query` | 0 | not needed, or I did not get to them |

## What helped

- **`bt check` as the one gate.** One line with DRC errors, unconnected count, pieces, and bt's
  own findings, plus `--no-fill` for speed, made every step fast to judge. It caught the
  dangling In1 stubs (`track_dangling`) and the "meets its net on another layer, no via"
  case, which KiCad's DRC does not flag by itself. It also pointed straight at the Power class
  clearance problem (4 errors on NC finger pads).
- **`bt route --batch` with `through` points, including paired points** (`x,y,B.Cu` then
  `x,y,In1.Cu` to force a via). This is what made the top lane pair work: four corridors
  routed in 1 s once I gave the waypoints. Without the paired points the router put vias
  where it liked and doubled back on In1.
- **`bt probe --vias "x,y;…"`** is the quickest way to ask "which of these sites are clear?"
  I used it for every ground via decision. It also tells you what is in the way and by how
  much, which I used to reason about the corridor spacing.
- **`bt tune`** with its per-pair report: it found room for every bump I asked for, reported
  the bump count and height, and warned that bumps touch the GND pour (which `bt fill` then
  fixed). The "trial only" default is a trap (see below), but `-o` writes items cleanly.
- **`bt unroute … -o items.json` and `bt apply` with several items files.** Being able to
  take a set of nets out, try a different order, and put back exactly what I wanted is what
  made the reroute experiments cheap to undo. `bt undo`-style backups in `.bt-undo/` also
  saved me once.
- **`bt escape --net GND --ref J1`**: it found 8–11 of the 21 ground pads on the first
  try and said, for each failure, why (which pad or track was too close). Useful even when
  the answer is "no spot".
- **`bt cleanup`** removed the three dangling stubs that `bt check` reported, in one call.
- **`bt render`**: a quick picture after each stage was the fastest way to see a bad topology
  (the wall of corridors, the packed landing row). The progress pictures came from it.

## What got in the way

- **`bt planar` said the D2 and D3 IN pairs were planar on one layer.** A B.Cu-only route of
  those two pairs failed (the second pair is walled in by the first). Its pin-order model
  does not know that the socket pads can only be reached from the north. Result: "PLANAR" was
  wrong here, and I wasted a bit of time trusting it before I checked by routing. Please
  make `planar` aware of the landing side (or print a warning when a pad's approach is one-sided).
- **`bt route` is greedy and slow in crowded fan-outs.** Single nets took 20–120 s to give up
  ("gave up after 25 s"), and the batch of 14 lanes gave 5–8 of 14 with different orders and
  limits. The message "boxed in" was useful, but the router does not try a different order or
  a different via position on its own, so I had to. The `--budget` and per-net limits are
  fine; the search itself is the limit.
- **The router snaps vias to its own grid.** I asked for vias at x=110.2, 110.53, … and got
  vias at 111.45, 111.43, … with a jog back on In1. The corridor still routed, but the
  geometry was not the one I designed, so I had to re-check every corridor after the fact.
  An option to honour exact via coordinates (or a warning when it moves them more than
  0.05 mm) would help a lot.
- **`bt tune` without `-o` or `--apply` writes nothing**, only prints "trial only". I ran it
  five times before I noticed, and the first results looked like they were applied. Printing a
  line that says "not written" in the same place as the numbers would catch this.
- **`bt via --near PAD` found nothing** for the three remaining J1 pads, while `bt probe`
  on hand-picked sites found two good ones 0.5 mm from the pad row. The `--near` search seems
  to stop at spots whose stub is also legal; a count of how many spots were rejected by which
  rule would help (the `bt escape` output does this and is better).
- **No help for the M.2 edge.** `bt fan`, `bt escape --side` and `--dogbone` are described for
  BGA, QFN and QFP sides; I did not try them on the edge connector, and the help gives no edge
  mode. I placed the fan-out vias by hand, which is where most of my time went.
- **`bt route --from J2.9` (a pin boxed in by lane exits) failed with blockers that did not
  explain the fix** (which layer would have to be cleared). The blocker list is good; the
  missing piece is "this pin can only be freed by moving track X".
- **Long runs and background jobs.** `bt route` with `--progress` is fine, but a run that
  gives up after a long search prints its summary only at the end. For the big batches I
  wanted a line per request as it finishes (the batch output does this; the single-net
  `--nets` runs were quieter).
- **Power class name.** `bt rules --nets "+3V3"` silently missed `/+3V3` (hierarchical net
  names need the slash). `bt rules` listed the class with only two nets and no error. A
  warning for "pattern matched no net" would have saved a step.

## What I did myself, and why

- **Layer plan and the crossing analysis.** `bt planar` could not be trusted for this footprint,
  and no tool plans crossings. I worked out the same-order crossing by hand, then tested it by
  routing.
- **The top lane pair's corridors** (waypoints, nested order, landing vias 0.35 mm above the
  pads). The router could not get the top landing pads with its own choices (the diagonal
  bundle walled them off), so I drew the corridors and let `bt route --batch` follow them.
- **Choosing which layer each lane leg used**, and the order of routing (corridors first,
  then the bundle, then control and power). Greedy order decided most of the outcome.
- **The ground-via arithmetic for the M.2 fingers** (clearances between 0.5 mm pitch fingers,
  0.45 mm vias, the 0.145 mm rule). `bt probe` did the checks; the arithmetic told me which
  sites could ever work.

## What I would change, add or remove

1. **Honour exact via coordinates** in `bt route` (or move them and say so, with the distance).
2. **A fan-out tool for edge connectors** (M.2, card-edge sockets): staggered via columns for
   0.5 mm pitch, ground columns reserved, lane exits that go horizontal before they turn. The
   escape tools assume QFN/BGA sides, and this board needed exactly that.
3. **A "corridor" option for pairs**: `bt pair --through` with the corridor's offset, so a pair
   stays coupled along a designed route (the top pair here was two separate nets).
4. **`bt planar`**: model the landing side (one-sided pads, via-only access). Otherwise remove
   the "PLANAR" answer for pads that cannot be reached on one side.
5. **`bt tune` and `bt route` should say when nothing was written** in the same line as the result.
6. **A pattern check** for `bt rules --nets` (warn when a pattern matches no net).
7. **Search budget reporting**: for every give-up, say how many nodes were explored and whether
   a larger budget or a different order would likely help. I spent several runs guessing.
8. **`bt check` could list the unconnected pads per net with their nearest blockers**, in the
   same way `bt islands` does for pours. That would have saved most of my investigation time
   on the M.2 ground pins.

## Verdict

`bt` is useful for the parts of PCB work that are checkable (placing copper, length matching,
zones, the DRC loop) and it made those steps quick. It is much weaker where the problem is
topology (the lane crossing, the fan-out of a fine-pitch edge). There I got little from
`bt planar`, and the router needed explicit corridors. The unfinished item in this board
(9 ground pads) is a topology problem of that kind, and I would want better fan-out and
planar tools before I trusted `bt` with it again.
