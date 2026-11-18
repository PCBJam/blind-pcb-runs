# Blind PCB runs

Raw data from a set of experiments in November 2026: Claude Code running Fable 5.2 gets a KiCad 10 board with its
copper stripped (and, in placement runs, most parts moved off the board) and has to place and route it on its own,
in a sandbox that can't reach the original design. Everything the agent saw and everything it produced is here,
so the runs can be checked, reproduced or extended.

## What's here

| Folder | Contents |
|---|---|
| `sandbox/` | The Docker sandbox (KiCad 10 image + Claude Code, a Squid egress proxy), the run script, the prep scripts that strip the copper and move parts off the board, and every brief that was used. |
| `scoring/` | Host-side scoring: KiCad DRC with zones refilled, copper renders, track/via metrics, placement check, report. |
| `launch/` | The launch scripts of the later runs, as they were used (paths made relative). |
| `boards/` | The original, human-routed board projects the runs start from, each under its own license. See `boards/README.md`. |
| `runs/` | One folder per run. Start at `runs/INDEX.md` (the table) and each run's `SUMMARY.md`. |
| `tools/` | `collect.sh` (copy finished runs in, write their summaries and the index), `summary.cjs`, `index.cjs`, `pack.sh` (build the release archives). |

### What's in git and what's in the release

