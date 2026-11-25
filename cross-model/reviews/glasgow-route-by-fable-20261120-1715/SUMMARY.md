# glasgow-route-by-fable-20261120-1715

| | |
|---|---|
| Job | glasgow-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = fable, C = astra, D = haiku |
| Time | 0:27 |
| Cost at API prices | $10.24 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 9 | 8 | n/a | 7 | **8** | Complete, clean hand-style layout: solid In1 ground, all 13 LVDS pairs length-matched to 28.5-29.6 mm, USB on one layer through the ESD pads, wide power trunks and local pours. Needs the inner planes pulled back from the board edge (0.06 mm now, JLCPCB wants 0.2 mm) before ordering. |
| B | fable | 8 | 7 | 8 | n/a | 7 | **7** | Complete and DRC-clean with the tidiest power planes (per-rail polygons on In2, stitched outer ground pours). Weaker on signal integrity: USB changes layer twice per line, LVDS pairs are not length-matched, and 29 vias sit in SMD pads. |
| C | astra | 4 | 5 | 5 | n/a | 4 | **4** | Electrically complete and DRC-clean, with a real stackup and impedance classes, but signals on In1 leave an 88 mm2 hole in the ground plane under the FPGA (26 % cover), the 3V3 plane is in 30 pieces, and all power tracks are 0.25 mm. Vias sit in 9 BGA ball pads and 5 QFN signal pins, which needs filled vias and is not a standard 4-layer order. |
| D | haiku | 2 | 2 | 2 | n/a | 1 | **1** | Unfinished: 153 unconnected links on 79 nets (I2C, parts of the FIFO bus, CC2, both VIO shunt paths, half the LVDS pairs). The saved plane fills are stale, giving 335 clearance and 199 hole-clearance violations if plotted as saved. |

Ranking, best first: A (human) > B (fable) > C (astra) > D (haiku).

Human guess: A (human), 93% sure. A has serpentine length-matching of all 13 LVDS pairs to one target, mirror-identical bank A/B layouts, small hand-drawn pours with idiosyncratic settings, dedicated shield copper for the USB and switch shells, 53 locked tracks, context-chosen via sizes, and only 1 of 2609 segments off the 45-degree grid, plus leftovers of an evolved design (dangling via by a DNP part, hole-to-hole warnings, planes drawn to the outline). B, C and D show near-uniform 0.45/0.2 vias, hundreds of off-angle segments and no length tuning.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `glasgow-route-by-fable-20261120-1715.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
