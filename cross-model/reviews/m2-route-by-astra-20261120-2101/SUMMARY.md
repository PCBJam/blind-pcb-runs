# m2-route-by-astra-20261120-2101

| | |
|---|---|
| Job | m2-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = astra, B = human, C = fable, D = haiku |
| Time | 0:14 |
| Cost at API prices | $2.67 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | astra | 8 | 9 | 9 | n/a | 8 | **9** | A combines short, closely coupled PCIe routes with a nominal 85 Ω geometry, parallel power pours and local capacitor returns. The retention drill is present, and release depends on confirming the production stackup and edge processing. |
| B | human | 9 | 8 | 6 | n/a | 8 | **8** | Two dedicated GND planes and nearby transition vias give B the strongest return paths. Long 0.25 mm feeds at the 3.3 V slot contacts reduce load margin, and the edge-drilled retention feature needs explicit fabrication treatment. |
| C | fable | 8 | 8 | 9 | n/a | 5 | **6** | C has excellent 12 V distribution, matched PCIe pairs and deliberate plane relief at the connector lands. The drill and profile omit the M.2 retention half-hole, a mechanical release blocker despite clean electrical DRC. |
| D | haiku | 2 | 2 | 4 | n/a | 2 | **2** | Nine missing GND connections isolate connector returns, and several differential mates take different layers or widely separated paths. A long 12 V trace and the missing M.2 retention feature compound the release risk. |

Ranking, best first: A (astra) > B (human) > C (fable) > D (haiku).

Human guess: B (human), 93% sure. Lane-specific rounded tuning, two length targets offset by about one via traversal, locally placed return vias and small residual power-route edits suggest iterative interactive routing.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `m2-route-by-astra-20261120-2101.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
