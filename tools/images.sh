#!/bin/zsh
# images.sh [run dir ...]: the committed pictures (default: every run in runs/, plus every board in boards/).
#   run:   img.before.png (the board as the agent got it), img.all.png + img.In<N>.png (inner layers, layers.sh);
#          img.tracks.png comes from score.sh.
#   board: boards/<b>/render/ref.tracks.png (+ ref.all / ref.In<N> on multilayer boards), the human reference.
H=${0:A:h}; S=$H/../scoring
for r in ${@:-$H/../runs/*(/)}; do r=${r:A}; b=($r/input/*.kicad_pcb(N)); [[ -n $b ]] || continue
  [[ -f $r/img.before.png ]] || $S/before.sh $b[1] $r/img.before.png
  [[ -f $r/img.all.png ]] || $S/layers.sh $r/work/${b[1]:t} $r/img
  echo "${r:t}: $(ls $r/img.*.png | wc -l | tr -d ' ') images"; done
(( $# )) && exit 0
for d in $H/../boards/*(/); do b=($d/*.kicad_pcb(N)); [[ -n $b ]] || continue; mkdir -p $d/render
  [[ -f $d/render/ref.tracks.png ]] || { $S/render.sh $b[1] $d/render/ref; rm -f $d/render/ref.{F,B,poured}.png; }
  [[ -f $d/render/ref.all.png ]] || $S/layers.sh $b[1] $d/render/ref
  echo "board ${d:t}: $(ls $d/render | tr '\n' ' ')"; done
