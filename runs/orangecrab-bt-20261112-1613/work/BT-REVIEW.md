# Review of `bt` after routing the OrangeCrab board

Written from the point of view of someone who had to place ~140 parts and route a
0.5 mm-pitch FPGA + DDR3 board with it, with no GUI. Numbers are approximate
(counted from my shell history, not instrumented).

## What I used, and how often

| command | calls (approx.) | verdict |
|---|---|---|
| `bt board` | 1 | very good |
| `bt part` | ~25 | very good |
| `bt render` | ~45 | essential |
| `bt route` (single, CLI) | ~700 (most from my own loop scripts) | good engine, weak control |
| `bt route --batch` | ~25 | useful, several traps |
| `bt probe` | ~1100 (mostly scripted) | essential, one important gap |
| `bt apply` | ~600 | fine |
| `bt ratsnest` | ~40 | fine |
| `bt drc --baseline` | ~60 | very good |
| `bt escape` | ~10 | good, late discovery |
| `bt same` | 2 | wrong answer on this board |
| `bt near` | 1 | unusable (timeout) |
| `bt congestion`, `bt gap`, `bt query`, `bt place`, `bt cleanup` | 0 | not used |

## What helped most

* **`bt board`** – one call gave me rules, classes, every part, every net with pad
  coordinates. I planned the whole floorplan and the BGA pin-swap-free orientation from
  that single dump. Big token saver compared with parsing the s-expression file.
* **`bt part`** – pad positions *after* rotation/flip. For bottom-side parts this saved me
  from several mirrored-footprint mistakes (I still made two, see below, because I guessed
  instead of asking).
* **`bt render`** – the only way to "see". `--layers`, `--box` and net labels made it
  possible to debug escapes at 0.25 mm pitch. I looked at roughly 30 of the 45 renders.
* **`bt drc --baseline`** – the baseline idea is exactly right for a board that starts with
  86 errors (castellated pads on the edge). Without it I would have had to diff reports by hand.
* **`bt probe`** – I hand-designed several hundred vias/stubs as coordinates in Python and
  probed them before applying. That loop (generate → probe → apply) is what made the
  hand-placed BGA escapes possible. Speed was fine for single items (0.2–0.5 s early on,
  ~2 s on the full board).
* **`bt route` single-layer, point-to-point** – fast (40–100 ms on an empty board) and the
  resulting tracks were always legal. As a "connect these two points on this layer without
  breaking anything" primitive it is good.
* **`bt escape`** – one call gave stub+via for 246 of 264 GND pads in 1.3 s, with sensible
  via sharing. I should have used it earlier for the power pads.
* The **"blocked by track tNNN (NET) at x,y"** lines of the single-route CLI are the most
  useful diagnostics in the tool. They told me which earlier net to rip.

## What got in the way or was wrong

1. **`--batch` JSON is not the CLI.** `"layers":"F.Cu,In2.Cu"` (string, as on the command
   line) makes every request fail with *"the target is outside the search window"*;
   `"through":"x,y;x,y"` crashes with a JS TypeError (`(req.through ?? []).map is not a
   function`); `"from":"x,y,L"` gives *"no pad x,y,L"*. All three must be arrays. The
   error texts sent me in the wrong direction each time. Please accept the CLI spellings
   or say "layers must be a list".
2. **Batch mode hides the reason.** In batch a failure is only *"the start/target is boxed
   in"*; the same net on the CLI prints the blocking tracks. With `--through` the message
   does not say which waypoint is the problem. I lost a lot of time here.
3. **The router is greedy and likes long diagonals.** On the DDR bus it routes
   "diagonal first, then a long straight run along the target row", which walls off the
   neighbours' targets. With 40 parallel nets this fails after ~25 whatever the order.
   I ended up writing my own lane assignment and geometry for the regular part and used
   `bt route` only for the irregular FPGA-side hop. A "bus" mode (ordered list of
   point pairs, keep order, no crossings) or simply a cost term for "stay close to the
   straight line / keep clear of other nets' pads" would have saved hours.
4. **Router-chosen vias in BGA fields.** With vias allowed, the router drops vias in the
   escape lanes of other balls, or 2 mm away outside the package. There is no way to say
   "vias only at these candidate sites" or "no vias inside this box" (`--avoid` blocks
   tracks too).
