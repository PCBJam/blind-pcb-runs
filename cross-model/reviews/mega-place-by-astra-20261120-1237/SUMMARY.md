# mega-place-by-astra-20261120-1237

| | |
|---|---|
| Job | mega-place |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = astra, B = fable, C = haiku, D = human |
| Time | 0:10 |
| Cost at API prices | $2.77 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | astra | 4 | 7 | 8 | 8 | 8 | **7** | Complete connectivity, short oscillator and bypass loops, and two-sided heat spreading at U1 make A the release candidate. The long edge-parallel SCL run and interrupted SPI returns are its main electrical weaknesses. |
| B | fable | 7 | 6 | 6 | 8 | 6 | **6** | Dual ground pours, 132 GND vias and local MCU bypassing give B the best ground distribution. Limited U1 heat spreading, ten via drills centred in SMD lands, and the long edge-routed AREF trace cost it first place. |
| D | human | 6 | 6 | 6 | 5 | 4 | **5** | The board connects all nets and gives the regulator generous copper, but U3 has long bypass and resonator loops and obscures FID4. Refilling clears 499 zone-clearance errors and still leaves 16 DRC errors. |
| C | haiku | 2 | 1 | 2 | 4 | 1 | **1** | Refilling leaves 58 missing connections, including both main oscillator nets, seven +5V links and seven GND links. The USB lengths look close, but the long bottom sections have poor coupling and little opposite ground. |

Ranking, best first: A (astra) > B (fable) > D (human) > C (haiku).

Human guess: D (human), 94% sure. The pin-bank fan-out from the central MCU follows the header rows in coherent groups. The locally shaped regulator copper, repeated large via sizes and indicator placement aligned to the legends also suggest a single designer planned the routing and placement together.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `mega-place-by-astra-20261120-1237.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
