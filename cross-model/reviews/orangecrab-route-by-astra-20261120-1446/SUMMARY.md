# orangecrab-route-by-astra-20261120-1446

| | |
|---|---|
| Job | orangecrab-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = human, B = haiku, C = astra, D = fable |
| Time | 0:12 |
| Cost at API prices | $2.87 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 9 | 9 | 9 | n/a | 6 | **7** | Two continuous ground references, tightly grouped DDR3 lengths and compact regulator loops make A the best starting point for a through-drilled order. Repair the zone identifiers and duplicate pour, then resolve the remaining copper and drill-clearance findings before release. |
| C | astra | 7 | 7 | 8 | n/a | 4 | **6** | C refills with zero opens and has compact regulator loops and closely matched DDR clock paths to the receiver. Its 385 microvias and 114 buried vias require HDI fabrication, and its DDR data spread and clock reference gap deserve timing review. |
| D | fable | 5 | 3 | 5 | n/a | 3 | **3** | D has a continuous top-side ground reference, local power copper and only through vias. Its 29 opens include USB negative and RAM reset, and a bottom-layer DDR strobe crosses four supply regions. |
| B | haiku | 2 | 1 | 1 | n/a | 1 | **1** | There are 120 missing connections, including 44 on ground and opens on USB, both DDR clock legs, the flash clock and the power rails. The design also requires 75 blind microvias and contains overlapping drills. |

Ranking, best first: A (human) > C (astra) > D (fable) > B (haiku).

Human guess: A (human), 96% sure. All sixteen DDR data nets use two vias and tightly grouped lengths, each byte has a consistent principal layer, and all three regulators have individually shaped local copper on both sides of their input capacitors. A achieves this with through drills and no drill centers on either BGA's ball lands.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `orangecrab-route-by-astra-20261120-1446.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
