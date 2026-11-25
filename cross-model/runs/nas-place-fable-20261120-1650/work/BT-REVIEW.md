# Review of `bt` after placing and routing RaspberryPiNVMeNAS

I used `bt` for almost everything except deciding where things go. Counts are from memory of the session, so
treat them as rough.

## What I used, and how much

| Command | Roughly | Verdict |
|---|---|---|
| `bt route --net …` (one net, with `--from/--to/--through/--avoid`) | 110 | useful, see below |
| `bt route --nets "*"` | 1 (33 min) | half useful, caused most of my rework |
| `bt probe` (items file, `--vias` lists) | 50 | the most valuable command |
| `bt apply --checked` | 45 | very good |
| `bt unroute` (`--box`, `--layer`) | 35 | very good |
| `bt fill`, `bt ratsnest` | 30 each | good |
| `bt tune` | 2 rounds of ~16 pairs | good result, bad default (see below) |
| `bt zone` (add, `--edit`) | 21 | good |
| `bt place`, `bt near`, `bt part`, `bt query` | 10–15 each | good |
| `bt render` | 15 | good, essential without a GUI |
| `bt drc --baseline` | 8 | very good |
| `bt islands` (`--fix`), `bt via --near`, `bt rm`, `bt silk`, `bt cleanup`, `bt rules`, `bt length`, `bt same`, `bt stitch`, `bt vias` | 1–8 each | mixed, see below |
| `bt board` | 1 | good first read |
| `bt pair` | 1 | result thrown away |
| `bt check` | 1 | crashed |
| `bt fan`, `bt escape`, `bt plane`, `bt bus`, `bt planar`, `bt offset`, `bt congestion`, `bt outline`, `bt free`, `bt merge`, `bt seg` | 0 | not used |

## What helped most

- **`bt probe` + `bt apply --checked`.** I generated the PCIe pairs, the buck stages, the switch fan-out, the
  Ethernet and USB pairs from small Python scripts as items files. Probing each file gave exact, readable
  failures ("gap 0.083 < 0.15 against track n28") and I usually needed two or three rounds per file. Without it
  I would have had to write my own clearance checker; this saved hours and many DRC round trips.
  `bt probe --vias "x,y;…"` to hunt for a legal via spot was equally handy.
- **`bt drc --baseline ORIG`.** The original board carries 400+ footprint/text findings. Seeing only what is
  new made every DRC round a ten-line read.
- **`bt board` / `bt part`.** One dump gave me the whole netlist with pad coordinates; I planned the floorplan
  and the pin-order analysis from it without opening the schematic.
- **`bt route` for single nets** with `--from x,y,B.Cu`, `--avoid` boxes per layer and `--seconds`. Once I
  learnt to give it a start via and keep-outs, it finished nets in seconds that I had no wish to draw by hand.
  The "blocked by track t123 (NET) at x,y" lines told me what to rip up.
- **`bt unroute --box --layer`** and its report of whether a net comes apart.
- **`bt islands`** names exactly which ground pads are cut off; `bt ratsnest` counting zone fills is right.
- **`bt place` / `bt near`** refuse courtyard and pad conflicts and say which one.
- **`bt tune`** matched 16 pairs to 0.01 mm in one command each.

## What got in the way or misled me

1. **`bt tune` without `--apply` writes nothing, and I did not notice.** The help lists it under "Write" and
   says "in place unless -o/--dry" for its neighbours; the output ends with the new lengths, not with a
   "TRIAL ONLY" line where I looked. I believed the pairs were tuned for most of the session and only found out
   from `bt length` at the end. Make the trial banner the last line, as `bt place` does.
2. **`bt route --nets "*"` has no notion of what must be kept clear.** With `--order escapes-first` it ran two
   Ethernet LED nets down the LED column between every resistor and its LED, ran +3V3 under all 16 LEDs
   between their pads, cut a +12V branch straight through the +12P input pour (splitting it), laid a
   thermistor line 0.16 mm beside a PCIe pair for 30 mm, and used the strip between the CM4 connector pad rows
   as a channel. All legal, all wrong. It warns "runs through other nets' pours" but still does it. I spent
   longer undoing this than the run took. Wanted: a keep-away distance per net class (e.g. 3× gap from pair
   classes), "do not cut pours of class Power", and a per-footprint option "no foreign track between my pads".
