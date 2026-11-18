#!/bin/zsh
# before.sh <board> <out.png>: the board as the agent got it: copper pads, fab outlines (parts off the board too) and the outline.
K=/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
t=$(mktemp -d)/b.kicad_pcb
sed 's/(layer "Edge.Cuts")/(layer "Dwgs.User")/' $1 > $t; cp ${1:r}.kicad_pro ${t:r}.kicad_pro 2>/dev/null
$K pcb export svg --mode-single --page-size-mode 2 --exclude-drawing-sheet --drill-shape-opt 2 -l F.Cu,B.Cu,F.Fab,B.Fab,Dwgs.User -o ${t:r}.svg $t >/dev/null 2>&1
rsvg-convert -w 1800 -b white ${t:r}.svg -o $2
