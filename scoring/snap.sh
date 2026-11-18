#!/bin/zsh
# snap.sh <board.kicad_pcb> <out.png> [width=900]: a quick picture of the copper (F.Cu, B.Cu, outline) with
# zone fills taken out, for the router lab's per-step pictures. No refill, no DRC marks.
K=${KICAD_CLI:-/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli}
t=${2:r}.nofill.kicad_pcb
perl -0pe 's/^\t\t\(filled_polygon\b.*?^\t\t\)\n//gms' $1 > $t
[[ -f ${1:r}.kicad_pro ]] && cp ${1:r}.kicad_pro ${t:r}.kicad_pro
$K pcb export svg --mode-single --page-size-mode 2 --exclude-drawing-sheet --drill-shape-opt 2 -l F.Cu,B.Cu,Edge.Cuts -o ${2:r}.svg $t >/dev/null 2>&1
rsvg-convert -w ${3:-900} -b white ${2:r}.svg -o $2
rm -f ${2:r}.svg $t ${t:r}.kicad_pro ${t:r}.kicad_prl
