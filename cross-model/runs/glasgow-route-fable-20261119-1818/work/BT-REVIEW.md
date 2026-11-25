# bt review (Glasgow routing job)

Written by the agent that routed /work/glasgow.kicad_pcb. The "uses" column is counted from my own command
log (about 800 `bt` calls typed, plus ~150 more made from a script loop); it includes calls on scratch copies.

## Short version

`bt` was worth having – I would not have finished this board without it – but mostly for its *checking and
editing* commands, not for its router. `bt probe`, `bt apply --checked`, `bt ratsnest`, `bt query`, `bt render`,
`bt zone`/`bt fill`, `bt rm`/`bt unroute`, `bt via` and `bt drc` carried the job. `bt route` was useful for easy,
uncongested, planar work and, late on, as a "can this be reached at all?" oracle; it failed or gave poor results in
every dense area. `bt fan`, `bt pair`, `bt plane` and `bt escape` were each tried and their output thrown away.
About two thirds of the copper on the board came from my own scripts (coordinates worked out by hand, written
as items JSON) and went in through `bt apply --checked`.

## What I used, and how often

| command | uses | verdict |
|---|---|---|
| `bt probe` (items file, also via lists) | 108 | The most valuable command. Every hand-drawn batch went through it first; it caught hundreds of clearance errors (0.01–0.1 mm) I would otherwise have met only in DRC. Messages name the offending item, layer and gap. |
| `bt apply --checked` / `bt apply` | 100 | Solid. Fast, never corrupted the board, never touched the .kicad_pro. |
| `bt ratsnest` | 89 | Very useful, above all "poured; fills counted" with the list of pieces: three times it showed pads that had a via but no plane behind it. |
| `bt route` (`--nets`, `--net --all`, `--from/--to`) | 85 | Mixed, see below. |
| `bt render` | 73 | Very useful; my only eyes. `--layers In2.Cu` less so (see below). |
| `bt rm`, `bt unroute` | 64 + 24 | Useful; `--uuid` is exact, the by-point and by-box forms take more than one expects (below). |
| `bt query`, `bt part`, `bt nets`, `bt rules`, `bt board` | 56 + 23 + 4 + 3 + 2 | `bt board` once at the start was the best single overview I could ask for. For bulk geometry I ended up reading the board with `pcbnew` in my own scripts instead of `bt query`. |
| `bt zone`, `bt fill` | 47 + 31 | Worked every time. `--replace --poly` and `--edit` are convenient. |
| `bt via` (single) | 19 typed | Good: probes first, says why not. |
| `bt via --near` | ~150 from a loop | Good result, slow, and three bad placements (below). |
| `bt drc` | 9 | Good: KiCad's DRC grouped and readable, on a scratch copy so the project file is safe. This is what told me the board was clean. |
| `bt check` | 4 | **Crashed** at the end: `error: Maximum call stack size exceeded` (13 s, exit 2), and with `--no-fill -o OUT`: `ENOENT: no such file or directory, open '.w/chk.kicad_pcb'`. I used `bt drc` plus `kicad-cli pcb drc` instead. |
| `bt cleanup`, `bt length`, `bt undo`, `bt gap` | 10 + 8 + 2 + 2 | Fine. `bt cleanup --dead` once removed pieces of a net I had not finished yet (my fault for running it early, but it did not say "this net is still open"). |
| `bt islands` | 2 | `--fix --dry` was a good report of which ground pads no pour can reach. I did not apply its fixes: they were tracks up to 16 mm long to the next piece of ground, where what a ground pad wants is a via into the plane beside it. |
| `bt stitch` | 2 | Worked first time: 30 vias on a 4 mm grid, sensible exclusions, clear summary of what it skipped and why. |
| `bt fan`, `bt pair`, `bt plane`, `bt escape` | 2 each (try + look) | Output discarded, see below. |
| not used | `bt bus`, `bt planar`, `bt tune`, `bt offset`, `bt place`, `bt near`, `bt outline`, `bt silk`, `bt congestion`, `bt free`, `bt same` | Not needed (placement is fixed), or I did the job in my own script because I needed exact control. `bt same` I wanted at the end but had lost the original to compare with (see below). |

## What helped most

1. **probe-then-apply as a loop.** Being able to write a few hundred segments as JSON, probe them in one second and get
   "all 142 clear" or a short list of named conflicts made hand/script routing practical. This is the core of the tool for
   me. Example from the last day: `BAD Net-(R10-Pad1) via 92.5,97.75: track t788 (/IO_Banks/DB0) on B.Cu gap -0.009 < 0.15`
   – a 9 µm short found in one second instead of in DRC an hour later. The final 54-item batch (three lanes round the
   board edge, lane shifts of two existing nets, 18 mm on an inner layer) probed "all 54 clear" first time only because the
   batches before it had been corrected this way.
2. **`bt ratsnest` on poured nets.** It tells you which pads are really joined by the *filled* copper. Without it I
   would have shipped an FPGA with three VCCIO balls floating on isolated bits of plane, and – later – six level shifters
   cut off from 3.3 V by ground vias I had just added.
