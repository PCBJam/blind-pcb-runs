# bt review (ESP32-P4 RedBoard routing job)

Honest summary: `bt` was worth having. The check/write half (`probe`, `apply --checked`, `query`, `part`, `render`, `ratsnest`, `plane`, `zone`, `tune`) saved a lot of time and mistakes. The routing half (`route --nets`, `pair`) was useful for easy nets and a liability around the dense QFN and for power, where I ended up computing coordinates myself and using bt only to verify them.

Counts are approximate (from memory of the session).

## What I used, and how it went

| command | uses | verdict |
|---|---|---|
| `bt board` / `bt nets` | 3 | Very good first look: whole netlist with pad coordinates in one text file. I planned the entire floorplan from it. |
| `bt part` | ~8 | Good. Pad numbers, nets, positions. Missing: the pad's rotated bounding box. "rect 0.6x1.5 270°" made me get the extents of rotated pads wrong twice; I wrote a pcbnew helper to print boxes instead. |
| `bt render` | ~15 | Essential without a GUI. `--layers`, `--nets`, `--no-rats`, `--box` all worked. Footprints named `kibuzzard-…` clutter every picture; an option to hide refs by pattern would help. |
| `bt probe` / `bt apply --checked` | ~40 | The most valuable pair. Every hand-computed track went through it; it caught ~35 clearance slips at 0.01 mm level and names the offending item. `removeAt` in the same file is handy. |
| `bt query` | ~8 | Good for "what is in this box", used to diagnose blocked routes. |
| `bt ratsnest` / `bt length` | ~20 | Good. `length` counts every stub of a net, so pair skew numbers include test-point stubs; say so in the output. |
| `bt zone`, `bt fill` | 6 | Worked first time, .kicad_pro untouched (I checked with cmp). |
| `bt plane` | 5 | Good for bulk GND/3.3V pad vias and it knows which pour a via lands in. It shares vias too eagerly for decoupling caps (three caps on one via 1.5 mm away), so I placed those by hand first. For a part made of nine separate "EPAD" pads it reported nine "shares via" on a via that touched none of them. |
| `bt tune` | 6 | Worked well: matched five MIPI pairs in one call each. Could not finish one (1.5 mm left) and said so clearly. |
| `bt route --nets` | ~15 | Mixed, see below. |
| `bt route --net … --from/--to` | ~10 | Fine for single links when a path exists; the "blocked by … at x,y" output is useful. |
| `bt unroute`, `bt undo` | ~10 | Needed often, worked. `unroute --box` and `--layer` are useful. |
| `bt drc` | few | Good grouping and baseline idea. |
| `bt pair` | 1 | Failed at once at the QFN pins ("boxed in for a 0.15 mm track with 0.35 mm extra clearance") and I did not go back to it; every pair was hand-computed. |
| `bt outline` | 2 | Used only as a work-around (below). |
| `bt congestion` | 1 | Crashed (below). |
| `bt fan`, `bus`, `escape`, `stitch`, `place`, `near`, `silk`, `islands`, `cleanup`, `gap`, `free` | 0–1 | Not needed or not reached; the QFN escape here depends on which caps sit in front of which pins, which I did not expect `fan` to solve. |

## Things that went wrong or confused me

1. **Outline inside a footprint.** This board's Edge.Cuts lives in the locked footprint H1. `bt board` said "outline doesn't close (its 0 Edge.Cuts pieces still count as edges), box Infinity…", `bt render` drew a blank picture without `--box`, `bt congestion` died with `error: Invalid array length`, and — the bad one — every `bt probe` reported `board edge gap -0.064 < 0.076` for every segment anywhere on the board (it seems to treat the footprint's lines as a cutout covering everything). Adding a board-level outline with `bt outline` did not help while the footprint lines were still there. Work-around: I moved H1's nine lines to User.5 by sed, added a board-level outline, and reverted both at the end. bt should read footprint Edge.Cuts like KiCad does.
2. **`bt route --nets` writes partial results for nets it then reports as GAVE UP**, and shove passes "removed N of the board's own tracks". After a failed batch I several times had to work out what had changed. A net that fails should leave the board as it was.
3. **Power nets get hairline necks silently.** With `--width .45` the VRAW/VBATT/5V routes at a SOT-583 came back with 0.122 mm segments several mm long (including the main supply path under the IC) and reported "ok". The neck rule is right at the pad, but it should be limited to a short length and reported.
4. **Router put a 0.25 mm VDD_SD trunk diagonally under the whole QFN on B.Cu**, cutting the underside in two and making two other rails unroutable. Nothing wrong by the rules; a designer would not do it. A "keep out from under this IC" default for non-local nets, or a cost for splitting free area, would help.
5. **Order sensitivity of `--nets`.** The six SD lines routed 6/6 in default order (with 12–33 mm length spread), 5/6 with the clock first and `--max-detour`, 3/6 in a third order; `--rip` then failed with "could not be put back". There is no way to ask for "these six as a group, similar length".
6. `bt route` runs longer than the 120 s tool timeout fairly easily; `--budget` only counts between nets. A hard wall-clock limit would be useful.
7. Net-class patterns with parentheses (`Net-(J5-Pin_1[4578])`) did not match in bt's reading of the .kicad_pro; plain names did.
8. `bt plane` / `route` report vias as fine that sit in solder pads' edges etc.; that is my decision to make, but a note "via overlaps pad X" would be welcome.

