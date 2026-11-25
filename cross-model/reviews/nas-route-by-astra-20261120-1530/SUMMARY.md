# nas-route-by-astra-20261120-1530

| | |
|---|---|
| Job | nas-route |
| Reviewer | GPT-6.2-Astra (effort high) |
| Boards | A = astra, B = haiku, C = human, D = fable |
| Time | 0:16 |
| Cost at API prices | $4.78 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| D | fable | 8 | 8 | 7 | n/a | 8 | **8** | D is the best release candidate, with credible impedance geometry, matched Ethernet paths and short top-side flash routes. The long 0.60 mm fan supply, local return discontinuities and assembly details still need sign-off. |
| A | astra | 8 | 7 | 9 | n/a | 7 | **7** | The strongest power distribution and a well-referenced CM4 USB pair make A a close second. Overlapping Ethernet tuning copper hides real path skew, and the flash data routing and USB-C launch add avoidable transitions. |
| C | human | 6 | 5 | 7 | n/a | 5 | **5** | Local switch-node pours, ground stitching and top-side flash routing are strengths. Lane 3 has substantial receive-pair skew, the saved stack gives poor impedance estimates, and refill leaves 19 zone-intersection errors. |
| B | haiku | 2 | 2 | 1 | n/a | 1 | **1** | The 29 missing connections include the 1.2 V converter switch node and RP2040 USB data. Bottom-side PCIe routes cross large gaps in the power planes, and the inner ground fill reaches the routed outline. |

Ranking, best first: D (fable) > A (astra) > C (human) > B (haiku).

Human guess: C (human), 95% sure. C combines individually shaped switch-node pours, local pad-level fill keepouts, ground stitching and curved skew tuning in particular PCIe corridors. The combination looks like repeated local decisions made in the PCB editor. Authorship remains an inference.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `nas-route-by-astra-20261120-1530.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
