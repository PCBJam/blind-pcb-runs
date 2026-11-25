# BT-REVIEW: bt on this board

Scope: I used bt for almost everything in this job (placement, planes, escape, routing, checks), and I did not use it for a few things I should have. Numbers below are from my session logs; counts are approximate.

## Commands I used, and how often (approximate)

| command | uses | verdict |
|---|---|---|
| `bt board`, `bt nets`, `bt part`, `bt query`, `bt rules`, `bt free` | ~25 | essential at the start. `bt board` is long (350 lines) but the single most useful dump. |
| `bt render` | ~10 | used for progress images. Clear, with layer colours and the grid. |
| `bt near --each` | ~15 batches | the workhorse for decoupling and small parts. Excellent trial output. Weak point: no keepout box, so the nearest legal spot is often inside an escape field (under the BGA interior, under the DDR3 field, in the channel). I had to move caps by hand three times. |
| `bt place` (trial, then `--apply`) | ~25 | reliable for courtyards and locked parts. It did not flag a mux pad overlapping the header's through-hole pads on the other side; only the KiCad DRC run (`bt check`) found that short. |
| `bt fan` | ~8 | the best BGA tool here. Escape plan, exits per side and layer, clear reasons for pins left. Problems below. |
| `bt probe --vias` / `bt probe` | ~8 | excellent for checking 36 via-in-pad candidates in one call, each alone. |
| `bt apply --checked` | ~10 | safe and reliable. Every apply I made was clean. |
| `bt zone` | ~12 | fast and correct. Warns about locked pads that hang over the outline. |
| `bt check` | ~8 | the most useful overall check. A stale `--no-fill` run misled me (see below). |
| `bt route --nets` | ~8 runs | works, but slow when the board is congested (20 s per net, pass 2 about 20 s per net), and most failures are "boxed in". |
| `bt stitch` | 2 | good: it proposes only vias that land in two same-net pours. |
| `bt islands` | 2 (read-only) | informative: it says which pieces each pour could join and how. I did not get to `--fix`. |
| `bt rm --uuid --dry`, `bt vias`, `bt unroute --dry` | ~8 | good preview output. |
| `bt undo` | 1 (incident, below) | saved me, but see the incident. |
| `bt rules --class` | ~6 | changes the .kicad_pro only, as stated. Clean. |
| `bt bus`, `bt pair`, `bt planar`, `bt tune`, `bt cleanup`, `bt silk --fix`, `bt outline`, `bt seg`, `bt merge`, `bt offset`, `bt drc --baseline`, `bt escape` | 0 | not used. Reasons: the DDR3 bus and pair tools might have helped with the lanes, but the field was already saturated; `bt silk --fix` and `bt outline` were not in scope; `bt drc --baseline` I replaced with an equivalent comparison on a copy of the original board. |

## What helped most
1. `bt fan` for the FPGA and DDR3 escape plan. It told me exactly which pins had no way out and why ("walls in ..."), which is the information needed to move parts.
2. `bt probe --vias` before writing 36 power vias. One call, each candidate checked alone.
3. `bt near --each` for the decoupling caps. It turned a 40-cap task into a few commands.
4. `bt check` as the single gate: fills refreshed, KiCad DRC, unconnected count, bt's own checks.
5. The progress lines from `bt route --progress`. Clear, and the failure messages name the blocking pad and track.

## What got in the way, with the command and what happened

1. **Board overwritten (serious).** `bt unroute OrangeCrab.kicad_pcb --nets ... -o /work/OrangeCrab.kicad_pcb`. The `-o` expects an items JSON file; the tool wrote the items JSON into the board file itself (5 KB, exit 2). Every later bt command then printed `error: n2.filter is not a function`, which looked like a tool bug. `bt undo` restored the version from before the last successful apply, which was not the state I wanted, so I lost the routed DDR3 nets until I re-applied the saved items file. Suggested fix: refuse `-o` with a `.kicad_pcb` path on any command that takes items; never let an error path leave the board file replaced; keep the pre-write copy in the undo folder even for failed writes.

2. **Stale fills.** After adding vias, `bt check --no-fill` reported 576 DRC errors. The same board after a refill had 86, all from the original locked parts. The tool does say "fills as saved", but the number is easy to misread. Suggested: make `--no-fill` print a loud line when the saved fill is older than the copper, and default to a refill.

3. **Escape planner ground vias.** `bt fan` plans vias for ground and power pins too. On the FPGA that was 100 ground vias, which would have cut every interior power plane. Passing `--planes` without GND made it escape the ground pins as signals (107 nets, many nonsense exits). I had to filter the `-o` items JSON by net. Suggested: a `--skip-nets GND` (or "leave to pour") option that plans no escape and no via for those pins.

4. **Clearance taken from the net class.** `bt fan` used the largest class clearance of the nets around a via. My Power class (0.15 mm) and USB class (0.15 mm) stopped the escape ("a 0.28 via doesn't fit ... at most 0.177 mm"). Lowering the classes fixed it, but the error does not say which class is responsible. Suggested: name the net and class that set the clearance.

5. **`bt near` has no keepout.** Caps were placed under interior BGA balls and in the DDR3 field because they were the nearest legal spots. Suggested: `--avoid` boxes (the same as `bt route --avoid`), and a warning when a spot is inside a fine-pitch escape field.

6. **Route speed on a congested board.** `bt route --nets` spent 20 s per failed net in pass 1, and pass 2 (shove) was slower. Short searches (`--seconds 5`) were 4x faster and found about as many routes. Suggested: a default time budget scaled to congestion, and a summary of why each failed net failed, grouped by blocker.

7. **Background runs.** A run started with `nohup` in a subshell kept running after the tool call ended, and I started a duplicate by mistake. `run_in_background` is the right tool; the log file showed the state.

8. **Locked footprints and DRC.** The 84 edge-clearance errors come from locked Feather pads, which bt reports in the check list. Good, but it would help to have an option to mark known/locked issues so the CHECK FAILED line only counts new ones.

## What I did myself, and why
- Chose the floorplan, rotations and the layer stack; bt does not decide these. The orientation scoring was a 30-line script.
- Put the DDR3 caps on the back in two outer columns and moved the rest by hand, because bt near had no keepout.
- Wrote the FPGA's 36 power via-in-pads myself (using `bt probe --vias` to check them).
- Kept the ground vias out of the interior by filtering the fan output by net.
- Did the DDR3 field clean-up (removing the fan's ground vias) by hand, after reading the blocking messages.

## What I would change or add
- A keepout option on every placement tool, and a "what is my spot blocked by" report for near.
- An explicit "skip these nets" for the escape planner.
- Safer `-o` handling and undo history that keeps the state before every write, including failed ones.
- A `bt status` command: routed/unrouted nets per group (DDR, IO, power), DRC errors minus the locked baseline, and the next blocker. I wrote this by hand several times.
- Faster failure in pass 1: give up after a budget per net, and report the blocker groups at the end.
