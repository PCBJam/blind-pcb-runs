# Review of `bt` on the Arduino Mega 2560 routing job

Short version: I used `bt` all the way through, but mostly as a **checker, writer and viewer**,
not as a router. About 95 % of the copper came from my own lane-generating scripts, pushed
through `bt probe` and `bt apply --checked`. That combination worked very well. The routing
commands themselves I used little, and the one time I gave the autorouter a real job it failed.

Counts are from my session and approximate.

## What I used, and how much it helped

| command | calls | verdict |
|---|---|---|
| `bt probe` (items file) | ~40 | The most valuable command. Every batch of scripted copper went through it; it caught about 45 clearance mistakes before anything was written (fan-outs too tight, a pad I took for round that is square, a B.Cu track under an NPTH peg, two of my own tracks crossing). Messages are exact: which item, against what, the gap and the requirement. |
| `bt apply --checked` | ~25 | Always did what it said. Writing plain text and leaving the `.kicad_pro` alone removed a whole class of worry. |
| `bt render` | ~25 | Second most valuable. Labelled pads and nets, per-layer views with fills, any window. Without a GUI this is what let me judge the routing. |
| `bt board`, `bt part --boxes`, `bt gap` | ~12 | `bt board` gave me the whole netlist with coordinates in one read; I planned the board from it. `--boxes` is what I ended up needing most (pad extents, not centres). |
| `bt drc --baseline`, `bt check` | ~15 | "Only what is new" is exactly right for a board that arrives with 113 findings. `bt check` noticing a stale fill and refilling saved me a wrong sign-off. |
| `bt rules` | 4 | Clean, changed only what I asked. |
| `bt ratsnest`, `bt islands`, `bt same`, `bt length`, `bt query` | ~12 | Small, fast, correct. |
| `bt route` single link, B.Cu, `--no-vias` | 5 | Good: the four ICSP links and (with `--nets`, order given) the four UART runs came out as clean 45° routes first time, in under 2 s. |
| `bt escape` (ground pads) | 1 | Good: 20 of 25 stub+via pairs placed correctly in one call, and for the failures it said what was in the way. |
| `bt stitch` | 1 | Usable, see below. |
| `bt zone`, `bt fill` | ~12 | Worked, with one bad surprise, see below. |
| `bt seg --width`, `bt via`, `bt rm --uuid`, `bt unroute`, `bt undo` | ~15 | All fine. `bt seg --width` with its own probe is a nice way to widen a power track late. |
| `bt fan` | 1 (trial) | Not used, see below. |
| `bt congestion` | 1 | Read once; little use to me here. |

Not used at all: `bt bus`, `bt pair`, `bt planar`, `bt tune`, `bt offset`, `bt place`, `bt near`,
`bt outline`, `bt silk`, `bt cleanup`, `bt plane`. Placement was fixed, nothing needed length
tuning, and for buses I had already written my own generator by the time I would have tried
`bt bus`. I cannot say whether `bt bus` would have done the fan-outs; that is a gap in this review.

## What got in the way or gave wrong or confusing answers

1. **`bt route --nets` on a real fan-out failed.**
   `bt route B --nets PA0,...,PA7 --order given --layers F.Cu --no-vias --passes 1 --avoid ...`
   took 88 s, connected 2 of 8 and gave up on 6. PA0 hugged a capacitor and PA7 ran straight
   through the corridor the others needed. Four of the failures said "the target is boxed in for
   a 0.25 mm track … blocked by track (TXD3) at 154.95,98.05". That track is on the *inside* of
   the pad row; the outside of those pads was completely free, so the diagnosis pointed the wrong
   way. I undid it and never gave the router an ordered bundle again. For a board like this one
   (100-pin QFP, everything in pin order) a lane/bus generator that takes "these nets, this
   order, this pitch, through these points" is what is needed; shortest-first maze routing is
   not.

2. **`bt zone --delete --at x,y` and `--replace --at x,y` removed more than the zone I meant.**
   I had the board-wide F.Cu GND pour and a small priority-1 patch at J12. Both
   `bt zone B --net GND --layer F.Cu --delete --at 165,106` and the same with `--replace` took out
   the main pour as well (the point is inside both outlines). The only hint was the "filled 2
   zones" line; I noticed through 92 new dangling-via warnings. It should pick the smallest or
   highest-priority zone at the point, or refuse when the point is ambiguous, and it should say
   which zones it removed.

