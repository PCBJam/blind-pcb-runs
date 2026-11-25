# macropad-small-by-astra-20261119-1326

| | |
|---|---|
| Job | macropad-small |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = astra, B = fable, C = haiku |
| Time | 0:12 (resumed 1 time after a plan usage limit) |
| Cost at API prices | $4.67 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | astra | 7 | 7 | 8 | 8 | 9 | **8** | A is the prototype choice, with short via-free USB routes, a wide single-layer LED supply, and via drills clear of exposed SMD lands. Its flash clock return and RP2040 core-regulator bypass need improvement, and all three designs share a BOOTSEL contention risk. |
| B | fable | 7 | 6 | 7 | 7 | 6 | **7** | B has the smallest outline, strong ground stitching, and short local regulator bypasses. A 49.94 mm flash-select branch, remote input bulk capacitor, and unfilled via drills in the RP2040 and other solder lands reduce its order readiness. |
| C | haiku | 4 | 5 | 6 | 6 | 6 | **5** | C has a 4.32 mm flash clock and a 0.50 mm LED supply, but cuts its only ground pour with signal routes and gives several fast signals poor return paths. Long regulator-capacitor returns, a recessed USB mating face, and in-pad drills add further risk. |

Ranking, best first: A (astra) > B (fable) > C (haiku).

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `macropad-small-by-astra-20261119-1326.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
