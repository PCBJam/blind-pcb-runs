# BT-REVIEW – `bt` on this board

I used `bt` for almost everything on this board. Counts are approximate (from my command log).

## Commands used (roughly how often)

| command | uses | what it did for me |
|---|---|---|
| `bt route` | ~150 | every signal route: single nets, `--all`, `--nets` bulk, `--through` waypoints, `--neck`, `--rip --move-board --fixed` |
| `bt apply --checked` | ~35 | writing hand-made or planned items after the probe |
| `bt plane` | ~20 | stub + via per pad into each In1/In2 pour: 227 GND vias in one call, 20+ power vias per rail |
| `bt ratsnest` | ~25 | open pieces per net, and the "fills older than the copper" warning |
| `bt query`, `bt length`, `bt part` | ~40 | checking copper in a box, lengths per layer, pad names and positions |
| `bt render` | ~8 | pictures for the progress log |
| `bt check` | 5 | fills, KiCad DRC, unconnected, pieces, and CHECK OK/FAILED |
| `bt zone` (incl. `--replace`) | ~10 | the In1 GND plane and the eight In2 zones; a +12V protrusion |
| `bt rules` | ~8 | net classes and the Power clearance |
| `bt escape` | ~6 | CM4 PCIe pins, CM4 Ethernet pins: this was the best single tool on the board |
| `bt probe` | ~6 | checking hand-made stubs and vias before applying |
| `bt via --near` | ~6 | legal via spot next to a failed M.2 power pad |
| `bt cleanup` | 4 | dangling ends and dead branches after the rip-ups |
| `bt unroute` | ~9 | removing copper before re-routing |
| `bt fill`, `bt same` | 3 | zone refresh; "nothing locked moved" |
| `bt pair` | ~7 | trials for ETH and PCIe pairs; not used for the final pairs |
| `bt fan` | 1 | the switch fan-out plan; not applied |
| `bt congestion`, `bt board`, `bt nets` | 3 | the first look at the board (`bt board` is 55 KB; I read the parts of it I needed) |
| `bt drc`, `bt bus`, `bt tune`, `bt islands`, `bt near`, `bt silk`, `bt outline`, `bt offset` | 0 | not needed for this board |

## What helped

- **`bt escape`** on the CM4 and the Ethernet pins gave a clean stub-and-via per pin, staggered so the vias clear each other. The PCIe switch and the M.2 sockets were different: `bt escape` put half the M.2 vias north of the socket, into the edge strip, so I wrote those by hand. The CM4 result was good enough to use directly.
- **`bt plane`** for zone pads is the right tool. The planner's summary ("N/M pads to the plane", "no spot" with a reason per pad, "shares via at") tells you what to do next. The trial-then-`-o`-then-`apply --checked` cycle worked every time.
- **`bt route --from VIA,B.Cu`** starting a route from the via's bottom side, and **`--through`** waypoints, were the only way I got lane topology right. Without the waypoints the router happily put a pair on the wrong side of the other.
- **`--neck "w:box"`** plus **`--max-neck-length`** gave the 0.127 mm exits at 0.4 mm pitch pins, and reported how much neck each route used.
- **`bt check`**: one line with CHECK OK/FAILED and the counts, plus the category list with coordinates, is the right shape. It also refills the zones in place, which the ratsnest does not.
- **`bt apply --checked`**: nothing was written when one item broke clearance. This saved me several times.
- **`bt route --rip --move-board --fixed "<list>"`**: the most useful option for a crowded net. It moves only copper it may move, and gives up cleanly if a moved net can't be put back.

## What got in the way

