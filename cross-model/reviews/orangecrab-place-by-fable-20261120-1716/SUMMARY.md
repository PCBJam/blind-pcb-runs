# orangecrab-place-by-fable-20261120-1716

| | |
|---|---|
| Job | orangecrab-place |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = human, B = astra, C = haiku, D = fable |
| Time | 0:31 |
| Cost at API prices | $9.42 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| A | human | 8 | 9 | 8 | 8 | 7 | **8** | Complete, through-via 6-layer board with solid In1/In4 ground planes, DDR3 matched to about 15.0 mm, a coupled 30 mm USB pair, pours for every rail and all FPGA decoupling under the BGA. Faults are housekeeping DRC items (zone edge 0.15 mm, NPTH clearance, a duplicate zone, 5 dangling vias) and very tight 0201 spacing (68 courtyard overlaps). |
| B | astra | 5 | 5 | 4 | 5 | 5 | **5** | Electrically complete and DRC-clean, but it needs an HDI build (197 microvias, 30 buried vias, custom stackup) rather than a standard 6-layer order, and VBUS/VBATT/VSYS are routed at 0.105 mm. Ground planes are perforated under the BGAs (97.6 mm2 void network on In1), DDR3 is unmatched with up to 6 vias per net, and the flash, ADC parts and SD filter are 15-23 mm from where they belong. |
| D | fable | 5 | 5 | 3 | 6 | 3 | **4** | Sound stack-up (In2 stripline between two ground planes), correct power widths and good decoupling on a standard through-via process, but 27 unconnected items make it dead as drawn: the 2.5 V LDO output reaches no FPGA VCCAUX ball and 9 of 12 P1.35V FPGA balls are cut off from the regulator. B.Cu signals run over split power only, and the button, charge LED and ADC mux have open pins. |
| C | haiku | 2 | 2 | 2 | 3 | 1 | **1** | Unfinished: 114 of 170 nets incomplete (210 unconnected items, 1252 mm of ratsnest), no rail delivered, USB, SD and the DDR clock unrouted. Bypass caps are parked in rows 4-8 mm from the FPGA and 0201 pads are placed on top of header and microSD pads. |

Ranking, best first: A (human) > B (astra) > D (fable) > C (haiku).

Human guess: A (human), 95% sure. A has DDR3 nets tuned to a target length with serpentines (24 address/control nets within 0.22 mm of 15.0 mm), 20 small hand-drawn regulator pours with individual priorities and ten rail islands on In3. Only J3 and J5 are locked in A, while B, C and D share the 19 locked footprints the job describes, so A did not start from the stripped job file. Its violations are legacy-style (dense courtyard overlaps, fills a few microns under a rule), whereas the other three show regular placement grids, parked capacitor rows, incomplete nets or HDI vias used to escape congestion.

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `orangecrab-place-by-fable-20261120-1716.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
