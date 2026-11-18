# bt review

I used bt for almost everything except deciding coordinates of the high-speed nets, which I
generated with my own Python script and fed to bt as items.json. Counts are approximate.

## What I used
| Command | Times | Verdict |
|---|---|---|
| `bt board` | 1 | Excellent. One screen gave rules, classes, parts, every pad with coordinates. The whole floorplan (reversed pair order, P/N mirror) was worked out from this output alone. Biggest token saver. |
| `bt render` | ~15 | Very useful; the only way I could "see". Zone fills, net labels on pads when zoomed, per-layer views all worked. |
| `bt probe` / `bt apply --checked` | ~10 | The core of my workflow: generate geometry → probe → apply. Messages name the offending item and the gap; I never had a KiCad clearance error on copper that probe had passed. |
| `bt place --apply` | 2 | Fine. Avoided the pcbnew/.kicad_pro trap. |
| `bt part` | 2 | Needed to learn which pad ends up where after rotation. |
| `bt zone`, `bt fill` | ~14 / 7 | Worked first time, `--replace` handy. |
| `bt stitch` | 2 | Mixed, see below. |
| `bt drc --baseline` | 5 | Very good: hiding the 20 pre-existing library notices made the real errors obvious. |
| `bt ratsnest`, `bt length`, `bt same`, `bt islands`, `bt query`, `bt unroute` | 1–5 each | All did what they say. `bt length` confirmed zero P/N skew at a glance. |

Not used: `bt route`, `bt pair`, `bt bus`, `bt fan`, `bt escape`, `bt plane`, `bt congestion`,
`bt near`, `bt free`, `bt cleanup`, `bt gap`, `bt undo`, `bt outline`.
Why: this board is nine pairs with one regular pattern. I wanted an exactly symmetric, skew-free
via transition (vias on the 45° mirror axis, P/N swap inside the turn) and identical breakouts on
every pair. That is 40 lines of script; I did not expect a pair router to produce that particular
construction, so I did not try it — I cannot say whether `bt pair` would have managed. The handful
of remaining nets were short enough to write by hand and probe.

## What got in the way / was wrong or surprising
1. `bt board` (first call, no file argument) printed the help and exit 1 — fine, but the help text
   is ~100 lines and I paid for it twice. A one-line "missing board file" would do.
2. `bt stitch --net GND` put 39 of 69 vias through the +12V and +3V3 pours (legal: they land on the
   two inner GND planes) and inside the socket pad field. They only perforate the power copper, so
   I removed them by hand. I would like an option like `--not-through other-net pours`, or have it
   default to F/B pours of the same net.
3. bt does not see copper `gr_text` on B.Cu ("M.2 PCIe x4 adapter", "Rev…"). `bt board` lists only
   the two logo footprints as copper graphics; `bt query` over the text shows nothing; `bt stitch`
   placed a via 0.11 mm from the text and `apply --checked` passed it. KiCad DRC caught it.
4. bt knows nothing about mask-layer graphics. The exposed screw land (F.Mask/B.Mask circle) ended
   up half GND / half +12V; only KiCad DRC (solder_mask_bridge) revealed it. Listing non-copper
   graphics on Mask layers in `bt board` would have told me up front that this area is special.
5. `bt zone` polygons that end 0.2 mm short of a pad give no warning; `bt ratsnest` after fill
   showed it, with coordinates, so it cost only one round.
6. `bt zone --solid` vs default: there is no way to ask for "thermal reliefs on through-hole only".
   I edited `connect_pads` in the file with sed (and had to repeat it after each `--replace`).
7. Reference designators cannot be moved with bt; I had to save through pcbnew and restore the
   .kicad_pro myself (the warning in the task text about that was accurate and saved me).
8. `bt apply` with only `removeAt` works, but there is no "remove this via at x,y" one-liner;
   I wrote small JSON files each time.
9. `bt undo` keeps a `.bt-undo/` folder in the project; I deleted it at the end.

## What I would change or add
- Show Mask/Cu graphics and text in `bt board` and honour copper text in probe/stitch.
- `bt stitch`: option to avoid other nets' pours; print the list of vias, not just the count.
- `bt zone`: `--connect solid|thermal|tht-thermal`, and a warning when a zone of net N has pads of
  net N within ~0.5 mm outside its outline.
- A `bt via`/`bt rm` shorthand for adding/removing a single item without a JSON file.
- `bt probe` output: a `--bad-only` flag (I always piped through `grep -v ok`; `--quiet` may do this,
  I did not check).
- A silkscreen helper (move a reference, report silk-on-pad) would have removed my only pcbnew use.

## Overall
Net positive by a wide margin. board + probe + apply --checked + drc --baseline + render are the
set I would not want to work without: they made a scripted, geometry-first approach safe, and the
board went from empty to DRC-clean in three DRC rounds. The routing commands went unused here, by
choice rather than because of any failure.
