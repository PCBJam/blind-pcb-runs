# Review of `bt` after routing this board

I used `bt` for almost everything except deciding where things go. Rough counts (from memory of the session, not logged):

| Command | Uses | Verdict |
|---|---|---|
| `bt apply --checked` (my own JSON) | ~90 | **The most valuable thing in the tool.** I generated coordinates in Python and let bt refuse the whole batch on any violation. The messages (net, layer, gap vs needed) were precise enough to fix in one go almost every time. KiCad's DRC never contradicted it on clearance. |
| `bt query` | ~40 | Very good. "What is in this box, with nets and coordinates" is what I needed before every local fix. |
| `bt render` | ~25 | Good; labelled pictures with pad nets were enough to plan from. Without `--box` it drew a blank on this board (see bugs). |
| `bt route` single link / `--all` | ~120 | Mixed. Excellent for short links and for "finish this from here to that pad on B.Cu". Poor judgement on long nets: it uses any layer I allow including a plane layer, makes 100–150 mm / 16-via routes without complaint, and several times wrote long fat power tracks across the escape of U1. |
| `bt route --nets …` (batch) | 4 | Saved a lot of typing for ~60 easy nets, but I threw away about a third of what it produced (east side of U1, I2C, power links on In2). 20 min per run. |
| `bt unroute`, `bt rm`, `bt undo` | ~45 | Essential. `bt undo` saved me several times. `bt rm --r` takes out every track ending under the point, not only the via I meant – cost me one round. |
| `bt plane`, `bt stitch` | 5 | Good: ~120 vias placed correctly in seconds. |
| `bt zone`, `bt fill` | ~30 | Fine. `--replace --poly` to reshape a region was handy. |
| `bt drc --baseline` | 6 | Good idea (only what is new). I still ran kicad-cli once myself to see *which* items were unconnected. |
| `bt length`, `bt ratsnest`, `bt islands`, `bt part`, `bt probe --via` | ~60 | All useful and cheap. `bt islands` was the clearest view of what still lacked ground. |
| `bt tune` | 5 | Worked, but only found room for 35–65 % of the skew and made 0.075 mm-high bumps – it should say up front how much it can do, or use fewer, taller bumps. |
| `bt pair` | 2 | Did not work for me (see below). |
| `bt bus` | 3 | Did not work for me (see below). |
| `bt escape` | 2 | Returned "no spot" for all 34 pads, including ones in open areas; with `--via-in-pad` it tried only the pad centre. |
| `bt cleanup`, `bt same`, `bt via`, `bt help` | few | Fine. |
| `bt fan`, `bt congestion`, `bt place`, `bt near`, `bt gap`, `bt free`, `bt silk`, `bt outline`, `bt offset` | 0 | Not needed, or I did the geometry in my own script (pair offsets). |

## What helped most
- Probe-before-write. I drew ~70 % of the critical copper (all pairs, the buses, power spine, every ring via) as centre lines in Python and relied on `--checked`. That is far fewer mistakes than I would make by hand and far fewer tokens than reading DRC reports.
- Text answers that name the blocker with coordinates.
- Writes that never touch the .kicad_pro, and per-write undo.

## Bugs / wrong or confusing answers
1. **Outline inside a footprint.** This board's Edge.Cuts lines live in footprint H1. `bt board` said "outline doesn't close (its 0 Edge.Cuts pieces…)" with an infinite box, and then *every* point inside the board failed with "board edge gap -0.064 < 0.076", while points outside the board were "ok". I had to move the nine lines to board-level graphics and move them back at the end (`scripts/edge.py`). This would have stopped a less stubborn user in the first ten minutes. `bt render` without `--box` also drew an empty image because of it.
2. **Neck width 0.12192** is written as `0.1219`, which KiCad flags as below the 0.12192 minimum (32 errors). Round up, not down.
3. **`bt pair` from 0.35 mm-pitch pins**: fails with "start is boxed in … with 0.327 mm extra clearance". It treats the pair gap as extra clearance at the pins, so it cannot leave a QFN. For USB it gave one leg with four vias and "vias Infinity mm apart".
4. **`bt bus`**: routes the first nets on their pin rows and then reports the rest as failed; its "not planar" verdict was wrong for the flash bus (it is planar if the pads are entered from the far side) and it did not try another order of rows.
5. **`bt route` uses In1.Cu (my ground plane) by default** when `--layers` is not given – first route I tried put a track through the plane. A zone-filled layer should not be a routing layer unless asked.
6. `bt ratsnest` ("fills counted") twice reported one missing link whose real cause was a whole island of the 3.3V pour cut off by In2 tracks; it named two pads next to each other, which sent me looking in the wrong place. Naming the islands (as `bt islands` does for a net) would help.
7. `bt route --all` sometimes "removes N of the board's own tracks (moved)" without `--shove` being given. Once it reconnected stubs I had deliberately cut.
8. `bt zone --islands always|never`: the echo ("islands kept"/"islands removed") is the opposite of what I expected from the word; say `remove`/`keep`.
9. `bt route --batch` uses different key names from the CLI flags (`maxVias`, not `noVias`) – it does list the valid keys, which was enough.
10. `bt escape`/`bt route --net GND --from PAD` fail silently-ish in places where a human sees room once a neighbouring track is nudged; they never propose "move this track 0.2 mm".
11. A background `bt route --nets` gives no result until the end unless stderr is watched; fine, but the 20-minute runs are long for what they deliver.

## What I did myself and why
- All differential pairs, the SDIO/flash/SD/GPIO/ADC buses and every via in the ring under the QFN: drawn from centre lines with a 20-line offset function. bt's pair/bus tools could not start at the pins, and topology (which net crosses which, on what layer) is where the real decisions were.
- Finding via spots near pads: my own grid search with `bt probe` (slow: ~1 s per probe).

## What I would change / add
- Fix the footprint-outline case and the 0.1219 rounding first.
- `bt pair`/`bt bus`: start with pin-pitch spacing and converge; accept explicit centre-line waypoints and just do the offsetting, mitring and length report (that is what I ended up scripting).
- A *topology* helper: given two groups of pads, say whether they can be joined planar on one layer, and if not, which net has to cross. I worked this out by hand four times (DSI, CSI, flash, SD) and it decided the whole layout.
- `bt route`: a cost for length/vias with a hard default limit (e.g. refuse > 3× the straight distance unless told), never use a poured inner layer unless listed, and report "this walls in pins X, Y" for wide tracks.
- `bt via --near PAD`: best legal via spot within r, optionally overlapping the pad, with the reason for each rejected neighbour – the thing I needed twenty times at the end.
- `bt probe` batch mode for many candidate vias in one process.
- `bt rm --via-only`.
- `bt tune`: report achievable length before writing; prefer fewer, taller bumps.
- `bt islands` for pours (which pads/vias are in each island of a filled zone).
