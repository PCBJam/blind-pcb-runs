#!/bin/zsh
# collect.sh <run dir>...: copy finished runs into runs/<run name>/ with everything raw kept
# (brief, input, work, transcript, proxy logs, scores, renders), minus the agent's Claude and Codex config
# directories (account and session metadata), the docker network file and other per-machine leftovers.
# DEST=<folder> copies somewhere else (cross-model/runs, cross-model/reviews, cross-model/excluded). A review
# (review.sh: key.json, no report.json) is copied too. The strip manifests' source path is made relative.
H=${0:A:h}; dest=${DEST:-$H/../runs}; dest=${dest:A}
for r in $@; do
  r=${r:A}; [[ -f $r/report.json || -f $r/key.json ]] || { echo "skip ${r:t}: no report.json or key.json (still running?)"; continue; }
  mkdir -p $dest
  rsync -a --delete --exclude claude-config --exclude codex-config --exclude net.yaml --exclude 'ask/work' --exclude '.bt-undo' \
    --exclude '.netlocks' $r/ $dest/${r:t}/
  for m in $dest/${r:t}/*.strip-manifest.json(N); do
    python3 -c 'import json,sys,os; f=sys.argv[1]; j=json.load(open(f)); j["src"]="boards/"+os.path.basename(j["src"]); json.dump(j,open(f,"w"),indent=2)' $m
  done
  [[ -f $r/report.json ]] && node $H/summary.cjs $dest/${r:t} >/dev/null
  echo "${r:t}: $(du -sh $dest/${r:t} | cut -f1)"
done
[[ -z $DEST ]] && node $H/index.cjs > $H/../runs/INDEX.md
