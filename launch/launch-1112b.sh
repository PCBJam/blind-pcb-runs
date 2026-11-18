#!/bin/zsh
# launch-1112b.sh route|place: 11/12 evening runs on the bt image (progress log + bt review), 3 h cap for routing-only, 4 h for placing.
#   route: ESP32-PoE-ISO and Glasgow revC3, routing only (placement kept).  place: Glasgow revC3, place + route.
H=${0:A:h}; cd $H/../sandbox
SRC=${BOARDS:-$H/../boards}   # board projects, one folder per board (see boards/README.md)
LOG=${SANDBOX_RUNS:-$H/../runs-local}; mkdir -p $LOG
export SANDBOX_IMAGE=blind-pcb-sandbox-bt TOOLS=bt PROGRESS=1
if [[ $1 == route ]]; then
  (SANDBOX_NETN=71 HOURS=3 BRIEF=briefs/route-4layer.md ./run.sh esp32-route-bt $SRC/esp32-poe-iso ESP32-PoE-ISO_Rev_O > $LOG/esp32-route-bt.log 2>&1 &)
  sleep 5
  (SANDBOX_NETN=72 HOURS=3 BRIEF=briefs/route-4layer.md ./run.sh glasgow-route-bt $SRC/glasgow-revc3 glasgow > $LOG/glasgow-route-bt.log 2>&1 &)
elif [[ $1 == place ]]; then
  (SANDBOX_NETN=73 HOURS=4 FLIP=front BRIEF=briefs/glasgow-place.md KEEP='^(J[0-9]+|MK[0-9]+|FID[0-9]+|NONO_HANA)$' \
    ./run.sh glasgow-place-bt $SRC/glasgow-revc3 glasgow > $LOG/glasgow-place-bt.log 2>&1 &)
fi
echo started $1
