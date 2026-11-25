#!/bin/zsh
# resume.sh <run dir> [hours]: continue a Codex (AGENT=codex) run that stopped early, e.g. on the ChatGPT plan's
# usage limit. Resumes the same session (same context, same /work) with a neutral "Continue." and appends the
# events to codex-resume-<n>.jsonl. seconds.txt adds this leg's time, so it stays agent time, not the wait in
# between. Then the transcript is rebuilt (codex2claude.cjs) and the run scored again.
# hours: what is left of the run's cap (default: 6 minus the time already used).
set -e
H=${0:A:h}; out=${1:A}
# The sandbox's own Codex login (device login into sandbox/codex-login), not the desktop app's:
# ChatGPT refresh tokens are single-use, so two holders of one login log each other out.
CODEX_AUTH=${CODEX_AUTH:-$H/codex-login/auth.json}
read agent model effort image < $out/agent.txt
# A review run (review.sh: key.json, no input board) gets 2 h in all and is not scored, only its review copied out.
review=0 proj=routing-sandbox; [[ -f $out/key.json ]] && review=1 proj=review
(( review )) || { stem=$(ls $out/input/*.kicad_pcb | head -1); stem=${${stem:t}%.kicad_pcb}; }
# Claude runs: the session lives in claude-config/projects (mounted as ~/.claude), so `claude -p --resume` picks it up.
if [[ $agent == codex ]]; then sid=$(jq -r 'select(.type=="thread.started").thread_id' $out/codex.jsonl | head -1)
else sid=$(jq -r 'select(.type=="system" and .subtype=="init").session_id' $out/transcript.jsonl | head -1); fi
used=$(<$out/seconds.txt)
if [[ -n $2 ]]; then left=$(( $2 * 3600 )); else left=$(( (review ? 2 : 6) * 3600 - used )); fi
[[ $effort == default ]] && effort=
(( left > 60 )) || { echo "no time left"; exit 1; }
n=1; while [[ -f $out/codex-resume-$n.jsonl || -f $out/claude-resume-$n.jsonl ]]; do (( n++ )); done
netn=${SANDBOX_NETN:-$(( RANDOM % 100 + 140 ))}
source ${0:A:h}/freenet.sh; netn=$(freenet $netn)
print -l "networks:" "  inside: {ipam: {config: [{subnet: 10.231.$netn.0/24}]}}" "  outside: {ipam: {config: [{subnet: 10.232.$netn.0/24}]}}" > $out/net.yaml
dc=(docker compose -f $H/compose.yaml -f $out/net.yaml -p $proj-${out:t}-r$n)
export SANDBOX_IMAGE=$image SANDBOX_WORK=$out/work SANDBOX_LOGS=$out/logs SANDBOX_CLAUDE=$out/claude-config SANDBOX_CODEX=$out/codex-config
echo "resume $sid (leg $n, ${left}s left)"
start=$(date +%s)
if [[ $agent == codex ]]; then
  cp -p $CODEX_AUTH $out/codex-config/auth.json; chmod 666 $out/codex-config/auth.json
  $dc run --rm -T agent timeout $left codex exec resume --json --skip-git-repo-check \
    --dangerously-bypass-approvals-and-sandbox -m $model ${effort:+-c} ${effort:+model_reasoning_effort=$effort} \
    -c model_reasoning_summary=auto -c web_search=disabled $sid "Continue." \
    < /dev/null > $out/codex-resume-$n.jsonl 2> $out/codex-resume-$n.stderr || echo "agent exit $? (leg $n)" | tee -a $out/exit.txt
  # If Codex refreshed the login during the run, the old refresh token is spent: keep the new one for the next run.
  [[ $out/codex-config/auth.json -nt $CODEX_AUTH ]] && ! cmp -s $out/codex-config/auth.json $CODEX_AUTH && cp $out/codex-config/auth.json $CODEX_AUTH
  rm -f $out/codex-config/auth.json*
else
  [[ -f $out/transcript-leg0.jsonl ]] || cp $out/transcript.jsonl $out/transcript-leg0.jsonl
  $dc run --rm -T agent timeout $left claude -p "Continue." --resume $sid \
    --model $model ${effort:+--effort} $effort --dangerously-skip-permissions --strict-mcp-config --output-format stream-json --verbose \
    > $out/claude-resume-$n.jsonl 2> $out/claude-resume-$n.stderr || echo "agent exit $? (leg $n)" | tee -a $out/exit.txt
fi
echo $(( used + $(date +%s) - start )) > $out/seconds.txt
$dc down -t 2 >/dev/null 2>&1 || true
if [[ $agent == codex ]]; then node $H/codex2claude.cjs $out $(<$out/seconds.txt) $model > $out/transcript.jsonl
else # one transcript: all legs' events, one result with the summed cost and turns and the last leg's text
  python3 - $out $(<$out/seconds.txt) <<'PY2'
import json, sys, glob, re
out, secs = sys.argv[1], int(sys.argv[2])
legs = [f"{out}/transcript-leg0.jsonl"] + sorted(glob.glob(f"{out}/claude-resume-*.jsonl"), key=lambda f: int(re.findall(r"(\d+)\.jsonl$", f)[0]))
lines, res = [], []
for f in legs:
    for l in open(f):
        try: e = json.loads(l)
        except Exception: continue
        (res if e.get("type") == "result" else lines).append(e)
r = dict(res[-1]) if res else {"type": "result", "subtype": "error"}
r["total_cost_usd"] = sum(x.get("total_cost_usd") or 0 for x in res)
r["num_turns"] = sum(x.get("num_turns") or 0 for x in res)
r["duration_ms"] = secs * 1000; r["legs"] = len(legs)
with open(f"{out}/transcript.jsonl", "w") as w:
    for e in lines + [r]: w.write(json.dumps(e) + "\n")
PY2
fi
if (( review )); then cp $out/work/REVIEW.md $out/work/review.json $out/ 2>/dev/null || echo "no review files"; else $H/../scoring/score.sh $out $stem; fi
