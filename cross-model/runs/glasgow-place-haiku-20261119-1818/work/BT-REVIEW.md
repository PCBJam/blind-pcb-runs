# bt review (from this layout session)

Counts are approximate (from my command history for this session). "Helped" means I could see the effect in the board or in the time it took.

## Commands I used, and how often

| command | uses | notes |
|---|---|---|
| `bt route` (incl. `--dry`, `--all`, `--nets`, `--shove`, `--rip`) | ~70 | the most-used, and the least satisfying (see below) |
| `bt ratsnest` | ~30 | the status check after every step; "fills older than the copper" warning was useful |
| `bt apply` (incl. `--checked`) | ~25 | the safe write path; refused conflicting sets |
| `bt zone` / `bt fill` | ~25 | zones on In1/In2; fill after every apply |
| `bt place` (trial, `--pads`, `--apply`) | ~35 | placement moves; `--pads` was how I checked B-side pin mapping |
| `bt near` (single, `--each`) | ~25 | decoupling (81/83 in one call) and small parts |
| `bt pair` | ~25 | USB pair, Z-port pairs |
| `bt render` | ~25 | the most useful diagnostic: zoomed renders found the BGA-interior and bottom-layer blockages |
| `bt via` (incl. `--near`) | ~20 | `--near` was the workhorse for per-pad plane vias |
| `bt rules` | ~10 | net classes and the via sizes; changes only the .kicad_pro |
| `bt board`, `bt part`, `bt nets`, `bt query` | ~30 | reading pins and nets |
| `bt fan` | ~8 | FPGA escape; one run applied (91 nets) |
| `bt unroute`, `bt rm` | ~15 | lifting nets to re-route them in another order |
| `bt free` | ~5 | finding bottom-side space |
| `bt check`, `bt drc` | ~8 | `bt check` at the end; DRC for courtyards |
| `bt same` | ~4 | confirmed no locked part moved |
| `bt islands` (incl. `--fix`) | ~4 | GND pieces; `--fix` joined 16 pieces correctly |
| `bt silk`, `bt cleanup`, `bt bus`, `bt length` | 1–3 each | `bt silk --fix` found nothing to move; `bt cleanup --dry` said the dangling ends were work in progress; `bt bus` failed on the bus |
| `bt escape`, `bt plane`, `bt stitch`, `bt tune`, `bt congestion`, `bt planar`, `bt offset`, `bt outline`, `bt seg`, `bt vias`, `bt undo` | 0 | I did not try them (see "What I would change") |

## What helped (with the effect)

- **`bt fan` on the FPGA.** It escaped 69 nets at first, and 91 of 101 after I moved the bottom-side parts out of the ball field. The per-ball messages ("via ... 0.3 mm off, needs 0.15", "row 3 deeper than 2 layers") told me what to move. Saved an hour of manual dog-bone placement.
- **`bt place --move ... --pads`.** It printed each pad's position and net after a trial move. That is how I found that a B-side part is mirrored in y, and that the SN74LVC1T45's DIR pin sits on the opposite side from A/B. I would not have caught that by reading the footprint.
- **`bt near --each` with `--side B`.** 81 of 83 decoupling caps were placed in one call (~50 s), each next to its pin. Much faster than placing them one by one.
- **`bt via --near PAD --radius 2 --apply`.** One via per surface-mount pad, applied one at a time, 193 of 206 GND pads (and 78 of 99 +3V3 pads). Reliable: each call probes the board including the vias before it.
- **`bt route ... -o file` then `bt apply --checked`.** Every route went to a file first. When two proposed sets clashed (the USB taps and bridges), `--checked` refused the set and wrote nothing. That is the feature I relied on most.
- **`bt route --shove` on CC1.** It moved only one B.Cu segment of USB_P (length unchanged) to make room. The only time shoving helped.
- **`bt islands --fix`.** Correct joins for the 16 GND pieces no pour could reach (34 segments, 10 vias).
- **`bt same`** after every placement phase: fast proof that nothing locked moved.
- **`bt render`** with a zoom box. The renders showed that the Z-port corridor was clear but the FPGA interior was not; they also showed a long bottom-layer track crossing the ball field (GNDPLL1 routing) that the numbers did not show.
- **`bt ratsnest --nets`** for checking one group at a time.

## What got in the way

