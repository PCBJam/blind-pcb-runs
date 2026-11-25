#!/bin/zsh
# launch-xm.sh <board> <models> [jobs]: cross-model runs (Fable / Astra / Haiku) 6 h cap, progress log + bt review.
#   board:  macropad | mega | glasgow | orangecrab | nas | m2
#   models: comma list of fable,astra,haiku       jobs: comma list of route,place (default: both; macropad's place = place + shrink)
# Efforts: Fable high, Astra high, Haiku max. Briefs and KEEP sets are the ones the earlier runs used.
# The images are the sandbox with bt (not in this repo; the runs used its round 11) and, for Astra, Dockerfile.codex on top.
H=${0:A:h}; cd $H/../sandbox
SRC=${BOARDS:-$H/../boards}   # board projects, one folder per board (see boards/README.md)
LOG=${SANDBOX_RUNS:-$H/../runs-local}; mkdir -p $LOG
board=$1; models=(${(s:,:)2}); jobs=(${(s:,:)${3:-route,place}})
export TOOLS=bt PROGRESS=1 HOURS=${HOURS:-6}
typeset -A M=(fable "claude claude-fable-5-2 high blind-pcb-sandbox-bt"
              astra "codex gpt-6.2-astra high blind-pcb-sandbox-bt-codex"
              haiku "claude claude-haiku-5-5 max blind-pcb-sandbox-bt")
# board -> "folder stem"; per job: env for run.sh
typeset -A B=(macropad "macropad-top macropad-top" mega "mega Arduino_Mega_2560" glasgow "glasgow-revc3 glasgow"
              orangecrab "orangecrab OrangeCrab" nas "cm4-nvme-nas RaspberryPiNVMeNAS" m2 "m2-pcie-adapter m2-pcie-adapter")
typeset -A J=(
  macropad-route ""
  macropad-place "BACK=1 BRIEF=briefs/macropad-b.md KEEP=^(SW[2-7]01|D[2-7]01)$"
  mega-route     "BRIEF=briefs/mega-route.md"
  mega-place     "BRIEF=briefs/mega-place.md KEEP=^(J[0-9]+|Y2|FID[0-9]+)$"
  glasgow-route  "BRIEF=briefs/route-4layer.md"
  orangecrab-route "BRIEF=briefs/route-6layer.md"
  orangecrab-place "FLIP=front BRIEF=briefs/orangecrab-place.md KEEP=^(J[0-9]+|H[0-9]+|FID[0-9]+|G\\*\\*\\*)$"
  nas-route      "BRIEF=briefs/route-4layer.md"
  nas-place      "FLIP=front BRIEF=briefs/cm4-place.md KEEP=^(Module1|J[0-9]+|U7|M[0-9]+|H[0-9]+|S[0-9]+)$"
  m2-route       "BRIEF=briefs/route-4layer.md"
  glasgow-place  "FLIP=front BRIEF=briefs/glasgow-place.md KEEP=^(J[0-9]+|MK[0-9]+|FID[0-9]+|NONO_HANA)$"
)
[[ -n ${B[$board]} ]] || { echo "unknown board $board"; exit 1; }
b=(${=B[$board]})
n=${SANDBOX_NETN:-$(( 150 + RANDOM % 80 ))}
for m in $models; do
  a=(${=M[$m]})
  for job in $jobs; do
    (( ${+J[$board-$job]} )) || { echo "no job $board-$job"; continue; }
    name=$board-$job-$m; (( n++ ))
    (env AGENT=$a[1] MODEL=$a[2] EFFORT=$a[3] SANDBOX_IMAGE=$a[4] SANDBOX_NETN=$n ${=J[$board-$job]} \
      ./run.sh $name $SRC/$b[1] $b[2] > $LOG/$name.log 2>&1 &)
    echo "started $name ($a[2] $a[3]) net $n"; sleep 5
  done
done
