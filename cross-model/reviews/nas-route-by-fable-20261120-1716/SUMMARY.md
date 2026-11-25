# nas-route-by-fable-20261120-1716

| | |
|---|---|
| Job | nas-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = astra, B = human, C = fable, D = haiku |
| Time | 0:32 |
| Cost at API prices | $11.43 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| B | human | 8 | 6 | 7 | n/a | 6 | **7** | Best ground system (802 GND vias, return vias and antipads at every pair transition), best regulator layout and clean 45-degree routing. Needs three fixes before ordering: 8.79 mm skew on PCIe_RX_3 from a one-leg meander, the CM4 +5V feed (0.8 mm track through two single 0.2 mm-drill vias, 192 mV at 3 A), and copper running to the board edge on all layers; no stackup is defined for its 0.127 mm pairs. |
| C | fable | 7 | 7 | 7 | n/a | 5 | **6.5** | Complete, DRC-clean against its own stricter rules, pairs matched within 0.17 mm on a documented JLC 3313 stackup, no power choke points. Loses to B on return-path detail (no return vias at pair transitions, single-via regulator grounds, no thermal vias under U3) and runs the PCIe RX pairs 0.42 mm from the wall of seven mounting holes on the bottom side. |
| A | astra | 6 | 7 | 5 | n/a | 5 | **5.5** | Complete, DRC-clean, with perfectly matched pairs and per-class impedance planning over solid GND. Power pours on the outer layers are fragmented by signals: 4.4 A of 12 V funnels through one via near (147.35, 82.85), U10/U14 input loops go through a via in or beside the VIN pin, and 68 % of the routing is any-angle with via-in-pad on fine-pitch pins. |
| D | haiku | 2 | 2 | 2 | n/a | 1 | **2** | Unfinished: 23 real open connections including the 1V2 switch node, three feedback-divider grounds and a USB D- line. No ground pours, In2 is power islands only so 66 % of PCIe length has no adjacent GND, pairs are routed up to 17 mm apart, switch nodes are 0.15 mm tracks and a 12 V track sits 0.03 mm from a slot edge. |

Ranking, best first: B (human) > C (fable) > A (astra) > D (haiku).

Human guess: B (human), 85% sure. B uses only the track widths and the single 0.45/0.2 via already preset in the project file and leaves the project's net classes, rules and default stackup untouched, while A, C and D all added net classes and edited rules. It is the only board with arc segments (84, all in rounded KiCad-tuner meanders), 92 % of its vias sit on a 0.05 mm grid and none of its routing is off 0/45/90 degrees. Its errors are human ones (a meander left on one leg of a pair, overlapping same-net zones with equal priority, edge clearance never set), and it shows mechanical awareness the others lack (no tracks near mounting hardware, void under the RJ45). The others carry tool signatures: A's 68 % any-angle routing and eleven via sizes, C's uniform 4 mm via grid, D's unfinished state.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `nas-route-by-fable-20261120-1716.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
