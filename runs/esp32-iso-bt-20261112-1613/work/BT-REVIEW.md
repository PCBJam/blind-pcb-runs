# Review of `bt`

Context: one 4-layer board, 147 parts, ~120 nets, an isolation barrier. I finished placement and the critical routing
with it; I did **not** finish the board (48 unconnected items left). Some of that is my planning, some is the tool; I try
to separate the two below.

## What I used, roughly how often

| Command | Calls | Verdict |
|---|---|---|
| `bt route` | ~700 (almost all from scripts) | The core. Excellent for one guided connection; poor as a whole-board router |
| `bt drc` | ~45 | Very good. Used after every stage |
| `bt apply` | ~250 | Good, never corrupted the file |
| `bt render` | ~30 | Very good with `--pads` |
| `bt probe` | ~45 | Good, with one blind spot |
| `bt ratsnest` | ~30 | Good |
| `bt escape` | 7 | Mixed |
| `bt part`, `bt board` | 4 | Good for the first read |
| `bt same` | 4 | Good, cheap reassurance |
| `bt congestion` | 1 | One finding from it changed the floorplan |
| `bt place`, `bt near`, `bt query`, `bt gap`, `bt cleanup` | 0 | Not used |

## What helped most

- **`bt route` with `--from/--to/--through/--layers/--width`.** Describing a route as "this pad to that pad through these
  points on this layer" and getting legal coordinates back in 0.1–0.5 s replaced most coordinate arithmetic. The whole PoE
  converter (about 35 connections) was done this way in three runs. The "blocked by track … at x,y" lines are specific
  enough to act on.
- **`bt drc --baseline` / grouped output.** Short, with coordinates. It made a DRC run after every stage affordable, and
  that is how my custom isolation rule caught two tracks in the barrier.
- **`bt render --pads`.** Pad numbers and net names on the picture let me check pin orientation of rotated/flipped parts
  at a glance. I trusted it more than my own rotation reasoning.
- **`bt congestion`.** The "IC pins with one way out" list showed the PHY's side pins exiting into the board edge and the
  barrier. That was a real placement error found before any routing.
- **`bt apply` being text-only** kept the `.kicad_pro` safe, as promised.

## What got in the way or was wrong

1. **`bt route` ignores board-edge clearance, pad-local clearances and custom rules.** First bulk pass: 25 edge-clearance
   errors, ~60 mounting-hole keep-out errors (the NPTH pads carry a 1.55 mm local clearance), fiducial clearance errors,
   and tracks through the isolation band. One via was placed 0.225 mm from the edge although I gave a legal through-point.
   I had to emulate all of this with 22 `--avoid` boxes, which also block legitimate access (avoid is all-layer).
2. **`--rip` moves tracks into places `--avoid` forbids.** After a rip pass the keep-out errors were back.
3. **`bt escape` placed a via outside the board** (Earth, x = 118.255, edge at 118.15) and one inside the isolation band.
   It also reports "no spot within N mm" for pads where a slightly longer stub would have worked; for the last ground pads
   it gave up at 4 mm.
4. **Pad names with dots are not parsed.** Resistor arrays have pads `1.1`, `1.2`, …; `--from RM2.1.1` gives "no pad
   RM2.1.1", and `bt escape` prints "no such pad" for them. I had to pass coordinates.
5. **`--batch` with an `avoid` key failed all 12 requests** with "the target is outside the search window". The same
   requests worked on the command line. I never used `--batch` again.
6. **`bt probe` does not check the items in one file against each other.** It said "all 60 clear" for a set in which a new
   via was 0.11 mm from a new track; KiCad DRC found it.
7. **Failure cost.** A successful route takes well under a second; a failing long one takes 30–70 s before it says so.
   Late passes were dominated by waiting for failures. "FAILED (4 ms)" with no reason turned out to mean "already
   connected" – that should say so.
8. **No differential-pair support.** I wrote my own offset helper. Fine for me, but it is the first thing a board with
   Ethernet and USB needs.
9. **Sequential routing has no global view.** Each call is locally sensible, but 60 calls in a row fill every channel
   with long diagonals and box in the last 15–20 nets. This is the main reason the board is unfinished. Reordering
   ("hardest first") helped more than `--rip` did.
10. `bt board` reports "outline 0 pts" for this board (outline made of separate segments); harmless but confusing.

## What I did myself instead, and why

- **Placement**: a Python table applied with `pcbnew`, plus my own overlap checker (most footprints here have no
  courtyard, so nothing flags overlaps). I did not try `bt place`/`bt near`: the PoE corner needed many parts placed
  together under constraints (drilled thermal pads blocking both sides, capacitor pins, the barrier), which is not a
  one-part-near-a-pad question. In hindsight `bt place` would have been a quicker check than rebuilding the board.
- **Diff pairs, zones, stitching vias, removing tracks**: own scripts. bt has no zone, no delete-by-net, no stitching.
- **Bookkeeping**: I wrapped `bt route` so every result was also appended to a per-stage JSON, to be able to rebuild
  after a placement change. That worked until `--rip` (results then refer to uuids of the live board).

## What I would change, add or remove

- Make `route`, `escape` and `probe` honour the same rules as KiCad DRC: edge clearance, pad/zone local clearance,
  rule areas, `.kicad_dru` clearances. This one change would have saved the most time and the most mistakes.
- Layer-specific avoid (`x0,y0,x1,y1,B.Cu`) and a "keep this net inside this polygon" option.
- A fail-fast for boxed-in pads, and a real reason for instant failures ("already connected").
- A diff-pair mode for `route` (two nets, gap, same way-points).
- A multi-net mode that orders nets itself and reports what it gave up on – or, at least, a `bt congestion` variant that
  says after each pass which pads have just lost their last escape.
- `bt unroute --net N [--box …]` and a stitching-via command.
- Accept dotted pad numbers. Fix `--batch` avoid handling.
- I would not remove anything; `cleanup`, `gap`, `query` simply did not come up.

## Honest bottom line

For guided, connection-by-connection work bt saved a great deal of effort and prevented clearance mistakes; I would use
it again exactly that way. Used as an autorouter it produced a board that passes its own checks, fails KiCad's, and
cannot be completed without ripping most of it up. I leaned on that mode too long instead of hand-planning the dense
areas, and that judgement error is mine.
