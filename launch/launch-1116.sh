#!/bin/zsh
# launch-1116.sh: 11/16 SparkFun IoT RedBoard ESP32-P4 WiFi/BLE runs on bt round 6 (image tag :r6, adds pair/bus
# skew tuning), 6 h cap, progress log + bt review. The project's MIPI and USB net classes are removed: the briefs say
# nothing about MIPI, USB high-speed or the antenna, on purpose.
#   redboard-route-bt-a / -b: the same routing-only job twice, to see whether a result is reproducible.
#   redboard-place-bt: place + route; outline, standoffs, connectors, buttons, fiducials and silk labels kept, the C5 module free.
H=${0:A:h}; cd $H/../sandbox
SRC=${BOARDS:-$H/../boards}   # board projects, one folder per board (see boards/README.md)
LOG=${SANDBOX_RUNS:-$H/../runs-local}; mkdir -p $LOG; B=SparkFun_IoT_RedBoard-ESP32-P4_WiFi_BLE
export SANDBOX_IMAGE=blind-pcb-sandbox-bt TOOLS=bt PROGRESS=1 HOURS=6
(SANDBOX_NETN=84 BRIEF=briefs/route-4layer.md ./run.sh redboard-route-bt-a $SRC/redboard-p4-wifi $B > $LOG/redboard-route-bt-a.log 2>&1 &)
sleep 5
(SANDBOX_NETN=85 BRIEF=briefs/route-4layer.md ./run.sh redboard-route-bt-b $SRC/redboard-p4-wifi $B > $LOG/redboard-route-bt-b.log 2>&1 &)
sleep 5
(SANDBOX_NETN=86 FLIP=front BRIEF=briefs/redboard-place.md KEEP='^(H1|ST[0-9]+|J[0-9]+|SW[0-9]+|FID[0-9]+|G.*|kibuzzard-.*)$' \
  ./run.sh redboard-place-bt $SRC/redboard-p4-wifi $B > $LOG/redboard-place-bt.log 2>&1 &)
echo started