3. **Long nets time out.** At the default 20 s every 100 mm+ net failed in the bulk run, and passes 2 and 3 then
   spent 12 minutes failing them again at 10 s. Scale the time with the link length.
4. **`bt pair` did not make a pair.** For the port-1 clock the two halves took different routes several mm
   apart (one diagonal early, one late), with "skew 0". I wrote my own centre-line offset code instead. I did
   not try `bt offset --pair`, which is probably what I should have used.
5. **`bt check` and `bt drc --refill` crashed** with "Maximum call stack size exceeded" on the finished board
   (755 vias, 17 zones). Plain `bt drc` kept working.
6. **`bt silk --fix` moved references off the board** (R10, R11, R18, C73 ended left of the edge although the
   help says it keeps them on it) **and moved the reference text of 12 locked footprints.** `bt same` still said
   "nothing locked moved". I restored those from the original with pcbnew.
7. **`bt islands --fix` put ground tracks on In1 and In2**, the plane layers `bt route` otherwise stays off.
8. **`bt route --from x,y,B.Cu` starts from a bare coordinate.** When my `bt apply --checked` for the start via
   had failed one line earlier, the routes still "succeeded" from a point with no copper under it, and I had
   three tracks ending in nothing. It should require copper of the net at the start point.
9. **`bt near --each … --side B`** puts the capacitor pad exactly under the IC pin ("0 mm"), which only works
   with via-in-pad; for decoupling I wanted "pad next to a via site". I placed both decoupling rings by script.
10. **`bt via --near`** prints only the first of the eight reasons unless one scrolls; fine, but when it says
    "no via spot within 3 mm" a probe of hand-picked spots sometimes found one (smaller search step?).
11. **`bt cleanup`** drops "dead ends" but left the 0.4–1.8 mm stubs I had created; I removed them by uuid.
    I also suspected it of flattening tuning bumps (it had not – see point 1), which shows the help should say
    whether it preserves them.
12. **`bt route` on a power-class net** uses the class width and then reports the target "boxed in" at fine-pitch
    pins; `--width 0.2` fixes it, a hint in the failure would help (it does suggest a narrower width – but not
    that the class width was the reason).
13. Minor: `bt place` exit code 1 with the reason several lines above the tail; `bt rules` cannot set
    `min_resolved_spokes`; `bt zone` cannot be given several zones in one call (17 fills avoided only with
    `--no-fill`).

## What I did myself instead, and why

- **All differential pairs** (PCIe, USB, Ethernet): generated geometry from centre lines in Python, because the
  pin-order problem (clock on the wrong side, P/N mirrored) needed a deliberate layer plan that no router
  call expresses, and because `bt pair` did not hold the pair together.
- **Placement**: a Python/pcbnew script with a buck "template" and transforms; `bt place` only for late moves.
- **Buck stages, power-pin fan-outs, decoupling rings, connector ground vias**: scripted items files, probed.
- **A neighbour check** (`scripts/pair_neighbours.py`): which foreign tracks run within N mm of a pair on the
  same layer. `bt` has nothing like it and KiCad's DRC cannot see it.

## What I would change, add or remove

- Add net-class "keep away" distances and pour protection to `bt route` (point 2). This is the biggest gap.
- Add a pair-neighbour / parallel-run report (`bt crosstalk --class PCIe --within 0.5`).
- Make every trial end with one unmissable line; make `tune` write like its neighbours or say it did not.
- `bt route --nets`: time proportional to length, and a `--exclude` list (I wanted "everything except these").
- A pin-escape mode that uses the space *inside* a QFN pin ring (stub to a via between pins and exposed pad);
  I did this by hand for 30 pins and it rescued every boxed-in pin.
- `bt same` should also compare the texts of locked footprints; `bt silk --fix` should skip locked parts.
- Fix the `check` / `--refill` crash.
- I would not remove anything; the commands I skipped (`fan`, `escape`, `plane`, `bus`, `planar`) looked
  sensible, I simply had scripts by then. `bt help` is long but the examples in it were what I actually read.

Overall: as a *checker and applier* for copper I describe myself, `bt` was excellent and I would not want to do
this job without it. As an *autorouter* it needs constraints I had to supply by hand after the damage was done.
