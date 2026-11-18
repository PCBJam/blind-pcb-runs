#!/bin/zsh
# collect.sh <run dir>...: copy finished runs into runs/<run name>/ with everything raw kept
# (brief, input, work, transcript, proxy logs, scores, renders), minus the agent's Claude config
# directory (account and session metadata), the docker network file and other per-machine leftovers.
H=${0:A:h}
for r in $@; do
  r=${r:A}; [[ -f $r/report.json ]] || { echo "skip ${r:t}: no report.json (still running?)"; continue; }
  rsync -a --delete --exclude claude-config --exclude net.yaml --exclude 'ask/work' --exclude '.bt-undo' $r/ $H/../runs/${r:t}/
  node $H/summary.cjs $H/../runs/${r:t} >/dev/null; echo "${r:t}: $(du -sh $H/../runs/${r:t} | cut -f1)"
done
node $H/index.cjs > $H/../runs/INDEX.md
