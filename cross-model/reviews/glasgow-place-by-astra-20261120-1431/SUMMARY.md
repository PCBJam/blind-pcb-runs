# glasgow-place-by-astra-20261120-1431

| | |
|---|---|
| Job | glasgow-place |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = human, B = fable, C = astra, D = haiku |
| Time | 0:12 |
| Cost at API prices | $3.82 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 8 | 9 | 8 | 7 | **8** | A is fully connected with a continuous main ground reference, closely bypassed loads, wide supply distribution and through-drilled vias. Resolve drill spacing, edge clearance, USB stackup and tight assembly envelopes before ordering. |
| C | astra | 5 | 7 | 5 | 8 | 4 | **6** | C connects the circuit and matches the expansion pairs closely, but inner-layer signal routing interrupts return paths and the +5V feed is long and narrow. Its 113 laser microvias, 44 buried vias and stacked drill locations require an HDI process. |
| B | fable | 7 | 7 | 2 | 8 | 2 | **3** | A compact crystal loop and well-coupled primary USB route sit on a sensible floorplan. Two shorts, including +1V2 to GND at C14, and 15 missing connections block power-up. |
| D | haiku | 3 | 2 | 1 | 3 | 1 | **1** | D has 321 missing connections across 138 nets, including the main and bank supplies, crystal and interface clocks. Long USB probe branches and distant FPGA decoupling compound the incomplete routing. |

Ranking, best first: A (human) > C (astra) > B (fable) > D (haiku).

Human guess: A (human), 97% sure. A uses wide local copper for regulators and shunts, puts individual bypass capacitors behind switching loads, integrates USB probe pads into crossover vias, and tunes the expansion lanes on a through-drilled board. That combination of circuit-specific decisions is the strongest evidence of human authorship.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `glasgow-place-by-astra-20261120-1431.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
