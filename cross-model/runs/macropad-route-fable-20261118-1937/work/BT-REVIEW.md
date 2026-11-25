# bt review

## How I used it
I planned the topology myself and typed coordinates into small Python scripts that wrote bt items files. bt then did the checking, the writing and the filling. I did not use `bt route`, `bus`, `pair`, `fan`, `planar`, `tune`, `place`, `near`, `outline`, `silk` or `free`, so I have no opinion on the router or the placement tools.

Why no router: the two things that decided this board were a 3V3 ring inside the QFN pad frame and using via positions to reorder the key lanes. Both are exact-coordinate decisions I wanted to own, and once those were drawn the rest was short enough to continue the same way. The `bt planar` and `bt route --order escapes-first` descriptions suggest they could have answered my lane-order questions faster than I did by hand; I did not test that.

Approximate call counts:

| Command | Calls | Verdict |
|---|---|---|
| `bt board` | 1 | Very useful |
| `bt part --boxes` | 2 | Essential |
| `bt probe` (files, `--seg`, `--vias`) | ~14 | The core of the work |
| `bt apply --checked` | ~12 | Core |
| `bt render` | ~14 | Very useful |
| `bt check` | 6 | Very useful |
| `bt rules` | 6 | Useful |
| `bt zone` | 2 | Useful |
| `bt escape` (`--net GND` trial, then a pad list) | 2 | Useful, with a reservation |
| `bt seg --width` | 3 | Useful |
| `bt ratsnest`, `bt vias`, `bt rm` | 2 each | Useful |
| `bt unroute`, `bt query`, `bt length`, `bt same`, `bt fill`, `bt drc --baseline`, `bt congestion`, `bt islands` | 1 each | Mixed, see below |
| `bt stitch`, `bt via --near`, `bt cleanup` | 1 each | Looked at, result not used |
| `bt help` | 2 | Too long |

## What helped
- **`bt board` and `bt part --boxes`.** One call gave me every net with pad coordinates; the pad boxes let me work out clearances on paper before drawing. I planned the whole QFN area from these two outputs without opening the board file.
- **`bt probe`.** It caught four clearance misses in the routing stages, each by 0.01–0.11 mm, plus three bad stitching-via spots, and named the other item and the gap every time. Each would otherwise have been a DRC round trip. The "nearest … at X mm" line on clear items was a good sanity check that a track was where I meant it.
- **`bt apply --checked` with plain-text copper.** It never touched the .kicad_pro, and nothing could be written with a violation in it. In about 400 segments I had no file-format problems at all.
- **`bt check`.** One line of verdict with fill, DRC, unconnected and its own checks. 17 s per run was acceptable. It agreed with `kicad-cli pcb drc --severity-all` run separately.
- **`bt render`.** Per-layer renders with fills were how I found that the MCU's ground island hung on two thin tracks. `--box` zooms were good enough to review the QFN.
- **`bt rm` and `bt unroute`** saying whether a net comes apart, and **`bt seg --width`** for widening three tracks in place.
- **`bt escape` with a pad list** placed 24 ground vias in one call, all legal, with clear reasons for the one it could not place.

Net effect: bt replaced writing my own S-expression writer and geometry checker, which I would otherwise have had to do. Most of the tokens in this job went on my own planning, not on bt output.

## What got in the way or was confusing
- **`bt cleanup` proposed 0.0005 mm segments.** `bt escape` placed vias at coordinates like 104.9375, 104.7849; `bt vias` prints them as 104.938, 104.785. I used the printed values for a track end, and `bt cleanup -o` then wanted to add segments such as `[104.938,104.785] → [104.9375,104.7849]`. I did not apply it. Either print full precision or have escape snap to the grid.
- **`bt islands --net GND` versus `bt escape`.** Islands said `U102.2 … no join found: no path`. `bt escape` in the next call found a via for the same pad at 98.36, 106.5, and my own at 98.4, 106.5 probed clear.
- **`bt via --near C108.2 --radius 2.2`** returned a via inside the QFN's exposed pad with a 1.4 mm stub, although `bt escape` had just told me a via fits 2.05 mm out at 111.95, 111.22. I used the latter by hand.
- **`bt rules --edge-clearance .3`** changed the .kicad_pro, but the .kicad_dru's 0.2 mm rule takes precedence, so nothing changed. `bt check` then said "fills were up to date" with no hint why. A line saying the dru rule overrides it would have saved a round.
- **`bt zone --connect thermal` warning** ("spokes may not fit on 24 SMD pads under 1 mm … KiCad leaves such a pad unjoined"). Every one of those pads did get joined. The warning is reasonable as a caution but reads as a prediction.
- **`bt escape` puts the via 0.05 mm from the pad edge.** Legal, but tighter than I would draw by hand. I would like a `--gap` option.
- **`bt probe --vias` with many candidates** prints the clear list first and last, truncated with "…", and the BAD lines in between. I re-ran with `grep -v ok` to find the three failures. Put the failures first.
- **`bt probe` on a file lists every clear item by default.** The first call cost about 60 lines to say "all clear"; I used `--quiet` afterwards. I would make quiet the default.
- **`bt help` is about 400 dense lines in one page.** I read it all once, which was expensive. `bt help CMD` exists, but the top-level page would be better as a one-line-per-command index.
- **Zoomed `bt render`** drew the title text over the top of the picture when the box did not leave room for it. Cosmetic.

## What I did myself instead, and why
- **All coordinates.** See above: I wanted to own the QFN ring and the lane order.
- **Stitching vias.** `bt stitch --pitch 6` offered 25 grid points. I wanted vias in particular places (the strip above the key lanes, beside the QSPI slot crossings, between sockets), so I listed 47 candidates, checked them with `bt probe --vias` and applied the 45 that fitted. Probe does not say whether a via lands in pour on both layers; I relied on KiCad's dangling-via check after the fill for that.
- **Independent DRC.** I ran `kicad-cli pcb drc --severity-all --schematic-parity` myself once at the end rather than trust a single tool's summary. It matched.

## What I would change, add or remove
- Add: `bt stitch --at "x,y;…"` or `--along` a polyline, with the "lands in pour on both layers" test that the grid mode already does.
- Add: a pad-to-via gap option on `bt escape` and `bt via --near`.
- Add: a note in `bt rules` and `bt check` when a .kicad_dru rule overrides the board minimum being set.
- Change: full-precision or snapped coordinates everywhere they are printed for reuse.
- Change: `bt probe` quiet by default, failures first.
- Change: shorter top-level help.
- Keep exactly as they are: `bt board`, `bt part --boxes`, `bt apply --checked`, `bt check`, per-layer `bt render`.
- Remove: nothing I used. I cannot judge the commands I did not use.
