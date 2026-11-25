# BT-REVIEW: bt board tools, from one routing session

I used bt for almost all the board work. Counts are approximate (I counted from my command log).

## Commands used, and how often

| command | times | what it did for me |
|---|---|---|
| `bt route` (single net, `--all`, `--from/--to`, `--avoid`, `--through`, `-o`) | ~45 | most of the copper; trial then apply, one net at a time |
| `bt route --nets ...` (escapes-first, given, `--passes`, `--budget`, `--progress`, `--move-board`, `--fixed`) | ~12 | groups of nets in one call; the big calls ran 5 to 50 minutes |
| `bt render` | ~18 | labelled PNG of any box; the best check I had |
| `bt drc` | ~55 | KiCad DRC plus bt's own checks, grouped; mostly used as a wait, see below |
| `bt apply` | ~25 | writes items files; with `bt probe` before it, nothing bad got in |
| `bt probe` | ~12 | caught an NPTH mounting-hole clearance and a D+ clearance before writing |
| `bt rules` | 5 | set the Default and Power clearances, widths and the board minimums |
| `bt congestion` | ~8 | links that cross routed copper on every layer; the most useful planning view |
| `bt ratsnest` | ~8 | open nets and their pieces; the open list |
| `bt planar` | 5 | layer counts for each bundle (S bus: 4 nets off-layer; ADC: 6 and 7) |
| `bt islands` (and `--fix -o`) | 5 | GND/+5V pieces, and the joins it would make |
| `bt via --near` | 5 | legal via spots next to MCU pins; good when it found one |
| `bt zone` (GND on B.Cu; `--edit --connect solid`; +5V box) | 4 | pours; `--edit --connect solid` cleared a starved-thermal error |
| `bt unroute` (`--list`, `-o`) | 4 | pulled whole nets off the board for a rerouting pass |
| `bt pair` (RD+/RD-, `--tune`) | 3 | skew 1.34 mm to 0 with two bumps; worked |
| `bt length` | 5 | per-net lengths and layers |
| `bt part` | 4 | pad positions, pin names and the net on each pin |
| `bt check` | 2 | one command, CHECK FAILED with the reasons |
| `bt rm` (`--segment --dry`) | 2 | said whether a net comes apart |
| `bt vias --under-min` | 2 | sanity check |
| `bt free` | 2 | free areas per layer |
| `bt fan` | 1 (trial) | not applied; the layer plan was useful to read |
| `bt board`, `bt help` | ~8 | the overview; `bt help` is 250 lines, `bt help CMD` is what I actually read |
| `bt bus`, `bt escape`, `bt plane`, `bt stitch`, `bt near`, `bt outline`, `bt silk`, `bt seg`, `bt tune`, `bt cleanup`, `bt undo` | 0 | not needed yet (the GND stitching and plane steps were still ahead) |

## What helped

- `bt render` with a box and `--px 1300-1600` was the best check. Every routing stage got one, and I saw things the numbers did not show (the 45-degree bundle over the N side pins, the B.Cu runs under the chip).
- `bt probe` before `bt apply` on hand-planned copper. The two probes (USHIELD, XVCC) each caught a real clearance problem first. The XVCC probe found the connector's mounting holes, which the router had avoided by itself.
- `bt route` for one link as a trial, then `-o`, then `bt apply`: the most reliable loop. A trial gives the actual geometry, and `-o` keeps the items for review.
- `bt pair --tune` made the RD+/RD- skew zero with two small bumps; that was exactly what I wanted.
- `bt congestion --nets` and `bt planar`: they told me which bundles cross and how many nets need the other layer, before I committed to an order.
- `bt islands` and `bt via --near`: the GND join suggestions and the legal via spots were the right kind of answer. The "boxed in / walls in U6.2" messages named the blocking copper.
- `bt check`: one command, one CHECK FAILED line with the counts. Good to end a session with.
- `bt rules` changed only the .kicad_pro fields I named, and it reads them back. Clear.
- `bt zone` / `bt fill` used pcbnew on a copy and returned only the .kicad_pcb, so the project file was not touched.

## What got in the way, or was confusing