- **`bt pair`** could not leave the pads: a 0.35 mm pair does not fit between 0.5 mm-pitch pads, so it failed at the first pin, and in the one case it did start it put one member on F.Cu with zero vias ("vias Infinity mm apart"). I routed pairs as two single-ended calls and steered them with `--through`. A pair mode that starts from vias, or that accepts per-member escapes, would have saved hours.
- **The 120 s foreground limit** on the tool call was hit many times (bulk, `--all`, rip). I used background runs with a log and a wait for each one. The `--progress` file is the right idea; a status line I could read without a background watch would be better.
- **`bt unroute -o`** writes an items file and leaves the board unchanged. I misread it twice and ran into the "removed copper I meant to keep" problem. The removal file also carries both `remove` uuids and `removeAt` positions; applying it removes everything at those positions, including escape copper. I had to filter the file by hand. In-place unroute is what most people expect.
- **The grid**: several routes failed with "the path found breaks clearance where the grid missed it: F.Cu segment ... is 0.1689 mm from pad ..., needs 0.2". The router knew the answer but could not place the path. A finer grid option, or a retry with a 0.01 mm offset, would have fixed those without me relaxing the class.
- **Bulk routing order**: `--order escapes-first` routed the LED and tacho nets first, and they walled in the RP2040's pins for every later net. Thirteen nets gave up in the bulk pass (its own list), nearly all of them at the RP2040, the CM4 left block, the switch's west and north sides, or the buck band. The guard ("route that pad first, or plan the area by hand") was helpful, but the bulk run would have done better as a planned fan-out per group.
- **Stale fills**: `bt ratsnest` counted zone pads as connected through old fills until `bt fill` ran. I was misled twice before I noticed. A ratsnest that says "fills stale: refill first" as a hard stop would help.
- **`bt check` counts mix footprint errors with routing errors**: 26 "DRC errors", all from the original footprints (17 type mismatches, 9 courtyards), next to 0 routing errors. Reporting them as separate groups ("placement errors: 26, routing errors: 0") would make the result readable in one look.
- **`bt plane --ref "U3,R43"`** matched no pads (it printed "0/0 pads to the plane"); I could not find the pattern syntax that works. Plain `--ref` with `U3.*` was not tested.
- **`bt rules --class Power --clearance 0.15`** changes every net in the class, and says so only in the read-back. That was the intent here, but a `--dry` note listing the affected nets would be clearer.
- **Long nets**: `--seconds 20` is too short for anything over about 60 mm, and the failure reads as "gave up after 20 s". A longer default for nets over 60 mm, or a message suggesting a time, would help.

## What I did myself instead, and why

- **The M.2 socket escapes**: I wrote the stubs and vias as a Python item file. `bt escape` wanted to put half the vias north of the socket (into the edge strip) and I needed them in the gap between the two pin rows. A `--side` option for connectors (as `bt fan --side` does for QFN) would have covered it.
- **The Ethernet ESD bridges**: three of them failed on the router grid. I drew them by hand as 0.2 mm straight segments and probed them.
- **The TSENSE_2 route**: the route the tool found shorted PICO_LED_3, so I removed it. I did not get to an escape plan for the RP2040 that would let it route.
- **Pair order at the sockets**: I worked out the swap for lane 3 on paper (switch pins 41 above 42 against the socket order) and then routed it with the swapped escape. The tool does not check pin order against the switch pins. A check in `bt planar`-style across a pair would catch this earlier.

## What I would change, add or remove

1. A **pair router that starts from escapes** (per-member escape points, then the pair in the open), with a skew and coupling check at the end.
2. A **group fan-out** step: give a list of nets and a part, and it plans every escape before any route is placed (what `bt fan` does for one side, extended to a whole group of nets on a part).
3. **In-place `bt unroute`** by default, and a removal file that never includes escape copper unless asked.
4. **A finer grid option** and a retry for the "breaks clearance where the grid missed it" case.
5. **`bt check` with separate placement and routing counts**, and a hard refusal of ratsnest counts while fills are stale.
6. **Time per net that scales with length** (or a `--seconds` suggestion in the failure message).
7. **`bt plane --ref` documentation** and a test that the pattern syntax works.
8. Keep `bt board` as it is (the full dump is useful), but a `bt status` one-page summary (open nets, counts, worst errors) would be the command I used most in the second half.
