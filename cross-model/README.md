# Cross-model runs, November 2026

Raw data behind [Fable, Astra and Haiku lay out the same boards](https://www.pcbjam.com/blog/cross-model-pcb-layout/):
three models on the same eleven board layout jobs, the same sandbox, tools and briefs, then two blind AI reviewers
scoring every result with the human original mixed in.

Start at [INDEX.md](INDEX.md): one row per run and per review, each linking to its `SUMMARY.md`.

## What's here

| Folder | Contents |
|---|---|
| `runs/` | The 33 runs: 11 jobs × Fable 5.2, GPT-6.2-Astra and Haiku 5.5. |
| `reviews/` | The 22 reviews: each job reviewed once by a Fable agent and once by an Astra agent. |
| `excluded/` | Three Astra Glasgow runs we threw out because they downloaded the original design (see below). |

As in `runs/`, git holds the summary side of each folder (`SUMMARY.md`, `brief.md`, `report.json`, the result
picture, the agent's `NOTES.md`, `BT-REVIEW.md` and progress notes; for a review `REVIEW.md`, `review.json` and
`key.json`). The full folder of each is `<name>.tar.xz` on the `cross-model-2026-11` release: transcripts, the input
board, the agent's working directory with its scripts and intermediate boards, the progress pictures, the raw DRC,
and the proxy log. Unpack it into the matching folder here.

## The jobs

| Board | Route only (placement kept) | Place and route |
|---|---|---|
| 6-key macropad (2 layers) | `macropad-route` | `macropad-small`: place on the back and shrink the board, no human board to compare |
| Arduino Mega 2560 clone (2 layers) | `mega-route` (`briefs/mega-route.md`) | `mega-place` (`briefs/mega-place.md`) |
| Glasgow rev C3 (4 layers, FPGA) | `glasgow-route` (`briefs/route-4layer.md`) | `glasgow-place` (`briefs/glasgow-place.md`) |
| OrangeCrab (6 layers, FPGA + DDR3) | `orangecrab-route` (`briefs/route-6layer.md`) | `orangecrab-place` (`briefs/orangecrab-place.md`) |
| CM4 NVMe NAS (4 layers) | `nas-route` (`briefs/route-4layer.md`) | `nas-place` (`briefs/cm4-place.md`) |
| M.2 PCIe adapter (4 layers) | `m2-route` (`briefs/route-4layer.md`) | |

The exact settings (brief, locked parts, flip) per job are in `launch/launch-xm.sh`. Each run's `brief.md` is what
that agent actually got: the job brief plus `briefs/tools-bt.md`, `briefs/progress.md` and `briefs/review-bt.md`.

## Models and settings

| Model | Harness | Effort | Cost |
|---|---|---|---|
| Fable 5.2 (`claude-fable-5-2`) | Claude Code 2.1.322 | high | Claude Code's own report, at API prices |
| GPT-6.2-Astra (`gpt-6.2-astra`) | Codex CLI 0.170.0 (`sandbox/Dockerfile.codex`) | high | OpenAI list price for the tokens Codex reported: $8 / $0.40 / $40 per 1M in / cached / out, reasoning counted as output |
| Haiku 5.5 (`claude-haiku-5-5`) | Claude Code 2.1.322 | max | Claude Code's own report, at API prices |

- **6 hours per run, 2 per review.** The runs used subscriptions. A run that stopped on a plan usage limit was
  resumed in the same session with "Continue." (`sandbox/resume.sh`); its time is agent time only, and its folder
  has the extra legs (`codex-resume-<n>.jsonl`, `claude-resume-<n>.jsonl`). `INDEX.md` marks them with *.
- **Codex transcripts.** `codex.jsonl` is Codex's own `--json` event stream. `transcript.jsonl` is the same run
  converted to Claude Code's stream-json shape (`sandbox/codex2claude.cjs`), so the same scoring and summary scripts
  read both.
- **Tools.** Every run had KiCad 10 (`pcbnew`, `kicad-cli`), Python, Node and `bt`, our command line board tool
  (round 11, described in `sandbox/briefs/tools-bt.md`). As in the earlier runs, bt itself is not part of this
  repo; every bt call and its output is in the transcripts.
- **Network.** The proxy (`sandbox/squid.conf`) started as the blocklist of the earlier runs. On 20 Nov, after the
  excluded Glasgow runs got the original design through the Go module proxy and then a GitHub mirror, it became an
  allowlist: model APIs, package registries, JDK downloads, and chip makers' and fabs' sites. The proxy reads its
  config when a run starts, so the runs started before that change (the macropad and Mega runs among them) ran under
  the blocklist; each run's `logs/access.log` lists every host it reached or was refused. Codex's own web search runs
  on OpenAI's side, past the proxy, so it was turned off (`-c web_search=disabled`) after the macropad runs.

## The reviews

`sandbox/review.sh` builds each review: the three models' boards and the human original (`boards/`) shuffled into
`/work/boards/A`, `B`, `C`, `D`, project files only, every board re-saved by pcbnew so the formatting gives nothing
away, and every copy given the human project's schematic. The letter-to-board key stays outside the sandbox in
`key.json`. The brief is `sandbox/briefs/review-boards.md`; it asks for EMI, signal integrity, power, placement and
routing scores, an overall score, a ranking and a guess at the human board. The macropad shrink job has no human
board, so that review leaves out the human guess (`NOHUMAN=1`).

The queue that ran most of the runs and reviews overnight is `launch/queue-xm.zsh`;
`launch/reviews-fable-1120.zsh` started the remaining Fable reviews.

## The excluded runs

Astra's first three Glasgow runs (two route, one place) are in `excluded/`. Runs one and two fetched the Glasgow
repo through the Go module proxy, run three through a GitHub mirror, and all three said so in their `NOTES.md`. The
brief only says some sites are blocked, not "don't download the original", but the job is to lay out the board, so
they are not part of the results. The kept Astra Glasgow runs ran under the allowlist.

## Caveats

- One run per model and job. Treat the numbers as anecdotes with receipts.
- DRC counts in `INDEX.md` and the summaries are as KiCad 10 reports them. Some boards bring errors of their own
  (footprint-type mismatches on the NAS, courtyard overlaps between fixed parts on the Mega and the OrangeCrab);
  the blog post subtracts those.
- The reviewers are AI agents too, from the same two model families as the entrants, and each rated its own family's
  boards higher. The scores are their opinion, backed by the findings in `REVIEW.md`; check those, not just the
  numbers.
