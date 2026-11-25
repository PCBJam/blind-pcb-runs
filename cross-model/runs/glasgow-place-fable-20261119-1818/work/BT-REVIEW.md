# Review of `bt` on the Glasgow revC3 board (272 parts, BGA-121, 4 layers)

Honest summary: `bt` was essential for *checking* and *writing* copper and saved most of my mistakes;
its *routers* were fine for easy, uncongested nets and poor in the congested parts of this board,
where I ended up computing track geometry myself and only using `bt probe` / `bt apply --checked`.

## What I used, roughly how often

| command | calls | verdict |
|---|---|---|
| `bt board`, `bt part`, `bt nets` | ~8 | very good – one dump gave me rules, pads with nets and coordinates; `bt part … --boxes` replaced a lot of pcbnew scripting |
| `bt probe` (items file, and `--vias` grids) | ~40 | the most valuable command. Every hand-computed batch (BGA fan-out, bus, LVDS pairs, shifter cells) went through it; the messages ("via n77 (/CLKREF) gap 0.018 < 0.127") are exactly what is needed to fix a number and retry |
| `bt apply --checked` | ~30 | used for every write; "skips copper already there" let me re-apply a file after an unroute |
| `bt unroute`, `bt rm` | ~20 | good; says per net whether it comes apart |
| `bt rules` | 4 | good, did exactly what it says and left the rest of the .kicad_pro alone |
| `bt zone`, `bt fill` | ~15 | good; `--replace` with a polygon was painless |
| `bt plane` | 5 | useful but see below |
| `bt route --nets …` (multi-net) | ~10 runs | mixed to poor here, see below |
| `bt route --net … --all` (one net) | ~120 (in loops) | fine for leftovers on a free board, weak once boxed in |
| `bt bus` | 2 | did not help (wandered round obstacles: 24 mm for a 9 mm link) |
| `bt fan` | 1 | gave a first picture of the BGA escape, not usable as it was |
| `bt render` | ~25 | very useful; the only way to *see* the board without a GUI |
| `bt drc`, `bt ratsnest`, `bt vias`, `bt query`, `bt congestion` | ~30 | good. `bt ratsnest` after `bt fill` was my progress meter |
| not used | `bt pair`, `bt tune`, `bt offset`, `bt escape`, `bt stitch`, `bt near`, `bt place`, `bt planar`, `bt outline`, `bt seg`, `bt cleanup`, `bt islands` (not yet at the time of writing this line) |

Placement I did with my own pcbnew script (a dict of ref → x, y, "pad 1 points N/E/S/W", side), because
I wanted to place ~250 parts from formulas (cells, grids) in one go and choose the rotation by where
pad 1 should end up. `bt place` would have worked but one `--move` per part with explicit angles for
flipped parts was more error-prone for me than "pad 1 west".

## What helped most

1. **`bt probe` + `bt apply --checked`.** I generated geometry in Python (dog-bones, 45° fans with
   exact perpendicular spacing, pair offsets) and probed it. Typical loop: 2-4 probes until "all clear".
   Without it I would have needed a KiCad DRC run per attempt and would have had to map violations
   back to my segments. Easily the biggest saving in time and in mistakes.
2. **`bt render`** with layer selection – found the misplaced parts and the ugly autoroutes at once.
3. **`bt rules`**, **`bt zone`**, **`bt unroute --box`** – small, predictable, no side effects.
4. **Messages that explain**: "the fills are older than the copper", "comes apart: 1 → 3 pieces",
   "walled in on F.Cu by … in the wrong order for their routes, so one route must change layer".

## What got in the way / gave poor results

1. **`bt route --nets` in congested areas.** Examples from this board:
   - 10 nets FX2→FPGA on B.Cu: 331 s, 7/10, `/D0` routed 22.5 mm round the far side of the BGA straight
     through the area the LVDS pairs needed, `/CLKIF` with 4 vias. Thrown away.
   - 16 direction lines: 309 s, 12/16, `/DA0` 38.9 mm for a ~10 mm link. Thrown away.
   - 8-bit bus from BGA exits to a resistor array with `--order given`, clean area, F.Cu only:
     6/8, with 15.6 mm and 24 mm detours for ~8 mm links. `bt bus` on the same nets: similar.
   The router is greedy per net: the first nets take the direct line and wall in the next ones; the
   shove/rip passes then mostly report "could not be put back after moving it out of the way".
   What I needed was a real *bus/channel* router: given N sources in order and N targets in order,
   stack lanes (pitch = width + clearance), 45° corners with correct perpendicular spacing. I wrote
   that by hand four times (FX2 bus, LVDS, shifter cells, connector buses).
