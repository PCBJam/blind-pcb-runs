#!/bin/zsh
# score.sh <run dir> <stem>: score a finished run on the host.
# DRC (zones refilled), renders (img.{tracks,F,B,poured}.png), track/via metrics (per role where
# sandbox/roles/<stem>.json exists), the placement check, then report.cjs folds it into <run dir>/report.json.
# Needs kicad-cli 10 (KICAD_CLI), node, rsvg-convert, and docker with the sandbox image for the placement check.
H=${0:A:h}; SB=$H/../sandbox; out=${1:A}; stem=$2; b=$out/work/$stem.kicad_pcb
$H/drc.sh $b $out/drc.json
$H/render.sh $b $out/img $out/drc.json
$H/layers.sh $b $out/img
bounds=$(node $H/bounds.cjs $b)
roles='{}'; [[ -f $SB/roles/$stem.json ]] && roles=$(<$SB/roles/$stem.json)
node $H/lab-metrics.cjs $b "$roles" "$bounds" > $out/metrics.json
node $SB/placement-check.cjs $out/input/$stem.kicad_pcb $b > $out/placement.json
# Placement runs: kept parts unmoved, everything on the board, sides, board size (pcbnew, in the image).
if [[ -f $out/keep.txt ]]; then
  docker run --rm --network none -v $out:/run -v $SB:/sandbox:ro ${SANDBOX_BASE_IMAGE:-blind-pcb-sandbox:latest} python3 /sandbox/place-check.py /run/input/$stem.kicad_pcb /run/work/$stem.kicad_pcb "$(<$out/keep.txt)" $([[ -f $out/back.txt ]] && echo back) 2>/dev/null | tail -1 > $out/place.json
fi
node $SB/report.cjs $out