Each run folder in git holds the summary side: `SUMMARY.md` (task, time, cost, scores, the result image, the
agent's own status paragraph, its progress log, links), `brief.md`, `report.json`, `img.tracks.png`, the agent's
`work/NOTES.md`, `work/BT-REVIEW.md` and `work/progress/*.md`, and `ask/ANSWER.md` where there is one.

The full raw folder of every run is `<run>.tar.xz`, attached to the `runs-2026-11` GitHub release. It holds
everything in the table below, including the transcript, the agent's scripts and intermediate boards, and the
progress pictures. Unpack it into `runs/` and the folder is complete. Transcripts embed every image the agent looked
at, which is why the raw side is about half a gigabyte.

License: the scripts, briefs and docs in this repo are MIT (`LICENSE`). The boards in `boards/` and their stripped copies and results in `runs/` keep their own licenses (`boards/README.md`).

### One run folder (unpacked)

| File | What it is |
|---|---|
| `brief.md` | The exact prompt the agent got (the brief plus any appended sections). |
| `input/` | The board as the agent got it: stripped copy of the project, parts moved off the board in placement runs. |
| `work/` | The agent's working directory as it left it: the board it saved, its scripts, `NOTES.md` (its own summary), `progress/` (numbered pictures and notes it saved along the way, failed attempts included) and `BT-REVIEW.md` where it was asked to review the tools. |
| `transcript.jsonl` | The full Claude Code stream-json transcript: every message, thinking summary, tool call and tool result. |
| `report.json` | Scores: DRC errors by type, unconnected items per net, track length, vias, placement check, the agent's turns, cost and tool counts, the hosts the proxy saw. |
| `drc.json`, `metrics.json`, `placement.json`, `place.json` | The raw inputs to `report.json`. |
| `img.*.png` | Renders of the result: `tracks` (fills removed, DRC errors circled), `F`, `B`, `poured`. |
| `logs/access.log` | Every host the agent's traffic reached through the proxy, allowed or denied. |
| `keep.txt`, `place-prep.json` | Placement runs: which parts stayed locked, which were moved off. |
| `seconds.txt`, `exit.txt` | Wall time; `exit.txt` exists when the agent didn't exit cleanly (124 = stopped by the time limit). |
| `ask/` | Older runs: a follow-up question to the agent about which tools would have made the job faster or cheaper (`ANSWER.md`), with its own transcript. |

The agents' Claude Code config directories (account and session metadata) are not included; the transcript has the
whole session.

## The sandbox

- **Image:** `kicad/kicad:10.0` (amd64, runs under Rosetta on Apple silicon) plus Node, Python and Claude Code 2.1.322. No sudo. The Claude config directory starts empty: no memory, no CLAUDE.md, no MCP servers, no plugins.
- **Network:** the agent's container sits on an internal Docker network; its only way out is a Squid proxy (`sandbox/squid.conf`). The proxy refuses GitHub and its mirrors and caches, arduino.cc, Kitspace and archive.org, so the agent can't download the original design, and logs every host it allows. Everything else, including PyPI and npm, is open. The rule blocking anything containing `pcbjam` is from the original setup, where the boards also lived on pcbjam.com.
- **Run:** `claude -p "<brief>" --model fable --dangerously-skip-permissions --output-format stream-json`, under `timeout` (3, 4 or 6 hours depending on the run).
- **Prep:** `strip.cjs` copies the project without tracks, vias and zones. For placement runs, `place-prep.py` locks the parts that match `KEEP` and moves every other part into a grid below the board (`FLIP=front` also puts them all on the top side; `NOEDGE=1` removes the outline too).

## Reproducing a run

```sh
cd sandbox
docker build --platform linux/amd64 -t blind-pcb-sandbox:latest .
echo 'CLAUDE_CODE_OAUTH_TOKEN=...' > .env        # from `claude setup-token`, or ANTHROPIC_API_KEY=...
# route only, the same brief as the Glasgow routing-only run:
BRIEF=briefs/route-4layer.md HOURS=3 ./run.sh glasgow-route ../boards/glasgow-revc3 glasgow
# place + route, the same locks as glasgow-place:
BRIEF=briefs/glasgow-place.md HOURS=4 FLIP=front KEEP='^(J[0-9]+|MK[0-9]+|FID[0-9]+|NONO_HANA)$' \
  ./run.sh glasgow-place ../boards/glasgow-revc3 glasgow
```

Runs land in `runs-local/`. Scoring runs at the end on the host and needs `kicad-cli` 10 (`KICAD_CLI`), `node`,
`rsvg-convert` and `perl`. `brief.md` in each run folder is what that run actually got, so diffing it against the
files in `sandbox/briefs/` shows which sections were appended.

`SANDBOX_NETN=<0-255>` gives each run's two Docker networks fixed subnets, for running several at once when the
Docker daemon's default address pools run out.

## Tools the agents were given

- **None** (11 Nov runs, Mega runs): KiCad's `pcbnew` Python module and `kicad-cli`, plus whatever the agent installed or wrote itself.
- **A KiCad MCP server** (`macropad-b-mcp`): [mixelpixx/KiCAD-MCP-Server](https://github.com/mixelpixx/KiCAD-MCP-Server) 2.9.0 with Freerouting 2.5.0, built with `sandbox/Dockerfile.mcp`.
- **`bt`** (runs named `*-bt`): a command-line board tool for agents that we started building during these runs, shaped by what the earlier agents asked for (board summary, a clearance probe, a pad-to-pad router, renders, DRC against a baseline, …). The tool itself is not part of this repo. Its description, as the agents got it, is `sandbox/briefs/tools-bt.md`; `run.sh` appends it with `TOOLS=bt`, and `sandbox/briefs/review-bt.md` asks for the review in `work/BT-REVIEW.md`. Each bt run's `brief.md` shows exactly what that agent was told, and its transcript shows every bt call and output. The tool changed between runs (round 3 for the 12–13 Nov runs, round 4 for the PCIe runs, round 6 for the 16 Nov RedBoard runs, which adds pair/bus length tuning), so a bt run's behaviour depends on that version.

**Running without bt:** leave `TOOLS` unset and use the plain sandbox image. The place and route briefs don't mention bt themselves, but check `brief.md` of the run you are reproducing: if it contains the bt section, the agent was told about a tool your image won't have, and that section (and the BT-REVIEW request) has to go.

## Caveats

- One run per setup. Nothing here is a measurement with error bars; treat the numbers as anecdotes with receipts.
- Cost is Claude Code's own figure at API prices. The runs were done on a subscription.
- The schematics of OrangeCrab were missing from that run's input (the strip script dropped KiCad 5 `.sch` files; fixed afterwards), so that agent worked from the netlist.
- Several boards start with DRC findings of their own (footprint library mismatches, castellated pads at the edge, the original Mega's clearance errors under KiCad 10 rules). Compare with the DRC of the input board before reading a run's error count.
- Rule changes: agents may edit net classes and design rules if they have a reason. Both Glasgow runs relaxed clearance to 0.125 mm (from 0.15); see their notes.
