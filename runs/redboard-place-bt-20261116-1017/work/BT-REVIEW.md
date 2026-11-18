# Review of `bt` after one full board (ESP32-P4 RedBoard, 4 layers, 292 footprints, 177 nets)

Short version: `bt probe` / `bt apply --checked` / `bt query` / `bt render` were the reason I could hand-route a 0.35 mm QFN by script at all, and they never gave me a wrong answer. `bt route` was fast and good on single links and small groups, and poor as a "finish the board" tool on this density. Three things cost me most of the lost time: the outline inside a footprint, shove/rip moving nets I had hand-routed, and the stale-fill view of poured nets.

Counts are approximate (taken from my command history).

## What I used, and how much it helped

| Command | Calls | Verdict |
|---|---|---|
| `bt probe` (mostly through a small Python wrapper) | ~60 | **Best tool in the box.** Exact gap numbers, names the offending item, checks new items against each other. Every hand-drawn track went through it; I trusted it and KiCad's DRC never disagreed afterwards. |
| `bt apply --checked` | ~50 | Same. "Skipped N already on the board" made scripts re-runnable. Writing plain text and leaving the `.kicad_pro` alone worked (the file was byte-identical at the end). |
| `bt query` | ~25 | Very useful for "what is boxing this pad in" – short, with nets and coordinates. |
| `bt render` | ~20 | Good enough to plan from; net labels on tracks and the fill display on a single layer (`--layers In2.Cu`) showed me the fragmented plane at a glance. Without `--box` on the unmodified board it produced an almost empty image (see outline bug). |
| `bt route` single link (`--net`, `--from/--to`, `--width`, `--neck`, `--avoid`) | ~90 | Good. Sub-second to a few seconds, sensible 45° geometry, and the failure text ("blocked by track t274 (GND) at …", "the start is boxed in for a 0.4 mm track") usually told me what to change. |
| `bt route --nets` batches | ~25 | Mixed, see below. |
| `bt ratsnest`, `bt length` | ~45 | Quick and clear. `bt length` per layer was how I noticed that pairs had been moved and how much had gone onto In2. |
| `bt rm`, `bt unroute` (`--layer`, `--box`) | ~70 | Needed constantly. `--dry` on `rm` is valuable. |
| `bt place` (trial and `--apply`) | ~25 | Courtyard and pad-clearance report before writing saved several iterations. |
| `bt plane` | 4 | 124/128 GND and 38/43 3.3V pads got a via in two calls – a big time saver. |
| `bt zone`, `bt fill` | ~25 | Worked every time. |
| `bt same` | 3 | Exactly the final check I needed, one line. |
| `bt part`, `bt board`, `bt via`, `bt drc`, `bt fan`, `bt stitch`, `bt islands`, `bt cleanup`, `bt undo`, `bt outline`, `bt free` | 1–6 each | see notes below |

Not used: `bt bus`, `bt pair`, `bt tune`, `bt escape`, `bt congestion`, `bt gap`, `bt near`, `bt silk`, `bt offset`.
- `bt pair`: my pairs needed exact entry geometry at the FPC pads and at the ESD arrays, so I wrote polylines and an offset function myself. In hindsight `bt offset` would have replaced my own offset code.
- `bt tune`: I ran out of time before length matching; the pairs are untuned (said so in NOTES.md).
- `bt congestion`: I should have run it before committing to the P4 escape. I did not, and that escape is the root cause of my worst problem.

## Problems, with what happened

1. **Outline inside a footprint (H1) is not read.** `bt board` said "outline doesn't close (its 0 Edge.Cuts pieces…), box Infinity…"; `bt free` and `bt route` then died with `error: Invalid typed array length: Infinity`; `bt place` reported every pad as "0.000 mm from board edge". After `bt outline --poly` added a board-level copy, H1's own outline was taken as a **cut-out covering the whole board** ("board edge -0.0635 mm off" for every pin in `bt fan`).
   Work-around: a script that parks H1's Edge.Cuts lines on the Margin layer while working and puts them back for KiCad. This cost about an hour and made `bt drc` unusable for me (it would have seen a double or missing outline), so I wrote my own DRC wrapper round `kicad-cli`.
   Fix wanted: read Edge.Cuts from footprints, and fail with a sentence rather than a typed-array error.

2. **Shove/rip moved hand-routed nets.** `bt route --nets "*"` (all passes, no `--fixed`) returned DSI_D1- and two CSI legs with extra vias and a bottom-layer detour. That was my omission, but nothing in the output said "moved DSI_D1-" in a way I noticed among 65 nets; I found it with `bt length`.
   Later, **with** `--fixed "DSI_*,CSI_*,…"`, a run that included the poured net GND still changed DSI_D1- and DSI_D0+ (message: "GND: GAVE UP: CSI_D1+ could not be put back after moving it out of the way"). Single-net `--rip` runs afterwards did respect `--fixed` (they reported "FLASH_CS could not be put back" and left it as it was). So `--fixed` seems not to be honoured on one path, possibly the poured-net one.
   Wanted: nets wider than class, or with hand-set geometry, protected by default; a per-run summary line "moved: A, B, C".

