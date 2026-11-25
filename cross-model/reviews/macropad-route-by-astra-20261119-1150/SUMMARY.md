# macropad-route-by-astra-20261119-1150

| | |
|---|---|
| Job | macropad-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = fable, B = haiku, C = astra, D = human |
| Time | 0:10 |
| Cost at API prices | $2.75 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| C | astra | 8 | 7 | 9 | n/a | 9 | **8** | The continuous back ground, wide LED trunks, short core bypasses and clear solder lands make C the best choice for a standard order. Both USB traces lose their back ground directly between the series resistors and the RP2040. |
| A | fable | 7 | 7 | 8 | n/a | 6 | **7** | Local ground stitching, single-layer flash routing and wide LED feeds are strengths. The saved fills violate clearance on both faces at a +3V3 via, and five drills under the RP2040 paste apertures add assembly risk. |
| D | human | 5 | 8 | 7 | n/a | 6 | **6** | Compact single-layer QSPI and crystal routing accompany a low-resistance LED feed. Split back copper forces a long LED bypass return, and four drills join the exposed QFN land directly to backside capacitor lands. |
| B | haiku | 6 | 5 | 6 | n/a | 5 | **5** | The back ground pour is continuous across the key field, but key traces interrupt the crystal reference, QSPI_SD1 changes layers twice, and one local core bypass takes 10.56 mm. Several stitch drills land directly in LED or capacitor solder lands. |

Ranking, best first: C (astra) > A (fable) > D (human) > B (haiku).

Human guess: D (human), 85% sure. The individually staggered key fan-out, front-only VBUS path, selective LED trunk widths and shared QFN-to-capacitor vias look like local decisions made during interactive routing. This inference is independent of the quality scores.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `macropad-route-by-astra-20261119-1150.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
