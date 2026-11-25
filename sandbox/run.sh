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
# MODEL (fable = latest Fable), EFFORT (low|medium|high|xhigh|max, default: the CLI default), BUDGET (USD cap, off by default: on a subscription token it only cuts the run short), HOURS (3) override the defaults.
set -e
H=${0:A:h}; name=$1; src=$2; stem=$3
root=${4:-${SANDBOX_RUNS:-$H/../runs-local}}
# A gitignored .env next to this script may hold the token: CLAUDE_CODE_OAUTH_TOKEN=... or ANTHROPIC_API_KEY=...
[[ -f $H/.env ]] && { set -a; source $H/.env; set +a; }
# Codex's own web search is off: it runs on OpenAI's side (cached index or live), past the proxy's GitHub block.
# AGENT=codex runs OpenAI's Codex CLI instead (image with codex: Dockerfile.codex, e.g. SANDBOX_IMAGE=blind-pcb-sandbox-codex).
# Its login is a copy of a ChatGPT-plan auth.json (CODEX_AUTH, default sandbox/codex-login/auth.json, gitignored),
# put in the run's own Codex home and deleted when the run ends. MODEL defaults to gpt-6.2-astra there; EFFORT is
# model_reasoning_effort (low|medium|high|xhigh|max|ultra; Codex's own default is low).
AGENT=${AGENT:-claude}
# The sandbox's own Codex login (device login into sandbox/codex-login), not the desktop app's:
# ChatGPT refresh tokens are single-use, so two holders of one login log each other out.
CODEX_AUTH=${CODEX_AUTH:-$H/codex-login/auth.json}
if [[ $AGENT == codex ]]; then
  [[ -f $CODEX_AUTH ]] || { echo "need $CODEX_AUTH"; exit 1; }
else
  [[ -n $ANTHROPIC_API_KEY || -n $CLAUDE_CODE_OAUTH_TOKEN ]] || { echo "need ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN"; exit 1; }
fi
out=${root:A}/$name-$(date +%Y%m%d-%H%M)
mkdir -p $out/logs $out/claude-config $out/codex-config; chmod 777 $out/logs $out/claude-config $out/codex-config
node $H/strip.cjs $src $stem $out/work >/dev/null
chmod -R a+rwX $out/work
# SANDBOX_NETN=<0-255>: explicit subnets for the two networks (the daemon's default pools can run out).
if [[ -n $SANDBOX_NETN ]]; then
  source ${0:A:h}/freenet.sh; SANDBOX_NETN=$(freenet $SANDBOX_NETN)
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
# EXTRA=<file> (relative to this folder): appended last, e.g. an extra question for the review.
[[ -n $EXTRA ]] && cat $H/$EXTRA >> $out/brief.md
export SANDBOX_WORK=$out/work SANDBOX_LOGS=$out/logs SANDBOX_CLAUDE=$out/claude-config SANDBOX_CODEX=$out/codex-config
echo "run dir: $out"
print -r -- "$AGENT ${MODEL:-default} ${EFFORT:-default} ${SANDBOX_IMAGE:-build}" > $out/agent.txt
start=$(date +%s)
if [[ $AGENT == codex ]]; then
  cp -p $CODEX_AUTH $out/codex-config/auth.json; chmod 666 $out/codex-config/auth.json
  # stdin closed: codex exec otherwise waits for more prompt on a non-tty stdin.
  $dc run --rm -T agent timeout $(( ${HOURS:-3} * 3600 )) codex exec --json --skip-git-repo-check \
    --dangerously-bypass-approvals-and-sandbox -m ${MODEL:-gpt-6.2-astra} ${EFFORT:+-c} ${EFFORT:+model_reasoning_effort=$EFFORT} \
    -c model_reasoning_summary=auto -c web_search=disabled -C /work "$(cat $out/brief.md)" \
    < /dev/null > $out/codex.jsonl 2> $out/codex.stderr || echo "agent exit $?" | tee $out/exit.txt
  # If Codex refreshed the login during the run, the old refresh token is spent: keep the new one for the next run.
  [[ $out/codex-config/auth.json -nt $CODEX_AUTH ]] && ! cmp -s $out/codex-config/auth.json $CODEX_AUTH && cp $out/codex-config/auth.json $CODEX_AUTH
  rm -f $out/codex-config/auth.json*
else
  $dc run --rm -T agent timeout $(( ${HOURS:-3} * 3600 )) claude -p "$(cat $out/brief.md)" \
    --model ${MODEL:-fable} ${EFFORT:+--effort} $EFFORT --dangerously-skip-permissions --strict-mcp-config ${MCP:+--mcp-config} $MCP \
    ${BUDGET:+--max-budget-usd $BUDGET} --output-format stream-json --verbose \
    > $out/transcript.jsonl 2> $out/claude.stderr || echo "agent exit $?" | tee $out/exit.txt
fi
echo $(( $(date +%s) - start )) > $out/seconds.txt
$dc down -t 2 >/dev/null 2>&1 || true
# Codex: the same transcript shape as Claude (codex2claude.cjs), priced from the token counts.
[[ $AGENT == codex ]] && node $H/codex2claude.cjs $out $(<$out/seconds.txt) ${MODEL:-gpt-6.2-astra} > $out/transcript.jsonl
$H/../scoring/score.sh $out $stem