3. **Text-only writes.** I could keep working with scripts and never had the .kicad_pro rewritten.
4. **`bt route --nets ... --layers F.Cu --no-vias --order given`** for planar bundles in open space: 23 nets of the
   level-shifter block, 14 FPGA-to-resistor nets, the PCA6408 nets – all first pass, clean 45° geometry.
5. **Reachability trials** (found late). `bt route --from x,y --to x,y --net N` without `--apply`, on a scratch copy,
   is a very good question-answering tool: three calls (13 s, 1 s, 27 s) told me that the far end of `~ALERT` could be
   reached from the north-west corner of the FX2 and not from the two other candidate points; one more showed where the
   reset line could surface. I then drew the routes by hand, but I would not have known where to aim without it.

## What got in the way or was wrong

- **`bt route` cannot start on fine-pitch pads.** On the QFN-56 (0.5 mm pitch, oval pads) every net failed with
  `the path found doesn't join the start (74.69, 98.5 on F.Cu): no clear way onto its copper there`. It leaves the pad
  diagonally and then rejects its own first segment. Same on the 0.5 mm ESD arrays (`boxed in for a 0.15 mm track`,
  1 of 8 nets after 104 s). Work-around: I drew a straight 1 mm stub on every pin first. The router should try the
  straight-out exit itself.
- **`bt route` has no notion of topology.** In the FX2–FPGA channel it routed 6 of 10 nets, sent `/RD` on a 26 mm
  detour round the wrong side of the chip and then reported the two clocks as "no way through". Each early net takes the
  shortest path and closes the door for later ones; shove/rip-up did not recover. `bt planar` exists for exactly this
  question, but it only looks at two parts' pin order; what I needed was "these 20 nets between these 3 parts on 2 layers –
  which must change layer and where". I did that analysis by hand for every dense area, and it is where most of my time went.
- **`bt route` left to itself makes routes I would not sign.** Its trial for the long `~ALERT` net was 90 mm with 7 vias,
  wandering through the I/O connector area; mine is longer but is three parallel lanes along the board edge with 2 vias.
  It also sometimes left partial copper behind when a multi-net run failed half way.
- **`bt pair` necks whole pairs.** For the LVDS pairs leaving the BGA it reported `NECKED 16.67 mm at 0.15` – because
  the first millimetre between the balls needs 0.15, the whole 17 mm run stayed at 0.15, and it does not coordinate
  several pairs into lanes. I generated the pairs from centre lines myself. (`bt offset --pair` would have done the
  offsetting; I only noticed after I had written my own.)
- **`bt fan U30`** left 16 of 121 balls and knows nothing about which balls are pairs, where the decaps sit on the back
  or which side a net wants to leave on. For a real BGA the via map is the design; a generic fan is not usable.
- **`bt plane --net +3V3`** wanted a new via for every SMD pad, including pads I had already joined to a plane via by a
  0.3 mm stub, and proposed vias in the middle of the BGA field. It should skip pads that already reach the pour.
- **`bt via --near` in a loop: slow, and three placements I had to undo.** Giving ~140 ground pads their own via was a
  Python loop of `bt via --near REF.PAD --apply`; each call re-reads the 3 MB board with filled zones and took 12–15 s,
  half an hour in total. It failed on only six really boxed-in pads and said why. But: two of its vias sat **on FPGA
  ball pads of the same net** (legal for DRC, bad for assembly: an open via in a BGA pad) and one on the tip of a QFN
  pin; and 32 vias, each individually legal, together **cut the +3V3 plane strip** on the inner layer and isolated six
  ICs. I found the first with my own script and the second with `bt ratsnest`. Wanted: never put a via inside another
  pad of a fine-pitch part even on the same net; and after writing a via, say if any *poured* net now has more pieces
  than before. A batch form (`--near C1.2,C2.2,...`) would remove the speed problem.
- **`bt zone --outline` fills to the project's edge clearance, which here is 0.05 mm** – so all four full-board zones
  came 50 µm from the board edge, GND on one layer and +3V3 on the next. Nothing warned me; I noticed it in a bounding-box
  check of my own at the very end and replaced the outlines with ones pulled back 0.4 mm (computed with pcbnew).
  `bt zone --outline --inset 0.4` and a warning when copper-to-edge is under ~0.2 mm would have saved that.
- **The pad guard gives false alarms across layers.** `every route found walls in R10.1 ... leaving no way out` for a
  B.Cu-only route under an F.Cu SMD pad. `--no-guard` fixes it, but then the guard is off everywhere.
- **`bt apply` ignores `"remove"` entries that are uuid prefixes** (the 8-character form `bt query` prints) without a
  word. The new copper went in, the old stayed, and I only noticed from a probe conflict two steps later. Either
  accept prefixes (as `bt rm --uuid` does) or say "0 of 4 remove entries matched".
