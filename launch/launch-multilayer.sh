#!/bin/zsh
# launch-multilayer.sh [mcp|bt]: the 11/12 multilayer placement runs (OrangeCrab 6L, ESP32-PoE-ISO 4L kept outline,
# ESP32-PoE-ISO 4L smallest). With "mcp" they run in the KiCad MCP image. Sources: <src root>/{orangecrab,esp32-poe-iso}
# (OrangeCrab r0.2.1 migrated from KiCad 5 with its net classes, fab minimums set to what the original routing uses).
H=${0:A:h}; cd $H/../sandbox
SRC=${BOARDS:-$H/../boards}   # board projects, one folder per board (see boards/README.md)
LOG=${SANDBOX_RUNS:-$H/../runs-local}; mkdir -p $LOG
if [[ $1 == mcp ]]; then export SANDBOX_IMAGE=blind-pcb-sandbox-mcp:latest MCP=/opt/kicad-mcp/mcp.json; sfx=-mcp; fi
if [[ $1 == bt ]]; then export SANDBOX_IMAGE=blind-pcb-sandbox-bt TOOLS=bt; sfx=-bt; fi
export PROGRESS=${PROGRESS-1}; H6=${HOURS:-6}
mcpline() { [[ -n $MCP ]] && sed 's#^Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed.#Tools: `kicad-cli` (KiCad 10.0.8) and the `pcbnew` Python module are installed, and a KiCad MCP server (`kicad`, with a Freerouting autorouter) is connected.#' $1 > ${1:r}$sfx.md && echo ${1:r}$sfx.md || echo $1; }
(SANDBOX_NETN=61 HOURS=$H6 FLIP=front BRIEF=$(mcpline briefs/orangecrab-place.md) KEEP='^(J[0-9]+|H[0-9]+|FID[0-9]+|G\*\*\*)$' \
  ./run.sh orangecrab$sfx $SRC/orangecrab OrangeCrab > $LOG/orangecrab$sfx.log 2>&1 &)
sleep 5
(SANDBOX_NETN=62 HOURS=$H6 FLIP=front BRIEF=$(mcpline briefs/esp32-poe-iso-place.md) KEEP='^(LAN_CON1|USB-UART1|MICRO_SD1|UEXT1|EXT[12]|BAT1|MH[0-9]+|Drill_Slot[0-9]+|FID[0-9]+|Logo_.*|Sign_.*)$' \
  ./run.sh esp32-iso$sfx $SRC/esp32-poe-iso ESP32-PoE-ISO_Rev_O > $LOG/esp32-iso$sfx.log 2>&1 &)
sleep 5
(SANDBOX_NETN=63 HOURS=$H6 FLIP=front NOEDGE=1 BRIEF=$(mcpline briefs/esp32-poe-iso-small.md) KEEP='(?!)' \
  ./run.sh esp32-small$sfx $SRC/esp32-poe-iso ESP32-PoE-ISO_Rev_O > $LOG/esp32-small$sfx.log 2>&1 &)
echo started
