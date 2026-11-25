# mega-route-by-fable-20261120-0456

| | |
|---|---|
| Job | mega-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = fable, B = haiku, C = astra, D = human |
| Time | 0:20 |
| Cost at API prices | $8.06 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | fable | 7 | 7 | 6 | n/a | 8 | **7** | Clean on every DRC pass with the only single-piece ground plane, lowest ground detours and a guarded resonator pair. Two local flaws: a +5V trunk under U3's ADC pin row makes the AVCC cap ground return 38.6 mm, and the regulator tab has no heat-spreading copper. |
| C | astra | 5 | 5 | 7 | n/a | 7 | **6** | DRC-clean and orderable with the tightest decoupling loops, but the ground is in 65 pieces with detours up to x27 (J12.6 is 222 mm from U3.62). The 16 MHz resonator crosses ADC lines and +5V reaches the MCU through 0.35 mm tracks. |
| D | human | 6 | 6 | 6 | n/a | 5 | **5.5** | Best MCU ground and supply ring and best regulator copper, but the saved file fails its own DRC (515 errors from stale fills, 4 after refill) and has ten 0.119 mm gaps. There is no ground under the USB connector and the regulator output capacitor is 75 mm away through 0.4 mm necks. |
| B | haiku | 1 | 2 | 1 | n/a | 1 | **1** | Unfinished: 88 unconnected items across 41 nets, with GND in 36 pieces, +5V in 30 pieces and 24 signal nets open. It cannot work and cannot be ordered. |

Ranking, best first: A (fable) > C (astra) > D (human) > B (haiku).

Human guess: D (human), 88% sure. Legacy imperial dimensions (0.254/0.813/1.27 mm tracks, 0.914/0.406 and 1.118/0.61 mm vias), hand-drawn zone outlines running past the board edge, purpose-drawn XVCC and +5V pours, a +5V ring under the MCU and a staggered ADC via farm. It also carries the mess of a long-lived converted project: stale fills, minimum clearance set to 0, a 0.0003 mm leftover stub. A, B and C use uniform metric widths and 0.6/0.3 mm vias; A has a regular stitching grid, C has algorithmic widths, and B is abandoned mid-route with length-tuned serpentines on a 7 mm USB stub.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `mega-route-by-fable-20261120-0456.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