- **`bt unroute --box` removes whole tracks that merely touch the box**, including long lanes I wanted to keep; twice I
  had to redraw copper. Likewise `bt rm x,y --net GND` offered to take the neighbouring stubs along with the via I meant
  (`--dry` showed it, so no harm – after that I only used `--uuid`). A `--clip` or "3 segments extend outside the box"
  would help.
- **`bt via --near`** says "no via spot within 3 mm" in places where a spot exists once you are willing to move a
  neighbouring track by 0.1 mm; it cannot know that, but it could name the one item that blocks the best spot.
- **Renders of inner layers** draw zone outlines and fills in nearly the same colour, so I could not see where a fill
  was pinched off or missing (an empty 10 × 5 mm pocket in the power plane went unnoticed until the last render);
  I had to infer it from `bt ratsnest`. A "fills only, one colour per net" mode would have saved several rounds.
- **Long runs and pipes.** `bt route ... | grep` under a shell timeout showed nothing at all when the timeout hit; I learnt
  to use `--progress FILE` and run in the background. The first lines of help could say so.
- **`.bt-undo` keeps only the last 20 snapshots.** My own backup of the untouched board was in /tmp and was lost
  in a sandbox restart; `.bt-undo` survived but no longer had the first state. Keeping snapshot 0 for ever
  (`bt undo --first`, or `bt same B --against-first`) would cost 3 MB and would have given me a proper
  "no footprint moved" check at the end instead of a comparison against old terminal output.
- **Help text.** `bt help` is one very dense page of ~330 lines; finding the exact flag (that `--no-guard` exists, that
  `bt offset --pair` exists, what `bt via --near` prints) took re-reading and grepping – I called it 17 times.
  Per-command help with one worked example each would be easier.

## What I did myself instead, and why

- BGA via map (53 vias), all LVDS pairs, the FX2 power stubs, the FX2–FPGA bus bundle and clock vias, the USB pair,
  the 16-part level-shifter block (power vias, lanes, DIR lines), both ESD/connector fans, the regulator power paths,
  every plane outline, the three long control nets round the board edge and the five inner-layer hops: scripted in
  Python as items JSON. Reason in every case: the layout is a *pattern* (lanes, nesting order, mirrored rows) that I can
  state in ten lines of code and that a net-at-a-time router does not find; or it needed other nets moved by a tenth of
  a millimetre first, which no command does.
- Reading pad positions and dumping copper in a box with nets and uuids: `pcbnew.LoadBoard` read-only in my scripts
  (faster and easier to filter than `bt part` / `bt query`).
- The "which ground pad has no via nearby", "which via sits inside a pad", "how close is copper to the edge" and
  "has any footprint moved" checks: own scripts.

## What I would change, add or remove

1. Make the router exit fine-pitch pads straight out by default (or expose `bt fan --stubs-only`).
2. A **lane/bundle primitive that I can drive with coordinates**: "these N nets, in this order, at pitch P, along this
   centre line, start at these pads, end at these pads, vias at these points". `bt bus` is close but picks its own path.
   Most of my scripts were exactly this.
3. A **crossing report for a region**: given a box and two layers, list which net pairs must cross and the cheapest
   set of nets to move to the other layer (generalising `bt planar` beyond two parts).
4. `bt reach B x,y --net N`: which unconnected pieces of the net (or which region, per layer) can be reached from a
   point – the trial-route trick as a first-class command.
5. `bt apply`: strict mode by default – unknown/unmatched `remove` entries are an error.
6. `bt unroute --box --clip`.
7. `bt plane` / `bt via --near` in batch, skipping pads already within X mm of a via of the net; never a via under a
   BGA or inside another pad; report poured nets that lose pieces.
8. `bt zone --inset`, and a copper-to-edge warning.
9. Per-layer guard instead of all-or-nothing `--no-guard`.
10. `bt render --fills` with one colour per net on a single layer.
11. `bt pair`: neck only inside the boxed-in stretch, then return to the pair width (it already knows where the box ends).
12. Fix `bt check` (stack overflow on this board); keep snapshot 0 in `.bt-undo`.
13. Keep exactly as they are: `bt probe`, `bt apply --checked`, `bt ratsnest`, `bt query`, `bt board`, `bt zone`, `bt drc`.

## Rough numbers

- About 800 typed `bt` calls plus ~150 from the via loop. Without `bt probe` I estimate two to three times as many DRC
  round trips through `kicad-cli`, each far slower and far less specific; without `bt ratsnest`'s fill-aware pieces,
  at least three plane faults would have reached the final DRC or the fab.
- Router results kept: roughly 110 nets (mostly 2-pin, uncongested). Router results thrown away: 7 runs
  (BGA fan, pair group, two FX2-channel runs, two DIR-line runs, bank A connector nets), plus the trial routes that
  were never meant to be kept.
- Honest overall: the checking/editing half of `bt` saved me a great deal of time and several real mistakes; the
  automatic half saved some time on easy nets and cost some on hard ones.