3. **Poured nets are judged on the stale fill.** After adding tracks on In2, `bt route --net 1.1V --all` answered "0/0 routed, 1 already connected" while KiCad, after refill, had the net in three pieces. I had to run `bt fill` before every such call, and each link I added for 3.3V could cut 1.1V again. A warning "fills are older than the copper" would have saved several rounds.

4. **In2 as a third layer.** The help says other nets' pours cost 2.5× to cross "so they don't get cut". With `--layers F.Cu,B.Cu,In2.Cu` the router put 340 mm of signal on In2, straight through a 1.1V island and round the pad ring, and split both planes. A much higher cost, a length cap per net on a foreign pour, or a refusal to isolate a plane via would be right. `--avoid "box,In2.Cu"` worked well once I used it.

5. **`bt cleanup --stub 3.5` deleted stubs that connect pads to planes** (a stub ending in a via/zone looks dangling to it). It broke 5V_USB2, 1.1V and 3.3V links; I restored from a copy. KiCad's own `track_dangling` list was the reliable source.

6. **Neck width 0.1219 mm** is below the project minimum 0.12192 mm: 22 `track_width` errors in KiCad. I patched the widths to 0.122 by `sed`.

7. **`bt place --apply --force`** moved a jumper onto an existing track without a word (I had asked for force, but the trial placement checks pads only against pads, not against routed copper).

8. **Batch routing speed and ordering.** `--nets "*"` took 37 minutes for 65 nets and finished 27; "shortest first" closed lanes that longer bus members needed (SDIO D2/D3 until I used `--order given`). Passes 2 and 3 spent 10–25 s per net and rarely succeeded. Long nets often hit "gave up after 20 s" where a later single-net call with `--from/--to` found a route in 4 s – e.g. `Net-(D5-DOUT)` failed twice with `--all` ("got closest at 142.59,89.53 … no path") and routed at once with `--from JP5.1 --to x,y,B.Cu`.

9. **`bt plane` via positions** are locally fine but blind to what is coming: two landed in the SDIO lane, others produced long diagonal stubs or shared a via 1.5 mm away. A `--keepout` box list would help.

10. **`bt fan` on a 0.35 mm QFN** only goes straight out about 1.7 mm on one layer; it is not a dog-bone fan-out, so I did not use its result. A staggered multi-row via fan with guaranteed bottom-layer channels is exactly what I got wrong by hand.

11. Small things: `bt stitch` found 0 sites with no hint which condition failed; `bt rm x,y` takes tracks *and* vias, and at a T-junction takes all three tracks (I cut a net that way) – a `--via-only` / `--track-only` switch would help; `bt drc` could not be given a pre-processed board, which is why I did not use it.

## What I did myself instead

- Hand-routing by coordinates in Python (≈450 segments: P4 escape, MIPI, USB, flash, crystal), always through `bt probe` and `bt apply --checked`.
- My own DRC wrapper (`scripts/check.py`: KiCad form of the board, refill, JSON summary) because of problem 1.
- Dangling-via removal by text edit, because `bt rm` also takes tracks.
- Widths: a pcbnew one-off to list track widths per net – that is how I found 5V and 3.3V_P had been laid at 0.15 mm by a batch run where I had passed one `--width` for all nets. A per-net-class width in batch mode, or reading widths from net classes, would avoid this.

## What I would change, add, remove

- Fix the footprint-outline case (1) and make `--fixed` airtight (2) – these two would have saved me roughly a third of the session.
- Protect planes by default (4) and warn on stale fills (3).
- `bt fan`: real multi-row fan-out for fine-pitch QFN/BGA that leaves bottom-layer channels, plus in-ring vias as an option.
- Batch route: `--order` by bus membership, per-class widths, a hard "do not touch" list shown in the summary, and a final table of nets moved / vias added / layer use per net.
- `bt cleanup`: never drop a stub whose end touches a via, pad or zone of its net.
- Keep `probe`, `apply --checked`, `query`, `render`, `length`, `same`, `place` exactly as they are.
- I would not remove anything; the commands I did not use were skipped for lack of time, not because they looked wrong.

## Net effect

Time and tokens: hand-routing with probe/apply was efficient (a script, one or two probe rounds, done). Batch routing and the plane repair were not: roughly half of the session went into three restore-and-redo cycles caused by problems 2, 3 and 4 combined with my own escape design. Mistakes avoided: every clearance error was caught before writing; the final KiCad DRC has no clearance or short errors, and I never had to chase one found late.
