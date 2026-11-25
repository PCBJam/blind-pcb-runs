# macropad-route-by-fable-20261119-1150

| | |
|---|---|
| Job | macropad-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = haiku, C = fable, D = astra |
| Time | 0:15 |
| Cost at API prices | $7.20 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| C | fable | 8 | 7 | 8 | n/a | 7 | **8** | Best all-round: five vias in the RP2040 pad placed between the back-side capacitor pads, every supply pin within 1.9-5.9 mm of a capacitor, 100 GND vias, sensible net classes and widths, and nothing near edges or unplated holes. Weak points are the split B.Cu pour and partial ground coverage under USB D+ and two QSPI lines. |
| D | astra | 7 | 7 | 6 | n/a | 7 | **7** | Best layer strategy (B.Cu is one 2358 mm2 ground plane, long runs on top) with wide supply copper and no via-in-pad, but the RP2040 exposed pad has no vias and grounds through two vias outside it, and a /KEY1 via sits 0.37 mm from the board edge. |
| A | human | 6 | 7 | 6 | n/a | 6 | **6** | Tidy, economical route with the cleanest USB entry and the tightest RP2040 decoupling, but +3V3 is 0.2 mm throughout (64.7 mm), there are only 18 GND vias with ground pads up to 9.6 mm from one, and via holes sit in five 0603 pads and on QFN pads 48/49. |
| B | haiku | 4 | 4 | 4 | n/a | 4 | **4** | DRC-clean but /KEY3 runs under the crystal (49 % ground under Y101) with /KEY4 and /KEY6 vias 0.5 mm from its pads, several RP2040 supply pins are about 10 mm of copper from any capacitor, and the +5V_LED trunk threads between unplated switch holes at 0.22 mm. Should not be ordered as is. |

Ranking, best first: C (fable) > D (astra) > A (human) > B (haiku).

Human guess: A (human), 85% sure. A's zones are plain named 4-point rectangles drawn past the board edge while B, C and D share an identical 63-point outline-traced polygon; A's GND vias sit on a 0.25 mm hand grid with push-and-shove track coordinates and vias dragged off track ends; it uses only 45 vias, four widths and one net class, and routes vias through the exposed pad into the capacitor pads as the placement intends. B, C and D show scripted patterns (a via a fixed distance from every GND pad, a 4 mm stitching grid, invented net classes, 19 computed widths).

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `macropad-route-by-fable-20261119-1150.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
