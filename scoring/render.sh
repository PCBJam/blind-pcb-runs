#!/bin/zsh
# render.sh <board.kicad_pcb> <out-prefix> [drc.json]: PNGs of the copper. <prefix>.tracks.png has zone
# fills taken out so the tracks show; .F/.B one side each; .poured as filled. With a DRC report,
# errors get magenta circles on the tracks image. Needs kicad-cli (KICAD_CLI), rsvg-convert, perl, node.
K=${KICAD_CLI:-/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli}
S=${0:A:h}
o=$2; b=${o}.filled.kicad_pcb; t=${o}.nofill.kicad_pcb
# Refill the pours on a copy first: a routed board still carries the old fills.
cp $1 $b; cp ${1:r}.kicad_pro ${b:r}.kicad_pro; [[ -f ${1:r}.kicad_dru ]] && cp ${1:r}.kicad_dru ${b:r}.kicad_dru
$K pcb drc --refill-zones --save-board -o ${o}.filled.rpt $b >/dev/null 2>&1
perl -0pe 's/^\t\t\(filled_polygon\b.*?^\t\t\)\n//gms' $b > $t
cp ${b:r}.kicad_pro ${t:r}.kicad_pro 2>/dev/null
origin=($(node -e 'const b=JSON.parse(process.argv[1]); console.log(b.minX, b.minY)' "$(node $S/bounds.cjs $b)"))
svg() { $K pcb export svg --mode-single --page-size-mode 2 --exclude-drawing-sheet --drill-shape-opt 2 -l $2 -o $3 $1 >/dev/null 2>&1
  if [[ -n $5 ]]; then node $S/mark.cjs $3 $5 $origin[1] $origin[2] $3 >/dev/null; fi
  rsvg-convert -w ${4:-1800} -b white $3 -o ${3:r}.png && rm $3; }
svg $t F.Cu,B.Cu,Edge.Cuts ${o}.tracks.svg 1800 $3
svg $t F.Cu,Edge.Cuts ${o}.F.svg
svg $t B.Cu,Edge.Cuts ${o}.B.svg
svg $b F.Cu,B.Cu,Edge.Cuts ${o}.poured.svg
rm -f $t ${t:r}.kicad_pro ${t:r}.kicad_prl $b ${b:r}.kicad_pro ${b:r}.kicad_dru ${b:r}.kicad_prl ${o}.filled.rpt
