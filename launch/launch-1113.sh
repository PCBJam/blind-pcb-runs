#!/bin/zsh
# launch-1113.sh: 11/13 PCIe runs on bt round 4 (image tag :r4), 6 h cap, progress log + bt review.
#   CM4-Nvme-NAS (will127534, MIT): routing only, and place + route. Antmicro m2-pcie-adapter (Apache-2.0): place + route.
#   The briefs say nothing about PCIe, impedance or length matching on purpose: does Fable notice on its own?
H=${0:A:h}; cd $H/../sandbox
SRC=${BOARDS:-$H/../boards}   # board projects, one folder per board (see boards/README.md)
LOG=${SANDBOX_RUNS:-$H/../runs-local}; mkdir -p $LOG
export SANDBOX_IMAGE=blind-pcb-sandbox-bt TOOLS=bt PROGRESS=1 HOURS=6
(SANDBOX_NETN=81 BRIEF=briefs/route-4layer.md ./run.sh cm4-route-bt $SRC/cm4-nvme-nas RaspberryPiNVMeNAS > $LOG/cm4-route-bt.log 2>&1 &)
sleep 5
(SANDBOX_NETN=82 FLIP=front BRIEF=briefs/cm4-place.md KEEP='^(Module1|J[0-9]+|U7|M[0-9]+|H[0-9]+|S[0-9]+)$' \
  ./run.sh cm4-place-bt $SRC/cm4-nvme-nas RaspberryPiNVMeNAS > $LOG/cm4-place-bt.log 2>&1 &)
sleep 5
(SANDBOX_NETN=83 FLIP=front BRIEF=briefs/m2-place.md KEEP='^(J[0-9]+|N[0-9]+)$' \
  ./run.sh m2-place-bt $SRC/m2-pcie-adapter m2-pcie-adapter > $LOG/m2-place-bt.log 2>&1 &)
echo started
