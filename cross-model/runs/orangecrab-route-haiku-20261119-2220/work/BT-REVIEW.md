# bt review (from this routing session)

I used `bt` a lot, and it is the reason the board has the amount of copper it has. It is also the reason the rest is
not finished: the router could not handle the FPGA periphery, and a few `bt` decisions were wrong for blind microvias.
Counts below are rough, from my command history.

## Commands used, and how often

| Command | Uses | Verdict |
|---|---|---|
| `bt route` (per net, `--all`, `--nets`, `--batch`) | ~60 | Most used and most important, and the most frustrating. Good: `--all` on a power net with `--layers` and `--max-vias` (VDD 14/14, VDDQ 15/15, P3.3V 30/30 links) and `--batch` with explicit `from`/`to` on In4. Bad: on the crowded FPGA periphery, `--nets` runs spent 10-20 minutes in shove/rip passes and mostly failed ('boxed in', 'walls in'). |
| `bt probe` | ~20 | Excellent for checking candidate stubs and vias against the whole board, including In2/In4 and B pads. The microvia false positives (below) were the only problem. |
| `bt apply` (`--checked`) | ~15 | Reliable; the "copper twice" warning after a re-probe is confusing. "removed N items" after a SPLIT is not explained. |
| `bt render` | ~12 | Essential. `--layers In4.Cu` and `--box` showed congestion that the text output could not. |
| `bt ratsnest` | ~15 | Good for the open list; the group coordinates helped locate pieces. The "groups" count includes decoupling and source pads, which is easy to misread. |
| `bt fan` | ~6 | Did the FPGA and DDR3 signal escape in one call each (103 and 50 nets). Costs: it gives poured (GND/power) pads through vias greedily, so I had to clear those pads on a scratch copy; and `--layers F.Cu,B.Cu` (second row on B) left 76 pins. |
| `bt via --near` | ~40 | Very useful: one call per ball, nearest legal spot, stub included. Used for the DDR3 ground and power balls after my site solver failed. |
| `bt plane` | ~6 | Works, but `--ref` takes a regular expression, not a glob list. A glob list returned "0/0 pads" with no warning. |
| `bt rules` | ~8 | Setting the net classes was clean. Every call re-prints the whole class list, which is noisy. |
| `bt check` | 3 | The best single view: KiCad DRC, unconnected, pieces, and bt's own checks in one. The "refilled ... old" message was useful. |
| `bt islands` (`--fix`, `--dry`) | ~4 | Good diagnostic for the GND pieces ('no join found: boxed in'). `--fix` only found 2 of 16 joins. |
| `bt congestion` | 2 | Useful. The "IC pins with one way out or none" list pointed at the right pins. |
| `bt unroute`, `bt rm` (uuid, point) | ~8 | Good, with the per-net "comes apart" report. |
| `bt undo` | 2 | Saved me once: I rebuilt from an undo state after the DDR3 routing was blocked by rails I had routed first. |
| `bt fill`, `bt zone` (GND In1/In3) | 4 | Zones and fills worked. |
| `bt query`, `bt nets`, `bt part`, `bt board` | ~15 | `bt board` is about 34 KB of text for this board, which costs a lot of context. A summary mode would help. |

Not used: `bt bus`, `bt pair`, `bt tune`, `bt planar`, `bt escape`, `bt stitch`, `bt length`, `bt cleanup`,
`bt outline`, `bt silk`, `bt place`, `bt near`, `bt same`, `bt drc --baseline`. I did not need placement tools (placement is
fixed), and I ran out of routing approaches before I got to length matching (`bt bus`/`bt tune` are the next step).

## What helped, roughly

- The fan and the probe made the first FPGA and DDR3 escape possible in a few calls. Without them I would have written
  the whole fan-out myself. The probe was the safety net for every write.
- `bt route --all` on power nets (a few calls) replaced what I would otherwise have hand-routed for 20-30 links.
- `bt via --near` replaced an unworkable site search for the DDR3 balls.
- `bt check` gave one line to trust or distrust a state. I used it at each milestone.
- `bt undo` plus the `.bt-undo` copies made the order experiments cheap.

## What got in the way (with the command)