## What I did myself instead, and why

- All differential pairs, the QFN-104 escape on four sides, the SDIO bus, crystal, decoupling links and the regulator areas: a 60-line Python helper (pcbnew for pad positions, mitred polyline offset) writing bt's `items.json`. Reason: the geometry is decided by which 0402 sits in front of which pin and by 0.39 mm slots between caps; I needed to choose lanes, not search for them. bt's part was the checking, which is exactly what I wanted from it.
- Net classes: edited the .kicad_pro JSON directly.

## What I would change / add

- Read Edge.Cuts from footprints (blocker on this board).
- `bt route`: atomic per net; never return success with a neck longer than ~1 mm on a net whose class width is larger; an option `--max-neck-length`.
- A bus/group mode for single-ended groups with a length window.
- `bt part --boxes` (rotated pad extents) and a `bt slot A B` that says what track width fits between two pads (I used `gap` too little because I already had boxes).
- `bt pair` should accept a necked first few mm at pins instead of failing.
- Render: hide references matching a pattern; draw In1/In2 fills in different colours when `--layers` has both.
- Keep: probe/apply --checked, removeAt, undo, the terse text output. Those are the reason the hand-routed parts took minutes rather than hours.

## Addendum after the second half of the job

More counts: `bt route` in batches ≈ 10 runs covering ~70 nets, single-net `bt route` ≈ 40 calls, `bt probe`/`apply --checked` ≈ 90 in total, `bt query` ≈ 30, `bt unroute` ≈ 15, `bt fill` ≈ 20, `bt stitch` 2, `bt same` 1, `bt drc` 3 (for the final check I used `kicad-cli pcb drc --format json` directly, because I wanted the item list per violation and schematic parity).

What the second half taught me:

- **The best pattern was: I fix the structure, bt does the legs.** After I laid a fan-out bus with an ordered via row by script, `bt route --nets … --order given --passes 1 --max-detour 1.7` routed 12 header nets first time, 37–47 mm, one via each. Before that, the same router on the same nets produced 45–66 mm routes with up to 6 vias and blocked six others. So the router is fine at "go from here to there"; it has no idea about escape order, and nothing warns that the order is wrong.
- **`--passes 1` (no shove) and `--fixed` should be the defaults** on a partly hand-routed board. Shove passes moved or removed tracks I had placed deliberately (once a USB track, several times power), and I only saw "removed N of the board's own tracks".
- **A killed `bt route` kept running.** I killed the shell script; the node process survived, finished its net minutes later and rewrote the board from its own in-memory copy, silently undoing an `unroute` and an `apply` done in between. bt should re-read (or at least check the mtime of) the board before each write, or take a lock file.
- **Allowing `In2.Cu` as a routing layer** closed a dozen nets that were topologically impossible on two layers — useful — but the router treats a plane layer as just another layer: it ran slow signals straight through a power island and through the neck of its feed, and `bt ratsnest`'s "(poured; fills counted)" only showed the damage after the next `bt fill`. A cost for cutting a zone into two pieces (or a warning "this track splits zone X") would have saved me hours; I ended up deleting the island and discovering isolated plane pockets one at a time with pcbnew's `GetConnectedItems`.
- `bt ratsnest` names one missing link per pair of pieces but not which pads are in the small piece. For plane nets that is the question. A `bt islands`-style listing of "piece 2: C20.1, U1.62, via @…" would have told me at once that a two-pad pocket was stranded, not half the board.
- `bt stitch` without `--through-pours` found 9 spots on a 66×58 mm board; with it, 33. Fine, but the default made me think it had failed.
- After I put the outline back into the footprint (as the original has it), `bt probe`, `apply --checked` and `render` are unusable again on the delivered file. That is the first bug in the list above and it is the one I would fix first.
- Small things: `bt route --from x,y,L` with a start that is not on copper of the net fails with "boxed in" rather than "start is not on the net"; `bt length` and pcbnew call In2 "In2.Cu" and "L3.Cu" respectively on this board, and `removeAt` needs bt's name.

Net judgement: for checking and applying hand-computed geometry bt was excellent and I would not have attempted this board without it. For autorouting around a 0.35 mm QFN it cost me more time than it saved until I changed how I used it. About a third of the board's copper (all controlled-impedance pairs, the QFN escape, buses, regulator areas) is hand-computed and bt-checked; the rest is bt-routed legs and power trunks that I reviewed, widened or replaced.
