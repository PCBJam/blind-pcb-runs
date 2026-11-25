# orangecrab-place-by-astra-20261120-1624

| | |
|---|---|
| Job | orangecrab-place |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = haiku, B = astra, C = fable, D = human |
| Time | 0:13 |
| Cost at API prices | $4.17 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| D | human | 8 | 9 | 8 | 8 | 5 | **7** | D has the best DDR timing geometry, ground continuity and local power copper, using only through-vias. Hold fabrication until the zone refill, residual copper clearance, assembly overlaps and fine-feature CAM review are resolved. |
| B | astra | 5 | 6 | 5 | 7 | 5 | **6** | All nets connect, and the main USB trunk and DDR strobe pairs are closely matched. Fragmented references, thin power routing, a 51.4 mm flash clock path and 227 blind or buried vias complicate release on a standard six-layer process. |
| C | fable | 4 | 5 | 3 | 7 | 3 | **3** | Short regulator loops and close FPGA and DDR decoupling are undermined by 27 unconnected items on ground, supply and reference nets. Back-side clock and memory routes cross several power-plane boundaries. |
| A | haiku | 2 | 1 | 2 | 1 | 1 | **1** | KiCad reports 210 unconnected items across 76 nets, including USB, DDR clocks and the power path. U5 occupies the underside microSD shell area and two resistors occupy the FPGA package area. |

Ranking, best first: D (human) > B (astra) > C (fable) > A (haiku).

Human guess: D (human), 98% sure. The DDR byte groups, strobes and layer choices were coordinated, the regulator switch nodes have compact shaped copper, and the indicators and oscillator were placed with their physical use in mind.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `orangecrab-place-by-astra-20261120-1624.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
