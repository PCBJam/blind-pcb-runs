#!/bin/zsh
# reviews-fable-1120.zsh: the Fable reviews of the FPGA and NAS jobs, started by hand on 11/20 (paths made relative).
H=${0:A:h}; S=$H/../sandbox; L=${SANDBOX_RUNS:-$H/../runs-local}; HB=${BOARDS:-$H/../boards}; mkdir -p $L/reviews
cd $S
latest() { local x=($L/$1-20261*(N/)); (( $#x )) && ls -td $x | head -1; }
typeset -A HUM=(glasgow "$HB/glasgow-revc3 glasgow" orangecrab "$HB/orangecrab OrangeCrab" nas "$HB/cm4-nvme-nas RaspberryPiNVMeNAS")
typeset -A LAY=(glasgow 4 orangecrab 6 nas 4)
n=140
for r in glasgow-route glasgow-place orangecrab-route orangecrab-place nas-route; do b=${r%%-*}
  runs=($(latest $r-fable) $(latest $r-astra) $(latest $r-haiku)); (( $#runs == 3 )) || { print "skip $r: $runs"; continue; }
  print "$r: ${runs:t}"
  AGENT=claude MODEL=claude-fable-5-2 EFFORT=high SANDBOX_IMAGE=blind-pcb-sandbox-bt LAYERS=$LAY[$b] SANDBOX_NETN=$n \
    ./review.sh $r-by-fable ${=HUM[$b]} $runs > $L/reviews/$r-by-fable.log 2>&1 &
  (( n += 3 )); sleep 20
done
wait