2. **`bt route` has no notion of "leave room".** It put vias and tracks into places that later nets
   needed (e.g. in the channel in front of a resistor array) – `--avoid` boxes would have helped, but I
   would have had to know all of them in advance.
3. **Inner plane layer as a routing layer.** When I allowed `In2.Cu`, the router happily drew 41 mm of
   `+1V2` on the +3V3 plane including closed loops, which cut the plane into 9 pieces. It prints
   "runs through other nets' pours … (it may split them)", but only for one of the nets, after the
   fact. A hard option "inner layer only inside this box / at most N mm" would be safer; so would a
   check after each net that the pour's pads are still one piece.
4. **`bt plane`** shares a via between at most 2 pads and otherwise adds a new one even when the pad
   already hangs on a via through a track. On the level-shifter grid it added ~20 GND vias I did not
   want; seven of them cut my 1.2 mm +3V3 finger on In2 into islands. An option "skip pads that already
   reach the plane through copper" (or making that the default) is what I expected.
5. **`bt fan` on the BGA**: interleaved the two halves of differential pairs across exits
   (Z11_N, Z12_P, Z11_P, Z12_N) and stopped at ring 3 ("deeper than 2 layers take"). It has no way to say
   "these two balls are a pair" or "this net wants to leave on side W".
6. **Run time and feedback of long routes.** With `| tail` nothing is visible until the end; I learnt
   to use `--progress FILE`. A multi-net run cannot be told "give each net at most N s *and* stop
   retrying a net that failed twice" – the second global pass spent its whole 560 s budget on SCL/SDA
   and tried nothing else (`--order hardest`).
7. **Boxed-in stub ends.** After I had drawn escape stubs out of the BGA (0.4 mm pitch), `bt route`
   could not start from a stub end whose neighbours were already routed ("the start is boxed in"), even
   with `--from x,y`. A via cannot fit there, so a human would shorten/rip the two neighbours; rip-up
   of board copper is off by default and `--rip` did not find it.
8. Small things: `bt drc` output is long when the baseline is missing; `bt route --net X --all` prints
   "0/5 routed; FAILED: /SDA, /SDA, …" without saying which link is which; the neck option exists but
   the multi-net router still reports "boxed in for a 0.15 mm track" in places where 0.127 would pass.

## What I did myself instead, and why

- Placement: pcbnew script (see above).
- BGA via/escape plan: own backtracking search over via sites + hand choice of which gap each ring-2
  ball uses, because the order in which nets leave the BGA decides whether the buses are planar.
- All regular structures (16 shifter cells, 13 LVDS pairs, FX2 bus, connector buses, USB): own geometry,
  `bt probe`, `bt apply --checked`.
- Silkscreen label moves: pcbnew (`bt silk` only moves references).

## What I would change, add or remove

- Add a **lane/bus router** that takes ordered source and target lists and returns stacked 45° lanes
  (and says how many lanes fit). This is the single thing that would have saved me the most time.
- Add **pair-aware BGA fan-out** (pairs kept on neighbouring exits, per-net preferred side, a via-site
  solver that keeps escape lanes free) – or at least let `bt fan` take a list "net → side/layer".
- `bt route`: an explicit **"plan first" mode** for a group (global routing: choose layer/side per net
  from crossings, like `bt planar` does, *then* detail-route), instead of net-by-net greedy.
- `bt route`: when inner plane layers are allowed, **refuse or cap** tracks that split a pour, per net.
- `bt plane`: do not add a via for a pad that already reaches the pour through copper.
- `bt probe --vias` grid search is great; a `bt via --near x,y --net N` returning the nearest legal
  spots on *all* layers (with In2 tracks considered) would replace my little grid scripts.
- Keep exactly as they are: `probe`, `apply --checked`, `unroute/rm`, `rules`, `zone`, `render`,
  `ratsnest`, the undo copies.
