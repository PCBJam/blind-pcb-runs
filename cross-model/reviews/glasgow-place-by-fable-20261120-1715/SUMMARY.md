# glasgow-place-by-fable-20261120-1715

| | |
|---|---|
| Job | glasgow-place |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = astra, C = haiku, D = fable |
| Time | 0:14 |
| Cost at API prices | $8.04 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 9 | 9 | 8 | 8 | **8** | Complete and correct through-via 4-layer board: solid one-piece GND plane, 13 LVDS pairs matched to 28.5-29.6 mm, clean USB and crystal, 0.45-0.75 mm power trunks, decoupling 0.1-0.5 mm from pins, 0 unconnected. Before ordering, pull the In1/In2 planes back from 0.05 mm at the board edge and fix two same-net via pairs with a 0.15 mm hole-to-hole web. |
| B | astra | 4 | 5 | 4 | 6 | 3 | **4** | Electrically complete and DRC-clean, but only as an HDI board: 113 microvias and 44 buried vias, so it is not a standard JLCPCB 4-layer order. The GND plane carries 397 mm of signal track and covers 34% of the area under the FPGA, and the USB supply input xVBUS is a 0.15 mm track. |
| D | fable | 6 | 5 | 3 | 7 | 2 | **3** | Sound architecture close to A (solid GND plane, through vias only, sensible power widths) but not orderable: +1V2 is shorted to GND through C14 pad 2 at (77.8,104.4), a +3V3 via shorts R45 pad 1, and 15 connections are open including FX2 reset, SCL, DA0-DA2 and the PLL1 supply. |
| C | haiku | 3 | 2 | 1 | 3 | 1 | **1** | Unfinished: 321 unconnected items on 138 nets, with +5V, VIOA, VIOB and the crystal having no copper at all. FPGA decoupling sits 6-17 mm from the balls and the LEDs are on the back inside the J5 header area. |

Ranking, best first: A (human) > B (astra) > D (fable) > C (haiku).

Human guess: A (human), 93% sure. A's lock state differs from the other three (25 locked footprints with C1/C15/C17/U2/U3 locked and J6-J10 unlocked, versus an identical set of 29 in B, C and D), which points to a pre-existing design the task was derived from. It also has hand-built structures none of the others attempt: isolated /SHLD and /SWSH islands on all four layers, sense pours at the shunts, regulator pours with via arrays, and all 13 LVDS pairs matched to each other within 1.1 mm with smooth serpentines. Its flaws are human ones (tight courtyards, a few close via pairs, a stray via), while B bends the rules to the tool with microvias and C and D stop partway with open nets and a track through a pad.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `glasgow-place-by-fable-20261120-1715.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
