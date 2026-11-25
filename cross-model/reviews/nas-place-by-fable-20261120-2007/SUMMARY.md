# nas-place-by-fable-20261120-2007

| | |
|---|---|
| Job | nas-place |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = fable, C = haiku, D = astra |
| Time | 0:19 |
| Cost at API prices | $11.32 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 7 | 7 | 8 | 7 | **8** | Complete single-sided board with solid GND plane, 802 stitching vias, return vias at every pair via and textbook buck layouts. Faults are local: PCIe_RX_3 has 8.4 mm skew, CM4 +5V runs through single 0.45/0.2 vias on an 82 mm 0.8 mm track, zone fills are stale and copper is 0.198 mm from the edge. |
| B | fable | 7 | 8 | 8 | 7 | 6 | **7** | Short, fully matched PCIe/Ethernet over continuous GND, planes and multiple vias for every rail, tight decoupling. Not orderable as is: 7 tracks are 0.05-0.11 mm from non-plated holes and plane copper touches those holes; return vias are 2-5 mm from pair vias and 109 parts are on the back. |
| D | astra | 7 | 7 | 7 | 5 | 5 | **6** | Best PCIe geometry (22-71 mm, matched, defined stackup) and closest decoupling, DRC clean under tightened rules. Held back by 32 vias in SMD pads including M.2 and CM4 connector pads, all 16 LEDs and 185 parts on the bottom, a fragmented In2 plane and an asymmetric Ethernet pair. |
| C | haiku | 3 | 2 | 2 | 3 | 1 | **2** | Unfinished: 147 unconnected items on 77 nets including +12V to five bucks, +3.3VSTB, +3V3 and the 1.2 V feedback. Differential pairs are routed as separate 0.4 mm tracks with up to 20 mm skew, and inner planes run to the board edge. |

Ranking, best first: A (human) > B (fable) > D (astra) > C (haiku).

Human guess: A (human), 92% sure. Only Module1 is locked in A while B, C and D all carry the 38 locked parts of the task's starting file, so A was not built from it. A keeps all parts on the top side, uses 84 arc tracks, via fences, 44 keep-out areas and many small hand-drawn power polygons, has no net classes, and its saved zone fills predate KiCad 10. Its errors are human ones (a tuning meander on the wrong side of one pair, test points crowding caps), unlike the script-like regularity of the other three.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `nas-place-by-fable-20261120-2007.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
