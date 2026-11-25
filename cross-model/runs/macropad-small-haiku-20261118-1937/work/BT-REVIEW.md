# bt review (from building this macropad board)

I used bt for almost everything that touches copper, and for all of the checks. Counts below are rough, from the session; treat them as orders of magnitude.

## Commands used, and how much they helped

| command | uses | verdict |
|---|---|---|
| `bt route` (single net, `--nets`, `--all`, `--through`, `--prefer`, `--order`, `--avoid`, `--max-vias`, `--budget`, `--progress`, `-o`) | ~70 | The core of the job and the most important tool. Routing that would have taken hours by hand went through in minutes. It also decided most of my routing. Its weakness is greedy ordering in dense rows, covered below. |
| `bt escape` (a pad list, and `--side`) | ~8 | Essential. The six key pins, the bottom +1V1 pins and two +3V3 pins were all boxed in until their stubs and vias came from `bt escape`. The staggered inside/outside vias it chose were what made the six keys routable at all. |
| `bt ratsnest` | ~12 | Good status view. `--nets` filters and the group coordinates are easy to act on. |
| `bt drc` | ~15 | Good. Coordinates grouped by check; the stale-fill and edge-clearance errors were clear. |
| `bt check`, `bt same` | 3 each | `bt check` is the right final gate ("CHECK OK"). `bt same` answers the locked-parts question, but it lists moved unlocked parts first, which needs a `grep` to find the answer. |
| `bt render` | ~12 | Very useful for the progress log and for spotting obstacles by eye. |
| `bt place` (trial, `--pads`, `--apply`) | ~25 | Good for checking one part at a time. Its pad output was the only reliable way I found to learn the rotation and flip mapping on B (see below). |
| `bt near` (and `--each`) | ~25 | Useful for courtyard-legal spots. Its messages were often misleading (below). |
| `bt apply -o` items-file workflow | ~25 | Good. Writing `-o` first, reading the JSON, then applying was my main safety habit. |
| `bt unroute`, `bt rm` (`--dry`, `--uuid`) | ~15 | `--dry` is excellent: it says whether a net comes apart before you commit. `unroute` removes vias as well as tracks, which I did not expect (below). |
| `bt query`, `bt board`, `bt length`, `bt vias` | ~20 | Useful for uuids and area checks. |
| `bt outline` (`--poly`, `--radius`, `--replace`) | ~8 | Good for the outline itself. |
| `bt outline --fit` | 2 | Not usable as the default: see below. |
| `bt zone`, `bt fill` | ~6 | Works. The zone keeps its own outline when the board outline changes; bt says so, but I missed it once and got a copper-to-edge error. |
| `bt via --near`, `bt via x,y` | ~10 | Mixed (below). |
| `bt probe` | ~5 | Good for candidate spots; the per-candidate list is what I needed. |
| `bt rules` | 3 | Good. Net classes written to the .kicad_pro without other changes, as advertised. |
| `bt congestion`, `bt planar` | 2 / 1 | `congestion` was a good pre-route view (it found the pins with one way out). `planar` said the QSPI order was planar, which was true of the pin order but not of the geometry; the geometric crossings came later and needed a re-route. |
| `bt undo --clean` | 1 | It reported "took out 20 earlier versions" but left three files in `.bt-undo` (the .kicad_pro copies). I removed them by hand. |
| `bt silk`, `bt cleanup`, `bt bus`, `bt pair`, `bt tune`, `bt fan`, `bt stitch`, `bt plane`, `bt islands`, `bt offset`, `bt seg`, `bt merge` | 0 | Not needed for this board (no differential pair in the usual sense, no BGA, no pour islands). |

## What helped most, with time and mistakes

- `bt escape` plus `bt route --order escapes-first --prefer F.Cu` turned the six key nets from 1-of-6 or 4-of-6 successes into 6-of-6 in one call. That was the largest single gain.
- `bt drc` plus `bt check` caught stale zone fills and an edge error that I would otherwise have shipped.
- `bt rm --dry` made dead-stub and escape-via cleanup safe: "no net comes apart" before every removal.
- `bt render` gave me a picture after each stage, and the picture showed the real obstacles (for example the +1V1 track crossing the key corridor) that the numbers did not.

## What got in the way, with examples

