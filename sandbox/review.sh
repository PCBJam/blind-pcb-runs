#!/bin/zsh
# review.sh <name> <human project dir> <stem> <run dir> [run dir ...]: blind review of one job's boards.
# The human original and the runs' boards are shuffled into /work/boards/A, B, C, ... (project files only: no notes,
# progress logs, scripts or fab files; every board re-saved by pcbnew so the formatting gives nothing away, and every
# copy gets the human project's schematic). The key stays outside /work, in <out>/key.json.
# The reviewer scores EMI, SI, power, placement, routing and DFM, ranks the boards and guesses the human one
# (briefs/review-boards.md). AGENT/MODEL/EFFORT/SANDBOX_IMAGE as in run.sh; HOURS (2) caps the review.
# LAYERS (2) goes into the brief. NOHUMAN=1 leaves the human board out (for jobs it doesn't meet, e.g. the macropad
# place + shrink); the brief then has no human guess. <human project dir> is still needed for the schematic. The job text is the first run's brief up to its "Tools:" paragraph.
set -e
H=${0:A:h}; name=$1; human=${2:A}; stem=$3; shift 3; runs=(${@:A})
root=${SANDBOX_RUNS:-$H/../runs-local}/reviews
AGENT=${AGENT:-claude}
CODEX_AUTH=${CODEX_AUTH:-$H/codex-login/auth.json}
[[ -f $H/.env ]] && { set -a; source $H/.env; set +a; }
out=${root:A}/$name-$(date +%Y%m%d-%H%M)
mkdir -p $out/logs $out/claude-config $out/codex-config $out/work/boards; chmod 777 $out/logs $out/claude-config $out/codex-config
# Entrants: "human" + each run dir, shuffled.
entrants=(human $runs); [[ -n $NOHUMAN ]] && entrants=($runs)
labels=(A B C D E F G H)
order=($(python3 -c 'import random,sys; a=sys.argv[1:]; random.shuffle(a); print(" ".join(a))' $entrants))
key="{"
for i in {1..$#order}; do
  e=$order[$i]; l=$labels[$i]; d=$out/work/boards/$l; mkdir -p $d
  src=$([[ $e == human ]] && echo $human || echo $e/work)
  for f in $src/$stem.kicad_pcb $src/$stem.kicad_pro $src/*.kicad_dru(N) $src/fp-lib-table(N); do cp $f $d/; done
  for p in $src/*.pretty(N/); do cp -R $p $d/; done
  for s in $human/*.kicad_sch(N); do cp $s $d/; done
  key+="\"$l\": \"$([[ $e == human ]] && echo human || echo ${e:t})\", "
done
print -r -- "${key%, }}" > $out/key.json
chmod -R a+rwX $out/work
# Re-save every board with pcbnew (same version, same writer).
docker run --rm --network none -v $out/work:/work ${SANDBOX_IMAGE:-blind-pcb-sandbox} python3 -c '
import pcbnew, glob
for f in glob.glob("/work/boards/*/*.kicad_pcb"):
    b = pcbnew.LoadBoard(f); pcbnew.SaveBoard(f, b)' 2>/dev/null
labs=${(j:, :)labels[1,$#order]}
job=$(awk '/^Tools:/{exit} {print}' $runs[1]/brief.md)
python3 - $H/briefs/review-boards.md $out/brief.md "$#order" "$labs" "$stem" "${LAYERS:-2}" "$job" "${NOHUMAN:-}" <<'PY'
import sys, re
src, dst, n, labs, stem, layers, job, nohuman = sys.argv[1:]
s = open(src).read()
if nohuman:
    s = re.sub(r"\nOne of the boards was laid out by a human.*?\n", "\n", s)
    s = s.replace(", the ranking and the human guess.", " and the ranking.")
    s = re.sub(r', "human_guess": \{.*?\}\}', "}", s)
    assert "human" not in s
s = s.replace("{{N}}", n).replace("{{LABELS}}", labs).replace("{{STEM}}", stem).replace("{{LAYERS}}", layers).replace("{{JOB}}", job.strip())
open(dst, "w").write(s)
PY
netn=${SANDBOX_NETN:-$(( RANDOM % 60 + 30 ))}
source ${0:A:h}/freenet.sh; netn=$(freenet $netn)
print -l "networks:" "  inside: {ipam: {config: [{subnet: 10.231.$netn.0/24}]}}" "  outside: {ipam: {config: [{subnet: 10.232.$netn.0/24}]}}" > $out/net.yaml
dc=(docker compose -f $H/compose.yaml -f $out/net.yaml -p review-$name)
export SANDBOX_WORK=$out/work SANDBOX_LOGS=$out/logs SANDBOX_CLAUDE=$out/claude-config SANDBOX_CODEX=$out/codex-config SANDBOX_IMAGE
print -r -- "$AGENT ${MODEL:-default} ${EFFORT:-default} ${SANDBOX_IMAGE:-}" > $out/agent.txt
echo "review dir: $out  key: $(<$out/key.json)"
start=$(date +%s)
if [[ $AGENT == codex ]]; then
  cp -p $CODEX_AUTH $out/codex-config/auth.json; chmod 666 $out/codex-config/auth.json
  $dc run --rm -T agent timeout $(( ${HOURS:-2} * 3600 )) codex exec --json --skip-git-repo-check \
    --dangerously-bypass-approvals-and-sandbox -m ${MODEL:-gpt-6.2-astra} ${EFFORT:+-c} ${EFFORT:+model_reasoning_effort=$EFFORT} \
    -c model_reasoning_summary=auto -c web_search=disabled -C /work "$(cat $out/brief.md)" \
    < /dev/null > $out/codex.jsonl 2> $out/codex.stderr || echo "agent exit $?" | tee $out/exit.txt
  [[ $out/codex-config/auth.json -nt $CODEX_AUTH ]] && ! cmp -s $out/codex-config/auth.json $CODEX_AUTH && cp $out/codex-config/auth.json $CODEX_AUTH
  rm -f $out/codex-config/auth.json*
else
  $dc run --rm -T agent timeout $(( ${HOURS:-2} * 3600 )) claude -p "$(cat $out/brief.md)" \
    --model ${MODEL:-fable} ${EFFORT:+--effort} $EFFORT --dangerously-skip-permissions --strict-mcp-config \
    --output-format stream-json --verbose > $out/transcript.jsonl 2> $out/claude.stderr || echo "agent exit $?" | tee $out/exit.txt
fi
echo $(( $(date +%s) - start )) > $out/seconds.txt
$dc down -t 2 >/dev/null 2>&1 || true
[[ $AGENT == codex ]] && node $H/codex2claude.cjs $out $(<$out/seconds.txt) ${MODEL:-gpt-6.2-astra} > $out/transcript.jsonl
cp $out/work/REVIEW.md $out/work/review.json $out/ 2>/dev/null || echo "no review files"
python3 - $out <<'PY'
import json, sys, os
out = sys.argv[1]
try:
    r = json.load(open(f"{out}/review.json")); key = json.load(open(f"{out}/key.json"))
except Exception as e:
    print("unscored:", e); sys.exit()
name = lambda l: key.get(l, l).split("-2026")[0]
print("ranking:", " > ".join(f"{l}={name(l)}" for l in r.get("ranking", [])))
for l, s in r.get("scores", {}).items():
    print(f"  {l} {name(l):28} overall {s.get('overall')}  emi {s.get('emi')} si {s.get('si')} power {s.get('power')} place {s.get('placement')} routing {s.get('routing')}")
g = r.get("human_guess", {}); print(f"human guess: {g.get('board')}={name(g.get('board',''))} ({g.get('confidence')}%)")
PY
