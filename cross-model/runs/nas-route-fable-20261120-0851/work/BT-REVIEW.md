# bt review – RaspberryPiNVMeNAS routing session

Counts are from memory of the session, so approximate (±20 %).

## How the board was actually made

About 70 % of the copper (all 15 PCIe pairs, Ethernet, USB, the U12 breakout, the RP2040 fan-out, the CM4 left connector, SD, buses, power taps) came from my own Python scripts that emit `items.json`, checked with `bt probe` and written with `bt apply --checked`. `bt route` did the short local nets, the buck feedback/boot nets and about 25 long slow nets across open board. Pours, pad vias, stitching, skew tuning and DRC were all bt.

## Commands used

| Command | ≈ calls | Verdict |
|---|---|---|
| `bt probe` | 45 | The most valuable command. 1 s answers, exact gap and the object hit. Caught roughly 60 mistakes in generated geometry before anything was written. |
| `bt apply` (mostly `--checked`) | 60 | Backbone of the workflow. Never wrote a bad file. |
| `bt route` single link / `--all` | 25 | Good in open space and for "finish this net". Failure messages name the blocking object, which is what I needed. |
| `bt route --nets` batches | 12 | Mixed: see below. |
| `bt zone`, `bt fill` | 14 / 20 | Worked every time, kept the .kicad_pro intact. |
| `bt ratsnest`, `bt length`, `bt query`, `bt part`, `bt vias`, `bt board` | 25 / 6 / 8 / 6 / 2 / 1 | Fine. `ratsnest` counting pours is what made "is power connected" a one-liner. |
| `bt rules` | 25 | Used far more than expected: also as a trick to keep the router and via tools away from pairs (raise the PCIe class clearance, route, set it back). |
| `bt plane` | 4 | 164 GND pad vias in one call, all legal. Big time saver. Needed clean-up for a few vias (below). |
| `bt stitch` | 1 | 300 vias, none wrong, sensible exclusions reported. |
| `bt tune` | 30 | Did the job: 15 PCIe pairs to ≤0.17 mm, Ethernet and USB to 0. One trap (below). |
| `bt via`, `bt escape`, `bt islands` | 14 / 1 / 3 | `via --near` and `escape` explain why a spot fails; that is what makes them usable. |
| `bt rm`, `bt unroute`, `bt cleanup`, `bt undo` | 12 / 14 / 3 / 2 | Fine. The "comes apart: 1 → 2 pieces" line is useful. |
| `bt drc --baseline` | 10 | Exactly the view I wanted: only what I caused. |
| `bt render` | 30 | Needed, but see below. |
| `bt check`, `bt drc --refill` | 1 / 2 | Crashed. |
| `bt same` | 1 | Used, then double-checked with pcbnew. |

Not used: `fan`, `bus`, `pair`, `offset`, `planar`, `congestion`, `near`, `place`, `outline`, `silk`, `seg`, `merge`, `free`, `gap`. For the pairs I wanted tandem-via polarity swaps, fixed lane positions and hand-made pin fan-ins, so I wrote a 20-line offset function instead of finding out whether `bt pair`/`bt offset` could express that. `bt planar` would have told me in one call what I worked out by hand four times (REFCLK is on the wrong side at every socket; SD order at the CM4). I should have tried it.

## What helped, and how much

- **probe + apply --checked**: without them I would have needed KiCad DRC round trips (25–30 s each) for every generated batch. Roughly 100 such checks at 1 s instead of 30 s, and far fewer tokens because the answer is one line per problem.
- **plane / stitch / tune**: each replaced work I would otherwise have scripted (an hour or more each).
- **route in open space**: the eight long nets of the last batch took 9 minutes of machine time and no thought. By hand that is an hour.
- **Failure texts**: "blocked by track t1825 (CM4_BOOT) at …", "65 too close to pad C77.1", "a via fits 1.975 mm out" – these told me what to move.

## What got in the way or was wrong

