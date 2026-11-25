# orangecrab-route-by-fable-20261120-1716

| | |
|---|---|
| Job | orangecrab-route |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = haiku, B = human, C = fable, D = astra |
| Time | 0:40 |
| Cost at API prices | $9.94 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| B | human | 8 | 9 | 8 | n/a | 7 | **8** | Complete, through-vias only, two unbroken ground planes, DDR3 length-matched to about 0.5 mm with 2 vias per net, coupled USB pair, pours at the regulators. Needs clean-up (planes 0.15 mm from the edge, 0.10 mm NPTH clearance, duplicate B.Cu zone, zone refill hangs in KiCad 10) and a stackup decision because In2 crosses 108 power-island splits on In3. |
| D | astra | 6 | 5 | 6 | n/a | 4 | **5** | Fully connected and DRC-clean with good USB and DQS pairs, but it relies on 499 blind, buried and micro vias with 115 stacked sites, which is a 2nd-order HDI build and not a standard 6-layer order. DDR3 is unmatched with up to 10 vias per net, the ground plane is perforated under the FPGA, and the DDR supply runs partly on 0.127 mm tracks. |
| C | fable | 5 | 3 | 6 | n/a | 3 | **3** | Sound stackup, real power islands, very tight decoupling and standard vias, but 29 nets are unrouted including USB D-, JTAG TCK/TMS, FPGA_RESET, SD clock and a USB-C CC resistor, so the board cannot be programmed. DDR3 is unmatched and tracks in the In3 ground plane cut slots under the In2 bus. |
| A | haiku | 3 | 2 | 2 | n/a | 2 | **2** | Unfinished: 120 unconnected items (54 nets in pieces) including VBUS and VBATT to the charger, P2.5V to the FPGA, the DDR3 clock, USB D+ and the flash clock. Buck switch nodes are 0.089 mm tracks, the In1 ground plane covers only 38% under the FPGA, and it needs 75 laser microvias. |

Ranking, best first: B (human) > D (astra) > C (fable) > A (haiku).

Human guess: B (human), 92% sure. B has serpentine length tuning to a 15.0 mm target, thousands of sub-0.05 mm segment fragments from interactive routing, hand-drawn power islands with ad-hoc priorities, per-regulator pours, keepout areas, a duplicated zone and rounding-level DRC leftovers from older KiCad versions. A, C and D show tool-like regularity: uniform fan-out stubs including on unconnected pins (A), grid-regular vias in capacitor pads and unmatched straight buses (C), and a single track width with programmatic stacked-via ladders and a custom DRC rule (D).

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `orangecrab-route-by-fable-20261120-1716.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