3. **`bt fan --dogbone` only fans outward.** For the MCU's north row I needed the vias *inside*
   the footprint (the outside is where the header lanes go). There is no "inward" option, so I
   wrote the fan myself. An `--inward` flag would cover the common "QFP on two layers" case.

4. **`bt escape` / `bt via --near` missed spots that existed.** For U3.62 both said there was no
   spot (escape within 1.5 mm, `via --near --radius 2.5` printed only the eight neighbouring
   failures). `bt probe --vias` then showed three clear spots 1.7 mm from the pad. I think the
   search wants a straight stub; a two-segment stub would have found them.

5. **`bt stitch` is a plain grid.** It put vias under the crystal can and 0.1 mm off SMD pad
   edges (legal, but not what I would hand to assembly); I filtered 12 of 106 by script. It also
   only lands where the pour already exists on two layers, so F.Cu pockets that the "remove
   islands" setting had deleted could not be stitched until I switched the zone to "keep", ran
   stitch, and switched back. An option to "stitch pockets that would otherwise be removed" would
   do that in one step, and a keep-out for named parts (`--avoid-parts Y2`) would help.

6. **KiCad's copper-sliver warning came back with no coordinates** through `bt drc` (KiCad's own
   JSON has none either). I found it by scanning the fill outline for acute corners with pcbnew.
   If bt could locate slivers itself that would save a detour.

7. **Custom rules:** `bt board` correctly told me a rule using `A.Reference` would not be applied
   by route/probe. Good. It could not tell me that a custom rule cannot relax a board-setup
   minimum, which cost one round; that is KiCad's behaviour, but a one-line warning when a
   `.kicad_dru` minimum is below the board's would be cheap.

8. Small things: `bt part --boxes` prints pad *bounding boxes*, and nothing says whether a
   through-hole pad is round or square (I assumed round for J3 and was wrong; probe caught it).
   The pcbnew "memory leak" swig lines leak into `bt zone` output. `bt via` at a free spot says
   "free: no track of the net joins it", which is right but reads like a problem.

## What I did myself instead, and why

- **All bundled routing** (ADC fan and bus, the four fan-outs of the MCU, the lanes inside the
  footprint, USB, power): Python that emits `items.json` polylines from lane tables. Reason: the
  result has to be ordered, evenly pitched and planned around crossings three steps ahead; the
  router has no notion of that plan. With probe as the safety net this was fast: typically one or
  two probe rounds per batch of 50–200 segments.
- **Planning which nets cross where.** I did this on paper from `bt board`. `bt planar` might
  have helped for single part pairs; my crossings involved three or four parts at once.
- **Sliver hunt and stitch filtering**: pcbnew scripts, as above.

## What I would change, add or remove

- Add a **lane/bus generator** I can drive with explicit order, pitch and waypoints (maybe that
  is `bt bus`; if so, the help should show a QFP-to-header example, because I did not recognise
  it as the tool for this).
- Add `bt fan --inward`.
- Fix `bt zone --delete/--replace --at` (item 2). That one can silently damage a finished board.
- Make `bt route --nets` fail fast and honestly on ordered bundles: 88 s for 2 of 8 is worse than
  an immediate "these eight share one corridor, use bus".
- Let `bt probe` accept a *corridor query*: "how many 0.25 mm tracks fit between X and Y on
  F.Cu here". `bt gap` does it for two pads; I wanted it for arbitrary points and for diagonal
  gaps (pad corner to pad corner), which is where most of my probe failures were.
- Keep exactly as they are: `probe`, `apply --checked`, `render`, `drc --baseline`, `check`,
  `board`, `undo`, and the rule that nothing is written unless asked.

## Did it save time?

Yes, clearly, but in the checking, not in the routing. Without `probe`/`apply`/`render` I would
have had to write my own clearance checker against pcbnew or iterate through KiCad's DRC for
every batch, and I would have made more mistakes with less feedback. My guess is that it halved
the work on the copper I generated; I have no measurement for that. The routing commands saved
time on about ten simple links and cost time once.
