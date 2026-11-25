# bt review (Arduino Mega 2560, 2-layer, ~150 nets)

I used bt for almost everything except deciding where copper goes. Roughly 400 calls.

## What I used, how often, how much it helped

| command | calls (approx.) | verdict |
|---|---|---|
| `bt probe` (items file) | 45 | The most valuable command. I generated ~1,000 segments from Python and every batch went through probe first; the "BAD … gap -0.094 < 0.15 against track n15 (SDA)" lines are exact and name the offender. Saved me from ever writing a DRC error into the board. |
| `bt apply --checked` | 45 | Same; "probed: all clear; wrote N" as one step is right. |
| `bt route` (single link, `--batch`, `--nets`) | 30 | Mixed, see below. Very good for point-to-point links with a fixed layer (`--layers B.Cu --no-vias`): J8 arrivals, east side of U3, PE0/PE1 legs – seconds, sensible 45° shapes. |
| `bt rm` / `bt unroute` | 45 | Fine. The per-net "comes apart: 1 → 4 pieces" line is useful. |
| `bt via` (`x,y` and `--near PAD`) | 40 | `--near` with the "why not the 8 spots" lines is handy for ground vias. |
| `bt render` | 25 | Essential (no GUI). `--layers B.Cu` with fills showed me the ground pockets. |
| `bt ratsnest` | 25 | Good, especially "piece 1 / piece 2 … pads" for the poured net. |
| `bt query` | 15 | Needed whenever the router had put copper I did not know about. |
| `bt check` / `bt drc --baseline` | 14 | `--baseline` is exactly right for a board that arrives with errors between locked parts. |
| `bt place` (trial and `--apply`), `bt part --boxes` | 14 | Trial placement of 49 parts in one call, with courtyard reasons, worked first time. |
| `bt fill`, `bt zone`, `bt stitch`, `bt islands` | 12 | zone/fill/stitch fine. islands: diagnosis good, fixes not (below). |
| `bt rules`, `bt same`, `bt length`, `bt cleanup`, `bt silk --fix`, `bt board`, `bt undo --clean` | 1-5 each | All did what they say. `bt board` is a good first call. |

Not used: `fan`, `escape`, `plane`, `bus`, `pair`, `planar`, `congestion`, `tune`, `offset`, `near`, `seg`,
`merge`, `gap`, `free`, `outline`. For the TQFP-100 I wanted vias *under* the body in two staggered rows with
a bus continuing on the other layer; I did not see that `fan --dogbone` could put the vias on the inside, so
I generated it myself. The USB pair is 11 mm with a resistor array in the middle, not worth `bt pair`.
`planar` would have told me earlier that J8.5-8 and the ADC side are reversed; I worked that out on paper.

## Where it got in the way or was wrong/confusing

1. **`bt route --nets … --order escapes-first` on a dense fan-out** (U3 west side, first try): it routed
   PE3/PE4 flat along FID1's keep-out and then reported PE5 FAILED ("no path", closest point 6 mm away).
   A human starts those three at 45° from the pads. Same on the south side: PL1's diagonal was laid so
   close to the XTAL1 track that PL0 (pin 35) had no way out, and the run still reported 7/8 without saying
   "PL1 walls in PL0" – the help says it won't wall in an unrouted pad. I drew both fans by hand.
2. **Shove/rip that leaves things worse**: `bt route --net +3.3V … --shove --move-board` reported "ok" and
   "moved DTR: shoved (+0.68 mm, +2 vias)". The moved DTR then had 3 vias in 4.5 mm and its vias boxed in a
   ground pad (RN5.4) for good. A later `--rip` call ended with "DTR could not be put back after moving it out
   of the way" after 63 s. I would rather get a plain FAILED than a +2-via shove of a net I did not name.
3. **Necking to 0.127 without being asked**: `bt route` necked 8PB6 for 3.8 mm and a +5V link to 0.127 mm and
   called it ok (it does say NECKED in the summary). For a power net that should be refused by default;
   I had to find and replace them. `--max-neck-length 0` should be the default for classes with a width > Default.
4. **`--fixed "*"`** on a `--nets` run still printed "2 needed shoving". Either it shoved copper routed in the
   same call (fine, but say so) or the pattern did not apply.
5. **`bt route --net X --all`** can take a net with 10 pads off in odd directions (RESET2 got a second,
   redundant branch to D3 that fenced in two pads of RN5; RN5.2's +5 V went 12 mm round U7 to J2.2). No way
   to say "tree, shortest, no loops".
6. **`bt islands --fix`**: for the ground pocket north of U3 it proposed "45.56 mm of track and 4 vias", for
   another "24.77 mm and 4 vias", for two "no join found". The real fixes were a via 3 mm away in the next
   sliver or moving one signal 0.8 mm. It would help if it named *which track closes the pocket*
   ("pocket bounded by RESET2 on B.Cu and +3.3V") – that is what I had to work out from renders.
7. **`bt via --near`** takes the first legal spot even when that spot is in an isolated pour pocket, so the pad
   is "connected" to nothing. A hint "this via lands in a GND island of 4 mm²" would have saved three rounds.
8. **"done … (exit 1)" lines**: they go to stderr and, in a chain of several `bt rm` calls, showed up
   between the stdout lines of neighbouring calls, so it was not obvious which call had failed (it was the
   ones that found nothing at the point). Putting the command's target on that line would fix it.
9. **`bt apply` to a `-o` path in a missing directory** fails with only "bt apply done (exit 2)".
10. **`bt place`**: courtyard of the resonator was given as "3.5x2.4" for a part rotated -90 (really 2.4 wide,
    3.5 tall as placed); cost one failed apply.
11. **`bt silk --fix`** left KiCad's silk warning count higher than before (156 → 169) on a board that already has board-level
    silk text; it only looks at references. It cannot move board text, which was the real problem here.
12. A long `bt route --net +5V --all` (5 links) ran past the 2-minute shell limit without any line of output
    until the end; `--progress` exists but per-link lines on stderr by default would do.

## What I did myself instead, and why
- All bus-like copper (ADC escape and bus, 14-track trunk to J7/J6, PL fan, SPI, USB, power trunks):
  Python polylines → `bt probe` → `bt apply --checked`. The router has no notion of "these 8 go as a bundle
  with staggered jogs" and I needed specific topology (which gap, which side of an obstacle).
- Silk label moves and the three decorative lines: pcbnew script (then restored the .kicad_pro, as warned).
- Thinking about pin-order reversal and which nets must change layer: on paper.

## What I would change / add
- A **bundle primitive**: "these N pads, leave at 45°, pitch p, jog-stagger, end on lanes y0+k·dy / at these
  pins" – essentially what my scripts do. `bt bus` may be close; the help did not make me confident it would
  take per-net end pins on a header and peel off in order.
- `bt fan` option for **inside vias, staggered rows, other-layer bus continuing straight** (QFP side whose
  targets are on the far side).
- Router: never neck a class wider than Default unless asked; never shove a net into more vias without
  `--allow-worse`; report "X now walls in pad Y" always.
- `bt islands`: name the bounding tracks of a pocket; offer "move this segment by d" as a fix, not only joins.
- `bt via --near`: prefer spots whose pour is connected to the main body of the net.
- `bt check` summary line could split "errors new since baseline" from all errors without a second command.
- A `bt text` (move/list board silk text) next to `bt silk`.

Overall: probe/apply/render/ratsnest/drc made a scripted hand-route of a 150-net board practical without a
GUI and I would use them again as is. The autorouter was worth it for ~40 % of the nets (simple, layer-fixed
links); in the congested corner it cost more time than it saved.
