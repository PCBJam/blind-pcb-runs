#!/bin/zsh
# ask.sh <run dir>: ask the agent of a finished sandbox run which tools would have made it faster or cheaper.
# A run with a saved session (claude-config/, run.sh keeps it since 11/12) is resumed, so its own agent
# answers. Older runs get a fresh Fable session in the sandbox with that run's files, notes and timeline.
# The answer lands in <run dir>/ask/ANSWER.md, the transcript in <run dir>/ask/transcript.jsonl.
set -e
H=${0:A:h}; run=${1:A}
[[ -f $H/.env ]] && { set -a; source $H/.env; set +a; }
mkdir -p $run/ask
r=$(node -e 'const l=require("fs").readFileSync(process.argv[1],"utf8").trim().split("\n").map(JSON.parse).findLast(e=>e.type==="result");console.log(Math.round(r=l.duration_ms/60000), l.total_cost_usd.toFixed(2), l.session_id)' $run/transcript.jsonl)
min=${r[(w)1]}; cost=${r[(w)2]}; sid=${r[(w)3]}
sessions=$(ls $run/claude-config/projects/-work 2>/dev/null | grep -c jsonl || true)
if (( sessions > 0 )); then
  work=$run/work; ctx="This is the same session: you remember the run."; resume=(--resume $sid); cfg=$run/claude-config
else
  work=$run/ask/work; rm -rf $work; cp -R $run/work $work; resume=(); cfg=$run/ask/claude-config; mkdir -p $cfg; chmod 777 $cfg
  ctx="Your session could not be kept, so here is the record of it: /work is your final working directory as you left it (your scripts and NOTES.md), /work/_ask/timeline.txt is your run's transcript (your messages, every tool call and its result, shortened)."
fi
mkdir -p $work/_ask; cp $run/brief.md $work/_ask/brief.md
node $H/timeline.cjs $run 600 > $work/_ask/timeline.txt
chmod -R a+rwX $work
prompt=$(sed -e "s|{{CONTEXT}}|$ctx|" -e "s|{{MIN}}|$min|" -e "s|{{COST}}|$cost|" $H/ask-prompt.md)
# EXTRA=<text> adds a question (e.g. about the MCP server in an MCP run).
[[ -n $EXTRA ]] && prompt="$prompt

Also: $EXTRA"
mkdir -p $run/ask/logs; chmod 777 $run/ask/logs
# Explicit subnets (SANDBOX_NETN, 0-255): the daemon's default address pools may be used up by other projects.
n=${SANDBOX_NETN:-$(( RANDOM % 200 + 20 ))}
cat > $run/ask/net.yaml <<Y
networks:
  inside: {ipam: {config: [{subnet: 10.231.$n.0/24}]}}
  outside: {ipam: {config: [{subnet: 10.232.$n.0/24}]}}
Y
dc=(docker compose -f $H/compose.yaml -f $run/ask/net.yaml -p routing-sandbox-ask-${run:t})
SANDBOX_WORK=$work SANDBOX_LOGS=$run/ask/logs SANDBOX_CLAUDE=$cfg $dc run --rm -T agent \
  claude -p "$prompt" --model ${MODEL:-fable} --dangerously-skip-permissions --strict-mcp-config $resume \
  --output-format stream-json --verbose > $run/ask/transcript.jsonl 2> $run/ask/claude.stderr || true
SANDBOX_WORK=$work $dc down -t 2 >/dev/null 2>&1 || true
cp $work/_ask/ANSWER.md $run/ask/ANSWER.md 2>/dev/null && echo "answer: $run/ask/ANSWER.md" || echo "no answer, see $run/ask"
