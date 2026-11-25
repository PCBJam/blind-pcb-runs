# nas-route-astra-20261120-1434

| | |
|---|---|
| Task | route only, placement kept |
| Model | gpt-6.2-astra (Codex CLI, `codex exec`, effort high) |
| Tools given | bt (see the README) |
| Time | 0:55 (finished on its own) |
| Cost at API prices | $14.74 (OpenAI list price for the token counts Codex reported, reasoning counted as output) |
| Turns | 180 |
| DRC errors | 17 (footprint_type_mismatch 17) |
| Unconnected | 2 items in 1 nets |
| Copper | 7219 mm of track, 945 vias |
| Hosts reached | chatgpt.com (161), sdmntprsouthcentralus.oaiusercontent.com (1), sdmntprwestus.oaiusercontent.com (1), sdmntprcentralus.oaiusercontent.com (1), repo.maven.apache.org (8), deb.debian.org (1), pypi.org (4), registry.npmjs.org (2), files.pythonhosted.org (2), ab.chatgpt.com (1); denied: api.github.com, github.com |

DRC is KiCad 10 with zones refilled, on the board the agent saved. Some boards start with findings of their own; see `../../../boards/README.md`.

## Pictures

Start is the board as the agent got it (pads and part outlines; in placement runs the free parts sit in a grid below the board). Reference is the human-routed original ([boards/cm4-nvme-nas](../../../boards/cm4-nvme-nas)). The copper pictures show F.Cu (red) and B.Cu (blue) with zone fills left out so the tracks show; DRC errors are circled in magenta on the result.

| Start | Reference | Result |
|---|---|---|
|  | ![](../../../boards/cm4-nvme-nas/render/ref.tracks.png) | ![](img.tracks.png) |

## The agent's own summary

From the start of its [NOTES.md](work/NOTES.md):

> **Routing is complete. Production release is on hold for the supplied schematic and mechanical discrepancies described below.** KiCad 10.0.8 reports zero unconnected items. Against the unrouted starting board, the final check adds zero DRC errors, zero warnings and zero schematic-parity findings.

Its review of the bt tool: [BT-REVIEW.md](work/BT-REVIEW.md).

## Progress log

Saved by the agent as it worked, failed attempts included. The notes are here; the pictures are in the archive.

- [Fixed placement](work/progress/001-placement.md)
- [First PCIe receive pair trial](work/progress/002-pair-trial.md)
- [Seven buck switching stages](work/progress/003-buck-loops.md)
- [Coupled high-speed spans](work/progress/004-coupled-spans.md)
- [Power distribution and ground returns](work/progress/005-power-distribution.md)
- [Control routing and first integrated check](work/progress/006-control-routing.md)
- [Socket supply continuity](work/progress/007-socket-supplies.md)
- [Discarded comparison](work/progress/008-autorouter-comparison.md)
- [Controller escapes](work/progress/009-controller-escapes.md)
- [Local connections on the second inner layer](work/progress/010-inner-breakouts.md)
- [Five-volt feed and a bus-strip trial](work/progress/011-power-mesh-trial.md)
- [Discarded fan-supply perimeter](work/progress/012-perimeter-trial.md)
- [Final board and independent checks](work/progress/013-final-board.md)

## Raw files

The prompt is [brief.md](brief.md); the scores are [report.json](report.json). Everything else is in `nas-route-astra-20261120-1434.tar.xz`, attached to the `cross-model-2026-11` release:
the full transcript (`transcript.jsonl`, converted from Codex's own `codex.jsonl` events, which are there too), the input board, the agent's working directory with its scripts and intermediate boards, the progress pictures, all renders, the raw DRC and metrics, and the proxy log.
