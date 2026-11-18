# bt review

I used bt throughout, but mostly its checking and writing half, not its routing half. Counts are approximate.

| command | times | verdict |
|---|---|---|
| `bt board` | 1 | Very good. One call replaced a pile of pcbnew scripting: parts, courtyard sizes, nets with pad positions. Everything I planned came from it. |
| `bt part` | ~8 | Very good. Pad number / pin name / net / position / size after each trial placement is exactly what is needed to get rotations on the back side right. I checked every rotation this way. |
| `bt render` | ~7 | Good. Pad-net labels when zoomed in are useful. Does not draw zone fills, so for ground I had to use `kicad-cli … svg` + rsvg-convert. |
| `bt congestion` | 1 | Little use here. The list of "IC pins with one way out" was correct but I already knew; the crossing counts are dominated by GND. |
| `bt probe` | ~30 batches | The tool I leaned on most. Hand-written coordinates → per-segment ok/BAD with the offender and the gap. Caught ~10 mistakes (pad gaps of 0.15, a via 0.18 from an LED cutout, a track 0.185 from an NPTH). |
| `bt apply` | ~100 (scripted) | Good; plain-text writing meant the `.kicad_pro` was never touched and I could rebuild the board from scratch on every change. |
| `bt drc` | ~20 | Good: grouped, short, with coordinates. `--baseline` is nice at the end. |
| `bt escape --net GND` | 2 | Good time saver: 52 of 57 ground pads in one call, and it respected the F.Cu tracks already there. |
| `bt route` | 1 single, 2 batches | Mixed, see below. Kept 3 connections from it (KEY2, KEY3, Key2/DOUT). |
| `bt same` | 3 | Good, reassuring. |
| `bt ratsnest` | 2 | Fine before pours. After pours it still lists GND as 115 groups ("poured"), which reads like a failure; I trusted KiCad DRC instead. |
| `bt place`, `bt near`, `bt gap`, `bt query`, `bt cleanup` | 0 | Not used. Placement was a geometry puzzle of courtyard boxes that I solved on paper and verified with KiCad DRC; I never thought of `place`/`near` when I needed them, which says something about either me or the help text. |

## What helped most
- `board` + `part` + `probe` + `apply` + `drc` as a loop. It let me write tracks as coordinates in small Python stage files,
  check them in a second, and regenerate the whole board (placement included) whenever a part moved. I moved parts five times
  after routing had started; without stateless text tools that would have been painful.
- Rough saving: I would guess a third of the tokens of doing the same with raw pcbnew scripts, and far fewer silent errors.

## What got in the way or was wrong
1. **`bt probe` does not check the items of a batch against each other.** `bt probe B stageC.json` said all ok; KiCad DRC then
   found 4 clearance errors (three parallel 45° jogs 0.08 mm apart) and later a real short (LED_EN crossing LED_DIN_3V3 on
   F.Cu), both inside one batch. This is the most important thing to fix or at least to print as a warning. After that I ran
   `bt drc` after every stage.
2. **One BAD slipped past my grep**: a +1V1 diagonal 0.15 mm from an unconnected QFN pad was applied; DRC caught it. Probably my
   own filtering (`grep -B1 BAD` on output truncated to the last 3500 characters by my wrapper), but a one-line summary at the
   *end* of the probe output ("3 of 61 break clearance") and a non-zero exit code would have made that impossible. The summary
   is at the top now.
3. **`bt route --batch` with `"through":"x,y;x,y"`** (the CLI syntax from the help) crashes with a JS stack trace
   (`(req.through ?? []).map is not a function`). In batch JSON it must be an array of arrays; `layers` likewise. The help
   does not say so.
4. **Layer-tagged through points make silly routes.** `[[155.3,102.25,"B.Cu"],[155.3,106.5,"B.Cu"],[154.4,112.5,"F.Cu"]…]`
   produced B→F→B→F with four vias on one key line, changing layer at each waypoint and once in between. KEY5 also ran
   past its target to put the via 3.7 mm further on. I threw the batch away and wrote the keys by hand.
5. **KEY4 failed** ("the target is boxed in") because KEY1, routed one request earlier in the same batch, took the only gap
   between two switch holes. The message was accurate and named the blocking track, which was helpful; but a batch that could
   put two tracks side by side through a 1.2 mm gap needs to know about both. I did not try `--shove`/`--rip`.
6. **`bt escape` proposes "via in the exposed pad"** for hot-swap socket pads, the electrolytic and the QFN centre without being
   asked. I filtered those out by coordinate. An option like `--no-via-in-pad` (or default off) would be better.
7. `bt escape` gave up on 5 pads "within 1.5 mm" where a short link to a neighbouring ground pad was the answer; a hint like
   "nearest same-net copper: C117.2 at 2.5 mm" would point to that.
8. Neither `probe` nor `drc` tells you that a ground pad group is an **island** before the pour exists. The QFN exposed pad was
   enclosed by my own tracks on both layers; I only found out from the single "unconnected" after filling. A check like
   "ground copper at X cannot reach the rest on either layer" would have saved a re-route of USB D+.

## What I did myself instead, and why
- **Placement**: pcbnew script (flip, rotate, position from a table) – bt has no command that writes a placement, only trial ones.
- **Outline and zones**: pcbnew script; bt has nothing for either. Saving through pcbnew to /tmp and copying only the
  `.kicad_pcb` back avoided the `.kicad_pro` problem you warned about (the warning was useful).
- **Most routing**: by hand with coordinates. On this board almost every connection had a specific slot (0.65 mm between QFN
  pad ends and capacitor pads, one track between an NPTH and a shield pad…) and a required ordering against its neighbours.
  Telling a router that precisely costs as much as writing the track.
- **Stitching vias**: my own grid generator, then `bt probe` as the judge. Worked well.

## What I would change, add or remove
- `probe`: check batch items against each other; summary line last; exit code ≠ 0 on BAD; `--quiet` to print only BAD lines.
- `route --batch`: accept the same strings as the CLI, validate the JSON and say what is wrong instead of a stack trace.
- `route`: treat a layer on a through point as "be on this layer here" and minimise vias globally; a `--max-vias N`.
- `route`: a way to route a small **bus** (n nets, same corridor, keep order) – QSPI and the key bundle were the cases.
- `escape`: no via-in-pad unless asked; fall back to linking to nearby same-net copper.
- A `bt place --apply` (write the trial placement) and a `bt outline` would let the whole job stay in bt.
- A `bt zone`/`bt fill` and zone fills in `render`; `ratsnest` should understand filled zones.
- An island check for a net across both layers before pouring.
- `congestion`: leave GND out of the crossing list by default.
- Nothing to remove, but `gap`, `query`, `near` and `place` need one example each in `bt help`; I did not reach for them.
