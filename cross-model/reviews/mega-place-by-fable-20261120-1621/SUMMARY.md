# mega-place-by-fable-20261120-1621

| | |
|---|---|
| Job | mega-place |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = astra, C = fable, D = haiku |
| Time | 0:29 |
| Cost at API prices | $7.48 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| B | astra | 6 | 7 | 7 | 8 | 6 | **7** | Complete and DRC-clean, with 5.5-6.8 mm decoupling loops on every MCU supply pair, the resonator 3 mm from the MCU, proper regulator copper and every LED/jumper at its printed legend. Weaknesses are a fragmented back ground (22% of signal length GND-referenced, 287 vias, 13 on one net), 23 different track widths and a 0.22 mm neck on the 3.3 V header feed. |
| C | fable | 7 | 6 | 6 | 6 | 7 | **6** | Cleanest routing and best ground (pours both sides, 132 stitching vias, 5 mm decoupling loops), DRC-clean. But the regulator tab has no pour and one via, the 16 MHz resonator sits over the ADC bus, D+ is 4.9 mm longer than D- and threads between RN2's pads, and parts ignore the printed legends (LED labels wrong, pin names clipped, 69 silk-over-pad warnings). |
| A | human | 5 | 6 | 5 | 7 | 5 | **5** | Sensible conventional arrangement with heavy power copper and good regulator heat spreading, but two of four MCU supply pairs have no local capacitor (loops 43-78 mm), the 47 uF regulator output cap is 79 mm of copper from the tab, and the USB ground return is 40 mm for 12 mm straight. As saved the zone fills are stale (499 clearance errors, copper 0.026 mm from J1's NPTH holes); after refill 16 errors remain and ten gaps are 0.10-0.12 mm. |
| D | haiku | 2 | 2 | 2 | 3 | 1 | **2** | Unfinished and non-functional: 58 unconnected items on 45 nets, including MCU ground and +5V pins, both MCU crystal nets, RESET, all 16 ADC lines and the UART link between the processors, with 50 dangling vias. The reset switch was also moved into the power section away from its legend. |

Ranking, best first: B (astra) > C (fable) > A (human) > D (haiku).

Human guess: A (human), 95% sure. A has no locked footprints while B, C and D each have exactly the 17 locked parts the job describes; A's geometry is on an imperial grid (0.9144/0.4064 mm vias, 1.27 and 0.254 mm tracks, off-grid part coordinates); the printed LED and jumper legends match A's placement exactly; A's MCU sits on fiducial FID4, a position locked for the others; and its zone fills are stale as from an older converted file. B, C and D show agent habits: a 4 mm stitching grid, widths like 0.185 mm with 13 vias on one net, and an abandoned route with dangling vias.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `mega-place-by-fable-20261120-1621.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
