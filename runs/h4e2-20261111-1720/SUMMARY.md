# h4e2-20261111-1720

| | |
|---|---|
| Task | route only, placement kept |
| Model | claude-fable-5-2 (Claude Code, `claude -p`) |
| Tools given | none (pcbnew, kicad-cli, whatever it installed) |
| Time | 0:52 (finished on its own) |
| Cost at API prices | $16.42 |
| Turns | 74 |
| DRC errors | 0 |
| Unconnected | 0 |
| Copper | 1965 mm of track, 242 vias |
| Hosts reached | api.anthropic.com (8), http-intake.logs.us5.datadoghq.com (55), files.pythonhosted.org (2), pypi.org (2) |

DRC is KiCad 10 with zones refilled, on the board the agent saved. Some boards start with findings of their own; see `../../boards/README.md`.

## Pictures

Start is the board as the agent got it (pads and part outlines; in placement runs the free parts sit in a grid below the board). Reference is the human-routed original ([boards/h4e2](../../boards/h4e2)). The copper pictures show F.Cu (red) and B.Cu (blue) with zone fills left out so the tracks show; DRC errors are circled in magenta on the result.

| Start | Reference | Result |
|---|---|---|
| ![](img.before.png) | ![](../../boards/h4e2/render/ref.tracks.png) | ![](img.tracks.png) |

## The agent's own summary

From the start of its [NOTES.md](work/NOTES.md):

> Result: `/work/H4E2.kicad_pcb` is fully routed (2 layers, 0 unconnected). KiCad 10.0.8 DRC with the
> project rules + `H4E2.kicad_dru` reports no clearance, short, edge, hole, annular or unconnected
> violations. The only messages left are the ones the unrouted board already had: the missing
> `HALE-git` footprint library (10 warnings), the two logo footprints (duplicate/extra footprint) and
> the excluded NPTH-in-courtyard under the display. The final report is `routing/drc_final.rpt`.

## Follow-up

Asked afterwards which tools would have made the job faster or cheaper: [ANSWER.md](ask/ANSWER.md).

## Raw files

The prompt is [brief.md](brief.md); the scores are [report.json](report.json). Everything else is in `h4e2-20261111-1720.tar.xz`, attached to the `runs-2026-11` release:
the full transcript (`transcript.jsonl`), the input board, the agent's working directory with its scripts and intermediate boards, the progress pictures, all renders, the raw DRC and metrics, and the proxy log.
