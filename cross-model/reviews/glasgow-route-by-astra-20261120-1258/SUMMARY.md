# glasgow-route-by-astra-20261120-1258

| | |
|---|---|
| Job | glasgow-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = human, B = fable, C = haiku, D = astra |
| Time | 0:13 |
| Cost at API prices | $3.84 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 8 | 9 | n/a | 6 | **8** | A combines a track-free L2 ground plane, closely matched FPGA expansion pairs and broad power feeds with local regulator copper. Correct the 0.051 mm zone-to-edge clearance, two 0.150 mm drill-wall gaps and the R40 via issue, then confirm the USB impedance build before ordering. |
| B | fable | 7 | 7 | 9 | n/a | 7 | **7** | B has continuous core-power distribution, short regulator loops and zero open connections. Its USB pair makes two transitions per main path, a FIFO trace crosses an L3 void, and 29 vias enter SMD lands with filling and capping disabled. |
| D | astra | 5 | 7 | 6 | n/a | 6 | **6** | D has the strongest nominal USB cross-section and provides ground beneath much of the expansion routing. Its FIFO D0 uses nine vias, its inner tracks interrupt the ground reference, and its five core-supply patches rely on additional routing. |
| C | haiku | 3 | 2 | 2 | n/a | 1 | **1** | Refilling clears 534 saved-fill clearance errors but leaves 153 open connections and four intersecting-zone errors. The FIFO clocks, EEPROM bus, expansion pairs and I/O bank regulator circuits have missing connections. |

Ranking, best first: A (human) > B (fable) > D (astra) > C (haiku).

Human guess: A (human), 98% sure. A tunes the entire expansion bus toward a common length while giving the mirrored regulator and shunt circuits repeated local copper shapes and the USB shell its own shield regions. This circuit-specific treatment is the strongest authorship clue in the four layouts.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `glasgow-route-by-astra-20261120-1258.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
