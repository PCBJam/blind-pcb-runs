#!/bin/zsh
# queue-xm.zsh: the overnight queue for the cross-model runs and reviews (11/19-20), as it was used (paths made
# relative). The Mega and macropad runs and the first reviews were started by hand before it. Three independent chains:
#   haiku: after both Glasgow Haiku runs finish -> OrangeCrab (route,place) -> NAS (route,place) -> M.2 route
#   fable: after 03:05 (Fable reset) and both Glasgow Fable runs -> Mega-route review by Fable + OrangeCrab -> NAS -> M.2
#   astra: one task per ChatGPT window, first at $ASTRA_FIRST, then every 5 h; a task that stopped on the usage
#          limit is resumed in the next window instead of starting a new one.
H=${0:A:h}; S=$H/../sandbox; L=${SANDBOX_RUNS:-$H/../runs-local}; HB=${BOARDS:-$H/../boards}; mkdir -p $L/reviews
cd $S
log() { print -r -- "$(date '+%m-%d %H:%M') $*"; }
latest() { local x=($L/$1-20261*(N/)); (( $#x )) && ls -td $x | head -1; }            # newest run dir of e.g. orangecrab-route-haiku
# finished = scored, not running, and not cut by a plan limit (those get resumed, and are not reviewed half done)
done_run() { local d=$(latest $1); [[ -n $d && -f $d/report.json ]] && ! running $d && ! limited $d && ! climited $1; }
wait_runs() { while true; do local ok=1; for r in $@; do done_run $r || ok=0; done; (( ok )) && return; sleep 120; done; }
launch() { # launch <board> <model> <jobs csv> <netn>: like launch-xm.sh, but skips runs that already exist
  local j; for j in ${(s:,:)3}; do
    [[ -n $(print -l $L/$1-$j-$2-2026111[9]-1[89]*(N/) $L/$1-$j-$2-2026111[9]-2*(N/) $L/$1-$j-$2-202611[23]*(N/)) ]] && { log "$2: $1-$j exists, skip"; continue; }
    SANDBOX_NETN=$(( $4 + ${#j} )) $H/launch-xm.sh $1 $2 $j; sleep 5
  done
}
# Claude run cut by the plan's usage limit: its result says so.
climited() { local d=$(latest $1); [[ -n $d ]] && tail -1 $d/transcript.jsonl | grep -q 'out of usage credits\|hit your limit'; }
at() { local t=$(date -j -f '%Y-%m-%d %H:%M' "$1" +%s); while (( $(date +%s) < t )); do sleep 60; done; }

review() { # review <who> <board> <job> <human dir> <stem> <layers>
  local who=$1 b=$2 j=$3; local a=(claude claude-fable-5-2 blind-pcb-sandbox-bt)
  [[ $who == astra ]] && a=(codex gpt-6.2-astra blind-pcb-sandbox-bt-codex)
  AGENT=$a[1] MODEL=$a[2] EFFORT=high SANDBOX_IMAGE=$a[3] LAYERS=$6 SANDBOX_NETN=$(( 100 + RANDOM % 40 )) \
    ./review.sh $b-$j-by-$who $4 $5 $(latest $b-$j-fable) $(latest $b-$j-astra) $(latest $b-$j-haiku) > $L/reviews/$b-$j-by-$who.log 2>&1
}

haiku_chain() {
  wait_runs glasgow-route-haiku glasgow-place-haiku
  log "haiku: orangecrab"; launch orangecrab haiku route,place 210; sleep 300
  wait_runs orangecrab-route-haiku orangecrab-place-haiku
  log "haiku: nas"; launch nas haiku route,place 213; sleep 300
  wait_runs nas-route-haiku nas-place-haiku
  log "haiku: m2"; launch m2 haiku route 216; sleep 300
  wait_runs m2-route-haiku; log "haiku: chain done"
}

fable_chain() {
  at "2026-11-20 03:05"
  # The Glasgow Fable runs ran out of Fable usage at 22:20 (11/19): continue them first (one at a time), with what is
  # left of their 6 h. A run already being resumed is waited for, not resumed twice.
  local r; for r in glasgow-route-fable glasgow-place-fable; do
    while running $(latest $r); do sleep 120; done
    climited $r && { log "fable: resume $r"; $S/resume.sh $(latest $r) >> $(latest $r).resume.log 2>&1; }
  done
  log "fable: orangecrab"; launch orangecrab fable route,place 220; sleep 60
  (review_step fable; review_step fable) &
  sleep 300; wait_runs orangecrab-route-fable orangecrab-place-fable
  review_step fable
  log "fable: nas"; launch nas fable route,place 223; sleep 300
  wait_runs nas-route-fable nas-place-fable
  review_step fable; review_step fable
  log "fable: m2"; launch m2 fable route 226; sleep 300
  wait_runs m2-route-fable
  for k in 1 2 3 4 5 6 7 8 9; do review_step fable; done; log "fable: chain done"
}

# Reviews: a board-job is reviewable once the Fable, Astra and Haiku runs all have a report. Place jobs keep the human
# board (only the macropad shrink left it out). A review stopped on the usage limit is resumed before a new one starts.
typeset -A LAY=(mega 2 glasgow 4 orangecrab 6 nas 4 m2 4)
typeset -A HUM=(mega "$HB/mega Arduino_Mega_2560" glasgow "$HB/glasgow-revc3 glasgow" orangecrab "$HB/orangecrab OrangeCrab"
                nas "$HB/cm4-nvme-nas RaspberryPiNVMeNAS" m2 "$HB/m2-pcie-adapter m2-pcie-adapter")
REVS=(mega-route mega-place glasgow-route glasgow-place orangecrab-route orangecrab-place nas-route nas-place m2-route)
limited() { local x=($1/codex-resume-*.jsonl(N) $1/codex.jsonl(N)) f; (( $#x )) && f=$(ls -t $x | head -1); [[ -n $f ]] && grep -q 'usage limit' $f; }
running() { docker ps --format '{{.Names}}' | grep -q -- "-${1:t}-r\|${${1:t}%-2026*}-agent"; }
review_step() { # review_step <who>: resume a limit-stopped review, else start the next ready one; waits for it
  local who=$1 d
  for d in $L/reviews/*-by-$who-2026*(N/); do
    [[ -f $d/review.json ]] && continue; running $d && return
    if [[ $who == astra ]] && limited $d; then log "$who: resume review ${d:t}"; SANDBOX_NETN=$(( 100 + RANDOM % 40 )) $S/resume.sh $d > $d.resume.log 2>&1; return; fi
  done
  for r in $REVS; do
    local bj=(${(s:-:)r}); [[ -n $(print -l $L/reviews/$r-by-$who-2026*(N/)) ]] && continue
    done_run $r-fable && done_run $r-astra && done_run $r-haiku || continue
    log "$who: review $r"; review $who $bj[1] $bj[2] ${=HUM[$bj[1]]} $LAY[$bj[1]]; return
  done
}
# Astra (11/20 10:50: bigger plan, no 5 h window): up to 2 runs at a time, resuming limit-stopped ones first, plus one
# review at a time next to them.
ASTRA_Q=("mega place" "glasgow route" "glasgow place" "orangecrab route" "orangecrab place" "nas route" "nas place" "m2 route")
astra_runs() { print -l $L/*-astra-20261119-2*(N/) $L/*-astra-202611[23]*(N/); }
astra_chain() {
  local d q busy
  while true; do
    busy=0; for d in $(astra_runs); do running $d && (( busy++ )); done
    if (( busy < 2 )); then
      q=; for d in $(astra_runs); do running $d || ! limited $d || { q=$d; break; }; done
      if [[ -n $q ]]; then log "astra: resume ${q:t}"; ./resume.sh $q >> $q.resume.log 2>&1 &
      else
        for q in $ASTRA_Q; do q=(${=q}); [[ -z $(latest $q[1]-$q[2]-astra) ]] && break; q=; done
        [[ -n $q ]] && { log "astra: run $q"; SANDBOX_NETN=231 $H/launch-xm.sh $q[1] astra $q[2]; }
      fi
    fi
    docker ps --format '{{.Names}}' | grep -q 'review-.*-by-astra' || (review_step astra &)
    sleep 180
  done
}

ASTRA_FIRST=${ASTRA_FIRST:-"2026-11-20 14:20"}
log "queue start; astra first window $ASTRA_FIRST"
haiku_chain & fable_chain & astra_chain & wait
log "queue done"