1. **Trial routes do not see each other.** Two trial routes for the same net (D+ east loop, D- escape) each looked legal alone and would have shorted or crossed together. I had to apply one at a time. Worth a "trial these together" mode.
2. **Long jobs and the 120 s tool limit.** Any `bt route --nets` of more than a few nets goes past the tool's foreground limit. The `--progress` file plus a background run works, but the first attempt wasted a run. Documenting a "run this in the background" line in the help would help.
3. **Failures without a reason.** Most failed searches say only "gave up after N s". The useful messages ("boxed in ... blocked by track X on F.Cu", "walls in U6.2 (GND)") only appeared on some failures. For a net that gives up, I could not tell whether more time or a different corridor would help.
4. **The pad guard blocked nets next to power pads.** "every route found walls in U6.2 (GND), U6.3 (+5V)" stopped PE1 twice. The guard protects an unrouted pad's way out, which is right in principle, but there is no per-net switch except `--no-guard`, which is all or nothing.
5. **`--move-board` did nothing I could see.** In my move-board call every net failed in pass 1 and no shove was made, though the copper it needed was movable. I could not tell whether the shove logic or the fixed list was responsible.
6. **`bt route --nets` with `--order escapes-first` changes order** as the board changes, so a second call on the same nets can behave differently. I preferred `--order given` once I knew the order I wanted.
7. **"could not be put back after moving it out of the way; it would have to move: A, B, C"** appeared in pass 2 many times. It names the nets but not the reason, and I could not act on it.
8. **`bt zone` help is inconsistent.** The usage line shows `--clearance .3` as a default; the text says a new zone takes the net class clearance. I used the class value both times, so I don't know which one applies.
9. **`bt islands` on a copy without its .kicad_pro** uses KiCad's default rules (clearance 0.2, track 0.25) and says so in one line. That is easy to miss: my first joins came from the copy and were wrong. I re-ran it on the real board.
10. **`bt islands --fix` with power nets** joins with the net-class width (1 mm for +5V). Many joins then say "boxed in for a 1 mm track". A narrower-width option for power joins would have helped.
11. **`bt drc` takes about 10 s.** I used it repeatedly as a wait while background jobs ran. That worked, but it cost many tool calls and tokens. A background wait would have been better; I now use one.
12. **`bt board` is 400 lines.** Too long to read in one go; `bt nets` or `bt ratsnest` were enough for most decisions.
13. **Output buffering through pipes.** `bt ... | tail` shows nothing until the end. Using `-o` and `--progress` files was the workaround.

## What I did myself instead, and why

- **USB D+/D-, RD pair, USHIELD, VBUS:** planned by hand, checked with `bt probe`. The router's answers for USHIELD and VBUS used vias and B.Cu diagonals through the connector; the hand plans were cleaner and both probed clear.
- **Ordering of the big bundles:** I chose ADC first, then the west-top, by reading `bt congestion` and `bt planar` and then trying both orders. The tools gave the information; the choice was mine.
- **Filtering join items** (dropping the D6 path from the GND fix file) and reading the items JSON with short Python scripts. `bt` has no filter for items files.
- **Waiting for background runs:** with Monitor and background bash waits. I wasted many calls polling and arming duplicate watchers; a single background wait per job is the right pattern.

## What I would change, add or remove

- **Add** a combined trial mode (`bt route --trial-together`) so several nets are checked against each other before any is applied.
- **Add** a "reserve corridor" command: take a box or a channel for a bundle (say, 16 ADC nets) so later calls route around it. This is what the board needed and what I lacked.
- **Add** a per-net reason when a search gives up (cells searched, nearest blocker), and a `--retry-with-guard-off NET` option.
- **Fix** `--move-board` or report why it moved nothing.
- **Fix** the `bt zone --clearance` default text.
- **Add** a narrower-width option for power joins in `bt islands --fix`.
- **Shorten** `bt help` to one screen, with `bt help CMD` for details; shorten `bt board` with a `--compact` mode.
- **Keep** `bt render`, `bt probe`, `bt congestion`, `bt planar`, `bt islands`, `bt via --near` and `bt check` exactly as they are: those were the parts that made the difference.

## Outcome, honestly

bt did not get the board finished. With its help I routed most of the board: the USB block, the MCU's south bus, the east bus (13 of 16), the top-right group and most of the west-top group. The MCU's north side (ADC) and the top and east corridors around J12 were not solved. The reason is a crossing problem with 2 layers and this placement, and I could not find a routing order or width that fits all the bundles. The notes in NOTES.md list every open net.