1. **`bt check` and `bt drc --refill` crash** with `error: Maximum call stack size exceeded` (exit 2) once the board had four GND pours and ~750 vias. Plain `bt drc --baseline` kept working. I verified fill freshness with pcbnew instead.
2. **`bt tune` without `--apply` writes nothing and does not say so.** It prints "44.284 → 47.415 mm (+3.131: 4 bumps…)" exactly as a real run does. I ran eleven pairs, believed them done, and only noticed when `bt length` had not changed. Every other trial command says "trial only" or "board unchanged".
3. **`bt route --nets` on a dense QFN (RP2040)**: 11 of 22 nets, one net necked to 0.127 mm for 11.9 mm, the rest boxed in. `bt route --net +3.3VSTB --all --no-vias` joined the supply pins with a ring inside the pad row and long links across the pin exits, walling the signal pins in – the "way out kept free" guard did not stop it. I threw both away and fanned the chip out by hand.
4. **`bt route --nets` round the CM4 connector**: SD_DAT3 came out 57 mm for a 31 mm link, ETH_LED1 with 4 vias, I2C with 4–7 vias. Legal, not acceptable. Pin order decides everything there and the router has no notion of it (`--order escapes-first` did not help).
5. **Router goes through other nets' pours on the same layer** (cost 2.5×). It put TSENSE_0 through the +3.3VA bottom pour and, earlier, a track across the 1.2 V feed strip. The single-link output warns ("runs through other nets' pours: 3.5 mm"), the batch summary did not show it where I looked. I ended up generating `--avoid` boxes from my zone list with a script, and wrote a second script to find tracks inside foreign pours. A `--no-cross-pours` switch, or treating pours with priority > 0 as hard obstacles, would remove both scripts.
6. **`"remove": [uuid-start]` in items.json was not honoured by `probe`/`apply`**: the probe reported clashes with the very vias listed for removal. `bt rm --uuid` with the same 8-character starts worked, so I removed first and applied after.
7. **`bt plane` puts vias in the escape path of neighbouring pins**: for C82.1 it chose a spot 1.5 mm past pin 9 of the QFN, straight in its way; for the pull-up row it put two vias in the only band the LED lines could use. After I removed vias, the stubs stayed and `bt cleanup` kept them ("longer than --stub … net is not one piece yet").
8. **`bt render`**: in zoomed crops the picture is shifted about 0.3 mm against the grid labels and F.Cu pads are drawn over B.Cu tracks. Twice I thought a pair was missing and had to `bt query` to be sure. With pours filled, everything is tinted and small tracks are hard to see; I found no switch to hide fills.
9. **`bt zone` false alarm**: "9 pads of +3.3V_M3 just outside the outline (not joined by this zone)" for connector pins whose pads overlap the outline by 0.6 mm; they were joined after the fill.
10. **`bt islands --fix` and `bt ratsnest` disagree on what is isolated**: islands listed R35.2/R39.2/C86.2 as unjoinable but not the CM4 GND pins that ratsnest listed, and the reverse a refill later. Ratsnest truncates the piece list at 8 ("… 292 pads"), so I had to parse it to get the pad names.
11. **"--width never takes a net under its class's width"**: sensible default, but I had to move the switch-node nets and +3V3 out of the Power class to get a thin boot-cap trace or a pull-up stub.
12. **`bt ratsnest` header** says "9 nets not fully connected" while listing one (GND).
13. **`bt same`** answers "nothing locked moved". Only the CM4 is locked on this board, so it is unclear whether the other 253 footprints were compared. I compared them with pcbnew.
14. **Speed**: `--nets` batches ran 5–9 minutes; LED_V+ needed 20–35 s per link. Fine in the background, long when waiting.

## What I did myself instead, and why

- Pair geometry, tandem-via polarity swap, lane planning, QFN and connector fan-outs: scripts. The tool has no way to say "these six pins leave north, turn east in this order and peel off into those headers", and that is 80 % of the difficulty of this board.
- Keep-out list from pours, tracks-inside-pours check, foreign vias in pours, fill-freshness check, footprint comparison: pcbnew/shapely scripts (items 1, 5, 13 above).
- Rule areas (pour keep-outs at starved thermals): pcbnew, since `bt zone` has no keep-out type. Saving through pcbnew rewrote the .kicad_pro as warned; I restored my copy.
- Impedance: own field solver. bt has nothing for it.

## What I would change, add or remove

1. Fix the stack overflow in `check` / `drc --refill`.
2. Make `tune` say "TRIAL ONLY" like the others, or write in place by default.
3. `route`: an option that makes foreign pours hard obstacles; and print the pour warning in the batch summary line.
4. `route --nets`/`plane`/`stitch`: a per-call keep-away, e.g. `--keep-away "PCIe*:0.35"`, instead of editing the class clearance and restoring it.
5. A **pin-order fan-out for QFN sides and connector rows with given targets** ("these pins to these pads, no crossing, lanes at pitch P") – the thing I scripted five times. `bt planar` output feeding a lane generator would be enough.
6. A jog helper for parallel lanes (shallow or staggered jogs): 45° jogs of 0.4 mm-pitch neighbours always end 0.083 mm apart and I hit that four times.
7. `plane`: respect the same pin-exit lanes as `route`, and take the stub out again when its via is removed.
8. `render`: `--no-fills`, B.Cu on top option, and fix the crop offset.
9. `zone`: rule areas (no-pour, no-via), and a `--thermal-min-spokes`-style report so starved thermals show up before KiCad DRC.
10. `islands`/`ratsnest`: one consistent list of isolated pads, untruncated on request.
11. Honour uuid starts in `"remove"` or reject them loudly.
12. Nothing to remove. The commands I did not use were unused by my choice of method, not because they looked wrong.
