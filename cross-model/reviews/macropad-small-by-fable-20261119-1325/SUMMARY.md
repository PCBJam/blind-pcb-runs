# macropad-small-by-fable-20261119-1325

| | |
|---|---|
| Job | macropad-small |
| Reviewer | Fable 5.2 (effort high) |
| Boards | A = astra, B = fable, C = haiku |
| Time | 0:17 |
| Cost at API prices | $7.62 |

The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).

## Scores

| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |
|---|---|---|---|---|---|---|---|---|
| B | fable | 6 | 6 | 7 | 7 | 6 | **6** | Smallest board with the soundest ground (5 vias under the MCU, unbroken F.Cu, 94 GND vias) and close decoupling. Held back by a 60.8 mm QSPI_SS branch to a mid-board BOOTSEL, QSPI/+5V/LED-data copper 0.35-1.2 mm from the edges, a 13.6 mm crystal run and four vias in small pads. |
| A | astra | 4 | 6 | 5 | 7 | 7 | **5** | Best USB section and cleanest fabrication detail, but the RP2040's only ground goes through one via (119.8,117.05) into an isolated 30 mm2 F.Cu island, and F.Cu is unfilled under the QSPI bus. That must be fixed before ordering; the board is also 13% larger than B. |
| C | haiku | 3 | 4 | 4 | 3 | 5 | **3** | Largest board; the USB-C connector faces the front edge in a recess, 0.63 mm behind the board edge with the key block 5.75 mm from its centre, so plugs are likely to foul. Ground is F.Cu only, with holes under the crystal, MCU and USB, and the LED supply and LED data are routed under the flash, MCU and USB lines. |

Ranking, best first: B (fable) > A (astra) > C (haiku).

The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).

## Raw files

Everything else is in `macropad-small-by-fable-20261119-1325.tar.xz`, attached to the `cross-model-2026-11` release: the transcript, the boards as the reviewer got them (`work/boards/`), its own scripts and measurements, and the proxy log.
