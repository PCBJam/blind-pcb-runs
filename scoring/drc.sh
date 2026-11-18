#!/bin/zsh
# drc.sh <board.kicad_pcb> <out.json>: refill zones, run DRC, print a summary line.
K=${KICAD_CLI:-/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli}
$K pcb drc --refill-zones --severity-error --severity-warning --format json -o "$2" "$1" >/dev/null 2>&1
node -e '
const r=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));const c={};
for(const v of r.violations)c[v.severity[0]+":"+v.type]=(c[v.severity[0]+":"+v.type]||0)+1;
console.log(process.argv[2],"violations",r.violations.length,"unconnected",r.unconnected_items.length,JSON.stringify(c))' "$2" "$(basename $1)"