1. **Microvias are treated as through vias everywhere.** `bt probe`, `bt route`, `bt islands` and `bt check` all
   see a `(via micro ...)` as a hole in every layer. With 126 ground microvias in the file, In2, In3, In4 and B.Cu were
   blocked around the FPGA, and `bt route` failed on I/O nets that had clear paths (2 of 17 routed, against 25 of 74 when
   the microvias were out). `bt probe` also reported microvias as "0 of 16 clear" because of the drill minimum for
   through holes. I had to strip the microvias from every routing copy with a text edit, route, and put them back.
2. **`bt route` cannot start from an inner-layer via.** With `--max-vias 0` and `--layers In4.Cu`, every power link
   failed with 'the start is boxed in' because the start was the ball on F.Cu. The fix that worked was explicit
   `from x,y,In4.Cu` / `to x,y,In4.Cu` requests from a batch (MST over the via points), which is not obvious from the help.
3. **Shove and rip-up are slow and often no use on crowded boards.** `--passes 2` or `3` with `--move-board` ran for
   10-20 minutes and only reported "could not be put back" for the nets it tried to move. The output at least names the
   nets and the blockers, but I could not act on it except by stopping the run.
4. **Blocking messages do not say what to change.** "walls in U6.4 (GND), leaving no way out: route that pad first, or plan
   the area by hand" is correct but leaves me to find the pad order by trial and error.
5. **`bt plane --ref` glob/regex confusion** (see the table): a silent "0/0 pads to the plane".
6. **Background runs.** Anything over about 100 s needs `nohup` and a progress file. `--progress` was good; the
   wait loops I wrote around it were the main cost in time.
7. **`bt fan` gives poured pads vias.** For a BGA with GND and power on the same grid, I had to clear those pads on a
   scratch copy to get the signal-only escape. A flag to skip nets (or to reserve sites) would avoid the copy.
8. **Output size.** `bt board` (34 KB here) and `bt rules` (repeats the classes on every write) use a lot of context.
9. Small: `bt probe` after `bt apply` reports "copper twice" for copper that was just written; `bt apply` reports
   "removed 1 items" for a SPLIT without saying which segment it removed.

## What I did myself, and why

- **Site solver for FPGA ground and power balls** (`scripts/bga_sites.py`, `bga_assign.py`): `bt fan` gave through vias
  to poured pads greedily and left 62 pins with no via. I needed one site per ball with a constraint search, and no
  `bt` command reserves sites or assigns them.
- **Ground bridges** (`scripts/gnd_bridges.py`): `bt` has no way to bridge same-net adjacent pads on a BGA field, and
  one microvia per ball was the bottleneck for everything else. The bridge solver cut 126 microvias to 16.
- **Microvia insertion and removal as text** (`insert_microvias.py`, `strip_microvias.py`): `bt` has no microvia type.
  pcbnew writes `(via micro ...)` the same way, which I checked.
- **MST batches for power rails and I/O** (`rail_mst_batch.py`, `io_mst_batch.py`): needed for the In4 rail routes
  (item 2 above).
- **Order decisions** (DDR3 before rails; the FPGA I/O on In1 after the ground bridges): `bt` has no planning step for
  this; `bt planar` and `bt congestion` would have been the tools to look at it first, and I did not use `bt planar`.

## What I would change, add or remove

- **Add blind and buried microvias as a first-class via type**, with the layer pair. Probe, route, islands and DRC should
  all use it. This is the single change that would have saved the most time here.
- **Add a BGA site-assignment command**: given a part, the nets (or groups), the via type, and the planes, choose one
  site per pin under the clearance rules, and report which pins it could not place.
- **Add same-net bridging for fine-pitch fields** (or let `bt fan` take a list of nets to skip).
- **Improve `bt route`'s diagnostics**: name the blocking net and item, and say which pad order (or which `--through`
  point) would free it. Allow `--through` lists to be given per net in batch requests with the layers.
- **Make shove and rip-up cheaper**: a per-pass time budget, and a clear "moved N copper items of net X, reconnected: yes/no".
- **Make `bt plane --ref` accept globs (or warn on a pattern that matches nothing).**
- **Summaries by default**: `bt board --summary` (counts, open nets, zones) and quieter `bt rules` output.
- **Remove or fix**: the "copper twice" text after a probe; the "removed N items" for a SPLIT.

I did not use `bt` for anything I could not verify with `bt probe`, `bt check` or KiCad's DRC.