1. **Rotation and flip on B was not obvious.** `bt place --move Y101,...,180,B` put the crystal's pads exactly where rotation 0 puts them. I only found the mapping by trial and `--pads`. A short table in `bt help place` would have saved a lot of time.
2. **`bt near` says "courtyard reaches past the board outline" for every spot when the parts are still off-board.** That is true but not useful. It should say that the part's current position is off the board, or that the search area lies outside the outline.
3. **Greedy routing of the six keys.** One call with `--order given` routed KEY3 first, then KEY2 and KEY6 were boxed in; the next order boxed KEY5. The messages were accurate ("boxed in ... blocked by track n8 (KEY2)"), but the fix was the escape stage, not a different order. A command that plans lanes for a whole dense row at once, with staggered vias and nested lanes, would be the biggest addition.
4. **`bt route --through` with per-point layers** would have been the natural tool for the nested fan I worked out on paper. I did not get to test it, so I cannot say whether it works as documented.
5. **`bt unroute` removes the net's vias too.** That is right for a clean reset, but it surprised me: after unrouting the key nets, their escape vias were gone and had to be re-planned.
6. **`bt outline --fit` shrinks the whole placed box, including the key area.** The dry run said it "only shrinks to what is placed", but the key switches are placed too, so the box it proposed (right edge 174.65, bottom 136.05) cut the key area. I had to set the outline by hand. For a board where part of the outline is locked by the task, `--fit` needs an option to keep a given box.
7. **`bt via --near PAD` on a pad of the same net** reports the nearest other-net pad, not that the via already touches its own pad. A via that overlaps its own GND pad is correct, but `bt route` then refuses the zero-length stub with "0/1 routed" and no reason. I found that out by reading KiCad's DRC.
8. **Long runs in the foreground** hit the 120 s tool timeout (exit 143). `--budget` does not stop a net that has started. Running long routes with `--progress` in the background, with a file to watch, was the only reliable way.
9. **`bt apply` vs `-o`:** with `-o` the board is unchanged, so a stale items file can be applied after the board changed underneath it. Two of my applies used a file computed before a later change. The `bt apply` report did not warn about this; it only said "wrote N segments". A check that the items' net copper still matches the board would help.
10. **`bt planar` as a guarantee.** It reads only the pin order around each part. It said the QSPI nets were planar, which was true of the order, and the crossings I got came from the geometry. The output should say "by pin order only" in plain words; it does say that in the parentheses, but that is easy to miss.

## What I did myself instead, and why

- **Floorplan**: I chose the positions and sides by reasoning about pin order and corridors, then used `bt place` trials to confirm each one. bt could not choose the floorplan, and it should not.
- **Reading pad coordinates**: I used short pcbnew Python scripts for the local pad frame of each footprint and for the outline, because bt's `board` output is long and I wanted exact numbers quickly.
- **Netlist reading**: I parsed the schematic netlist with a short script rather than reading the raw file.
- **Key lane design on paper**: the nested fan and its layer plan were worked out by hand. I did not finish implementing it, because the escape-plus-prefer-F approach routed all six keys before I needed to.
- **Decoupling placement**: I made the trade-offs (C117 and C120 are far) myself, because bt's suggestions landed in the key corridor.

## What I would change, add or remove

- **Change** `bt route`: give a per-pin layer option for dense rows, and a "fan-out" mode for a fine-pitch edge that plans staggered vias and nested lanes for every pin of that edge at once. Report the specific pad or lane that blocks each net in a form I can act on.
- **Change** `bt outline --fit`: keep a given box (the key area) fixed, and refuse to cut through any placed footprint's courtyard.
- **Change** `bt near`: separate "part is off the board" from real conflicts.
- **Change** `bt apply`: check that the items file still matches the board before writing.
- **Change** `bt undo --clean`: either remove everything it reports, or say what it kept.
- **Add** a short table of the B-side rotation and flip mapping to `bt help place`.
- **Add** a `bt via` / `bt route` case for a stub to a via that already overlaps the same-net pad: say so, instead of failing silently.
- **Remove** nothing that I used. The unused commands (`bus`, `pair`, `tune`, `fan`, `plane`, `stitch`) were not needed for this board, so I cannot judge them.

## Bottom line

bt carried the routing and every check. Without `bt escape` and `bt route` with the staggered-via and prefer-layer options, the key matrix would not have routed at all in the time I had. The failures I hit were mostly in greedy ordering through dense rows and in a few misleading messages, not in the core checks.
