# m2-route-by-fable-20261120-2102

| | |
|---|---|
| Job | m2-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = fable, B = haiku, C = astra, D = human |
| Time | 0:14 |
| Cost at API prices | $6.61 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| C | astra | 7 | 8 | 8 | n/a | 8 | **8** | The only board with no blocking defect: clean DRC, zero-skew coupled pairs over ground, plane-fed power with via arrays, retention half-hole present. Weaker points are the three-way In1 split near the layer transitions, no pad relief under J1, a thin 0.35 mm half-hole land and needless via-size variety. |
| A | fable | 8 | 9 | 9 | n/a | 6 | **7** | Best copper of the four: zero-skew coupled pairs over ground, plane cut-outs under the connector pads, pours for +3V3 and +12V, 115 ground vias, clean DRC. Held back by a blocker: no M.2 retention notch or half-hole at (186.2, 98.76), so the card cannot be screwed down as fabricated. |
| D | human | 9 | 7 | 5 | n/a | 7 | **7** | Two unbroken ground planes and the tidiest pair routing, with a proper 5.5 mm retention half-hole. But the slot's +3V3 is fed through two 0.25 mm tracks of about 15 mm, the lanes are length-matched with tight serpentines PCIe does not need, and one unwaived edge-clearance DRC error remains. |
| B | haiku | 2 | 2 | 3 | n/a | 2 | **2** | Not orderable: ten GND pads are unconnected (J2 fingers 9/21/27/33/39/45/51, J1 A15/A27/A28), the PCIe pairs are uncoupled and split across layers over plane voids, and +3V3 runs on a single 0.6 mm track of about 37 mm through single vias. |

Ranking, best first: C (astra) > A (fable) > D (human) > B (haiku).

Human guess: D (human), 90% sure. D's half-hole via has a legacy-format UUID at an off-grid position whose perpendicular foot on the slanted board edge is exactly the stale DRC exclusion marker in the project file, so it is the original via; C has the same UUID placed on the marker coordinate with a custom rule, which looks reverse-engineered. D also uses KiCad GUI default zone values (0.508/0.254 mm), a multi-layer zone, tuner-style arc serpentines, no via on a round grid (0 of 92), and zero-length and duplicate segment leftovers.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `m2-route-by-fable-20261120-2102.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
