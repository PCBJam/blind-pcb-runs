# mega-route-by-astra-20261120-1142

| | |
|---|---|
| Job | mega-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = human, B = fable, C = astra, D = haiku |
| Time | 0:09 |
| Cost at API prices | $2.38 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| C | astra | 6 | 7 | 8 | n/a | 8 | **8** | C is the preferred order candidate, with complete connectivity, two-sided regulator copper and the best-coupled USB receiver pair. The main electrical weakness is the interrupted ground reference under the main oscillator and long header routes. |
| B | fable | 7 | 6 | 6 | n/a | 7 | **7** | A continuous rear ground fill and 134 ground vias support a fully connected board. The regulator has little local heat-spreading copper, seven vias are inside solderable lands, and the USB B7 branch spends 5.05 mm on the back. |
| A | human | 5 | 6 | 8 | n/a | 4 | **5** | Broad supply trunks and two-sided regulator copper are strengths. The saved pours create clearance and mask failures, and four copper DRC errors remain after refill. |
| D | haiku | 1 | 3 | 1 | n/a | 1 | **1** | D has 88 missing connections after refill, including 29 on +5V and 35 on GND. Its matched USB receiver traces cannot compensate for open MCU supplies, oscillator returns and header signals. |

Ranking, best first: C (astra) > B (fable) > A (human) > D (haiku).

Human guess: A (human), 85% sure. The shaped power pours, offset thermal vias, broad shield return and selective neck-downs suggest hand tuning over several passes. The long SPI-clock detour and tiny leftover SCL segment also fit a locally revised layout.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `mega-route-by-astra-20261120-1142.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