5. **`--shove` / `--rip` lost copper.** In a scratch copy, `--shove` on via-to-point hops
   returned `remove` lists that included other nets' hand-placed stubs and their vias and
   did not put them back (18 of 41 nets ended with no copper at all although the summary
   said 40/41 routed). I stopped using both flags. Later `--rip` simply failed with the
   same "blocked by" list as without it.
6. **Things the router does not see.** It routed straight over the two net-less copper
   logos on F.Cu (shorting_items in KiCad DRC) and over the custom-shaped pads of the
   QFN-24 (`custom 0.28x0.71` pads of U9 – it seems to take them as much smaller or
   rotated). I had to add `--avoid` boxes by hand for both. It also does not know about
   filled zones as connections (it tried to wire every power pad to every other one when
   I had removed the zones), and treats F/B pours as obstacles ("start is boxed in").
7. **`bt probe` checks new items against the board, not against each other.** Two of my
   own stubs in the same items file violated clearance with each other's vias; probe said
   "all clear", KiCad DRC found them. This is the one gap in an otherwise trustworthy tool.
8. **`bt same` false alarm.** The board has three locked footprints with the same
   reference `G***` (logos). `bt same` reported two of them as "moved, rotated, flipped,
   footprint changed" after a plain placement of other parts. It matches by reference;
   it should match by UUID. I wrote a 15-line pcbnew check instead.
9. **`bt near` did not return** within 120 s for one 0201 capacitor near a BGA ball (I
   killed it). I wrote my own pad-vs-copper/courtyard checker with a spiral search
   (tools/fit.py) and used that for ~60 parts.
10. **Speed degrades.** `bt route`/`bt probe` went from ~50 ms to 1–2 s per call once the
    board had ~2500 tracks and zones, so scripted loops that were fine in the morning took
    10+ minutes in the evening (one batch of 80 nets needed ~12 minutes).
11. **No width change inside a route, no via size option.** Tracks must be 0.09 mm inside
    the BGA; I would have liked to continue at 0.15 mm outside. The via size comes from the
    net class only, so I set all classes to 0.28/0.15.
12. Small things: `bt render` also drops an `.svg` next to every PNG (surprising in the
    progress folder); `bt drc` prints the full "nets with more unconnected items" paragraph
    every time, which is hundreds of tokens of noise; `bt apply` happily adds duplicates
    (I produced co-located vias by re-applying an items file).

## What I did myself instead, and why

* **BGA escape planning** (which ball gets which interstitial / vacant-ball site, which
  balls leave on F.Cu through which lane): by hand, as Python tables → `bt probe` → `bt apply`.
  No tool support exists for this and it is where the real design decisions are.
* **DDR bus** (tools/bus2.py): ordered lanes through the via columns, own segment geometry
  and own clearance check, `bt route` only for the last hop.
* **Placement search** (tools/fit.py): replacement for `bt near`.
* **Zones**: pcbnew `ZONE` + `ZONE_FILLER` (bt has nothing for zones).
* **Locked-part check**: by UUID with pcbnew.
* **Rip-up**: a pcbnew script that deletes tracks by net / layer / box.

## What I would change, add or remove

* Make batch and CLI take the same spellings; print "blocked by …" in batch too; name the
  failing waypoint.
* A `--keep-order` / bus mode for groups of nets, and a "hug the straight line" cost option.
* `--via-sites x,y;…` (only these places may get a via) and `--no-via-box`.
* Layer-specific `--avoid` (`x0,y0,x1,y1,B.Cu`).
* `bt probe` should check the items of one file against each other.
* Treat net-less copper graphics and custom pads as real obstacles; understand filled
  zones for connectivity (`bt ratsnest`/`bt route --all` on power nets).
* `bt rip NET [--layer] [--box]` and `bt zone add/fill` as first-class commands – I needed
  both dozens of times.
* A length report per net (`bt length --nets RAM_*`) – needed for DDR matching and missing.
* `bt same`: match by UUID.
* `bt near`: a time limit and a coarse mode.
* I would not miss `bt congestion` and `bt gap`; I never felt the need for them once I had
  `render` and `probe`.

## Overall

`bt board`, `part`, `render`, `probe`, `apply`, `drc --baseline` and `escape` are a solid
base and saved a great deal of time and tokens. `bt route` is a reliable *segment* router
but not yet an *autorouter* for dense areas: order dependence, no rip-up that can be
trusted, and thin diagnostics in batch mode meant that on this board roughly a third of
the copper is hand-specified geometry and another third needed several ordering attempts.