1. **Routing is slow and mostly fails in dense areas.** Single-net calls took 5–20 s; a 100-net group with the default passes ran 18 minutes and finished 6 nets. `--passes 1` made it about five times faster. Passes 2 and 3 (shove, rip) rarely succeeded here; most failures ended in "boxed in". Eventually I had to stop several jobs.
2. **`--budget` does not stop a net in progress.** `bt route --net GND --all` ran for more than 15 minutes with no output and no progress line, at 100% CPU. I killed it. The per-net `--seconds` limit works, but the `--all` form on a plane net with ~200 pads did not show progress until it finished (or never).
3. **Misleading message: "courtyard reaches past the board outline".** `bt near` printed this for every candidate spot when the target pad was on a part that was not yet placed (U36 was still off-board). The real cause was that the target was off the board, and the message did not say so.
4. **`bt near --each` with spaces instead of commas** silently mis-parsed the list: "no pad U1.3 C2". The error did not say what the separator should be.
5. **`bt pair` surprises.** `--neck "0.15:box"` made the *whole* route 0.15 mm, not just the box. `--width .45` failed with "boxed in for a 0.45 mm track", but `--width .3` with no neck worked. The pair router's skew reports are good, but when the vias could not pair it printed "vias Infinity mm apart at most" and still said "ok".
6. **`bt drc --check NAME` does not filter.** It ran the whole check. Also, `bt drc` labelled `courtyards_overlap` as "(error)" while the project's rule_severities say "warning", so its summary ("15 errors") did not match KiCad's own (4 errors).
7. **`bt fan` re-planned on an edited board made things worse.** After I unrouted nets, a re-plan reported 76 fanned / 28 left, against 91 / 10 on the first run. The planner does not say which stubs are reserved for which nets, so it re-planned over copper I had removed on purpose.
8. **`bt bus` on D0..D7** failed with "the path found doesn't join the start" at points 1.2 mm from the pads. The lane start points did not match the pad positions; I could not tell which part of the bus geometry it used.
9. **Zones: no warning about pads cut off by an island.** I made +1V2, VIOA and VIOB islands on In2. Each covered +3V3 pins, so those pins were cut off from the +3V3 plane. bt let me create them without a warning. (My mistake; but a warning that "these +3V3 pads will be cut off by this zone" would have saved two steps.)
10. **Stale fills after every apply.** Twice, a new via landed in a zone whose saved fill was older, and KiCad DRC reported 4 clearance and 4 hole-clearance errors. `bt ratsnest` and `bt check` warned, and `bt fill` fixed it, but I should have been warned at apply time.
11. **Probe output shows the track, not the net context.** For a BAD via, `bt probe` names the track and gap, but I often had to `bt query` the box to see which pin it belonged to.
12. **`bt zone --delete` prints a Python/SWIG "memory leak" line** on each call. Harmless, but it sounds like a failure.

## What I did myself instead, and why

- **Placement by hand, with bt for the checks.** `bt near` on its own put the IO buffers in a clump on the FPGA's bottom-right, where the escape needs room. I placed the buffer rows on a grid and used `bt near` only for small parts.
- **Decoupling pin assignment in Python** (`scripts/assign_decaps.py`). bt does not know which cap belongs to which pin; I wrote the mapping from the netlist.
- **Per-pad via loops in bash** (`scripts/gnd_vias.sh`, `3v3_vias.sh`, `retry_vias.sh`). I did not realise `bt plane` does one stub-and-via per SMD pad of a net into its pour (I never tried it; see below). The loops worked, but they added vias to FPGA balls that were already connected, which I then had to remove by hand.
- **USB connector geometry by hand**: the B-side bridges, the U15 tap orientation (rot 180 on the B side), the order of the taps, and the choice of 0.3 mm for the pair. No tool would have chosen the U15 orientation for me.
- **Removing and re-routing nets in a chosen order** (D7, D2, FPGA_DONE) with `bt unroute` and `bt route`. bt has `--order escapes-first` and `--rip`, but neither did "inner balls first"; I did that manually.
- **Moving the FX2 up 2 mm** after reasoning about the pin maps. No tool suggested it; `bt congestion` was not run.

## What I would change, add or remove

- **Use `bt plane` for plane vias.** I should have tried it: one call per net, a stub and via per SMD pad into the pour, with the fan's exits kept free. If it works on the GND and +3V3 nets, the 200-iteration loop is unnecessary.
- **Make `bt route` stop mid-net on `--budget`** and print a progress line per net and per pass, so a plane net with ~200 pads does not look hung.
- **A `--reserve` (or `--keep-out`) option on `bt fan`**: keep the escape lanes of listed nets free when re-planning. Today a re-plan walks over the copper you removed on purpose.
- **Warnings at zone creation and at apply time**: pads of other nets on the same layer that a zone would cut off; fills older than the copper after an apply (not only in `bt ratsnest`).
- **Clearer errors**: "target is off the board / not placed" instead of "courtyard reaches past the board outline"; say which separator `--each` wants.
- **`bt pair --neck`**: say that the neck applies to the whole route when it is used this way, or apply it only inside the box.
- **`bt drc --check NAME`**: make it filter. And use the project's severities so `bt drc` and KiCad agree.
- **`bt bus`**: report the pad positions it used for each lane start, so a mismatch is visible.
- **`bt apply --checked` on a mixed set**: name the items that conflict with each other (not only "not written: 9 of 15 break clearance") so a set can be split quickly.
- **Remove or fix `bt zone --delete`'s leak message** (it looks like a failure).
- **Add a "re-route in this order" option** (inner balls first, then the rest), since that is what I did by hand and what decided the outcome on the FX2 bus.

## Net result

bt made the placement and the plane vias much faster than doing them by hand, and `--checked` kept the file safe through ~60 writes with no bad state. The router was the bottleneck: on this board, most nets that needed to pass through the FPGA's interior or the Port B channel did not route, and more passes did not change that. The board is not finished (see NOTES.md); the interior congestion is the main reason, and bt could not have fixed it without a placement change.
