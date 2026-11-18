#!/bin/zsh
# run.sh <name> <src project dir> <board stem> [runs root]
# Blind agent routing test: strips the board's routing, runs Claude Code
# (latest Fable by default) in the Docker sandbox with only that copy, then scores the result on the host.
# Auth: ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN (from `claude setup-token`) in the env.
# Placement variant: KEEP=<ref regex> locks those footprints and moves every other one off the board
# (place-prep.py); FLIP=front|back also flips every moved footprint onto that side; NOEDGE=1 removes the outline; BACK=1 requires placed parts on B.Cu (scoring only, the brief says it). BRIEF=<file>
# picks another brief (default brief.md).
# SANDBOX_IMAGE=<image> runs another image (e.g. blind-pcb-sandbox-mcp, Dockerfile.mcp) without rebuilding.
# TOOLS=<name> appends briefs/tools-<name>.md (an image with your own tools; the bt tool used in some runs is not part of this repo). ACCEPT=1 appends briefs/acceptance.md.
# MCP=<mcp config json, as seen inside the container> gives the agent MCP servers (default: none).
# MODEL (fable = latest Fable), BUDGET (USD cap, off by default: on a subscription token it only cuts the run short), HOURS (3) override the defaults.
set -e
H=${0:A:h}; name=$1; src=$2; stem=$3
root=${4:-${SANDBOX_RUNS:-$H/../runs-local}}
# A gitignored .env next to this script may hold the token: CLAUDE_CODE_OAUTH_TOKEN=... or ANTHROPIC_API_KEY=...
[[ -f $H/.env ]] && { set -a; source $H/.env; set +a; }
[[ -n $ANTHROPIC_API_KEY || -n $CLAUDE_CODE_OAUTH_TOKEN ]] || { echo "need ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN"; exit 1; }
out=${root:A}/$name-$(date +%Y%m%d-%H%M)
mkdir -p $out/logs $out/claude-config; chmod 777 $out/logs $out/claude-config
node $H/strip.cjs $src $stem $out/work >/dev/null
chmod -R a+rwX $out/work
# SANDBOX_NETN=<0-255>: explicit subnets for the two networks (the daemon's default pools can run out).
if [[ -n $SANDBOX_NETN ]]; then
  print -l "networks:" "  inside: {ipam: {config: [{subnet: 10.231.$SANDBOX_NETN.0/24}]}}" "  outside: {ipam: {config: [{subnet: 10.232.$SANDBOX_NETN.0/24}]}}" > $out/net.yaml
  dc=(docker compose -f $H/compose.yaml -f $out/net.yaml -p routing-sandbox-$name)
else
  dc=(docker compose -f $H/compose.yaml -p routing-sandbox-$name)
fi
[[ -z $SANDBOX_IMAGE ]] && SANDBOX_WORK=$out/work $dc build -q agent
if [[ -n $KEEP ]]; then
  docker run --rm --network none -v $out/work:/work -v $H:/sandbox:ro ${SANDBOX_BASE_IMAGE:-blind-pcb-sandbox:latest} \
    python3 /sandbox/place-prep.py /work/$stem.kicad_pcb "$KEEP" $FLIP ${NOEDGE:+noedge} 2>/dev/null | tail -1 > $out/place-prep.json
  print -r -- "$KEEP" > $out/keep.txt; [[ -n $BACK ]] && touch $out/back.txt
fi
cp -R $out/work $out/input
sed "s/{{STEM}}/$stem/g" ${BRIEF:-$H/brief.md} > $out/brief.md
# TOOLS=<name>: tell the agent about the tools in its image (briefs/tools-<name>.md). briefs/tools-bt.md describes bt, which is not in this repo: TOOLS=bt only makes sense with an image that has it.
# ACCEPT=1: tell it how the result will be checked.
[[ -n $TOOLS && -f $H/briefs/tools-$TOOLS.md ]] && cat $H/briefs/tools-$TOOLS.md >> $out/brief.md
[[ -n $ACCEPT ]] && cat $H/briefs/acceptance.md >> $out/brief.md
# PROGRESS=1: ask for a numbered visual log in /work/progress (failed attempts kept). With TOOLS, also ask for
# a review of those tools at the end (briefs/review-<TOOLS>.md, if it exists).
[[ -n $PROGRESS ]] && cat $H/briefs/progress.md >> $out/brief.md
[[ -n $TOOLS && -f $H/briefs/review-$TOOLS.md ]] && cat $H/briefs/review-$TOOLS.md >> $out/brief.md
export SANDBOX_WORK=$out/work SANDBOX_LOGS=$out/logs SANDBOX_CLAUDE=$out/claude-config
echo "run dir: $out"
start=$(date +%s)
$dc run --rm -T agent timeout $(( ${HOURS:-3} * 3600 )) claude -p "$(cat $out/brief.md)" \
  --model ${MODEL:-fable} --dangerously-skip-permissions --strict-mcp-config ${MCP:+--mcp-config} $MCP \
  ${BUDGET:+--max-budget-usd $BUDGET} --output-format stream-json --verbose \
  > $out/transcript.jsonl 2> $out/claude.stderr || echo "agent exit $?" | tee $out/exit.txt
echo $(( $(date +%s) - start )) > $out/seconds.txt
$dc down -t 2 >/dev/null 2>&1 || true
$H/../scoring/score.sh $out $stem
