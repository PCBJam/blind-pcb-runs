#!/bin/zsh
# layers.sh <board.kicad_pcb> <out-prefix>: the inner layers, for boards with more than two copper layers.
#   <prefix>.all.png    every copper layer's tracks and vias in one picture (zone fills left out), in KiCad's
#                       layer colours (F.Cu red, B.Cu blue, inner layers in their own colours)
#   <prefix>.In<N>.png  one inner layer with its zones filled, so plane splits and tracks cutting a plane show
# Two-layer boards get nothing (render.sh's tracks image already shows everything).
K=${KICAD_CLI:-/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli}
o=$2; b=${o}.lfill.kicad_pcb; t=${o}.lnofill.kicad_pcb
inner=($(sed -n '/^\t(layers/,/^\t)/p' $1 | grep -oE '"In[0-9]+\.Cu"' | tr -d '"'))
(( ${#inner} )) || exit 0
cp $1 $b; cp ${1:r}.kicad_pro ${b:r}.kicad_pro 2>/dev/null; [[ -f ${1:r}.kicad_dru ]] && cp ${1:r}.kicad_dru ${b:r}.kicad_dru
$K pcb drc --refill-zones --save-board -o ${o}.lfill.rpt $b >/dev/null 2>&1
perl -0pe 's/^\t\t\(filled_polygon\b.*?^\t\t\)\n//gms' $b > $t; cp ${b:r}.kicad_pro ${t:r}.kicad_pro 2>/dev/null
svg() { $K pcb export svg --mode-single --page-size-mode 2 --exclude-drawing-sheet --drill-shape-opt 2 -l $2 -o $3.svg $1 >/dev/null 2>&1
  rsvg-convert -w 1800 -b white $3.svg -o $3.png && rm $3.svg; }
svg $t "${(j:,:)inner},B.Cu,F.Cu,Edge.Cuts" ${o}.all
for l in $inner; do svg $b $l,Edge.Cuts ${o}.${l%.Cu}; done
rm -f $b $t ${b:r}.kicad_pro ${b:r}.kicad_dru ${b:r}.kicad_prl ${t:r}.kicad_pro ${t:r}.kicad_prl ${o}.lfill.rpt
