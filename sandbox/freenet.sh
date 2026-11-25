# freenet <n>: print the first subnet number from n up (wrapping in 20..250) that no docker network uses and no other
# launch took in the last 3 minutes. Sourced by run.sh, resume.sh and review.sh; parallel launches otherwise pick the
# same 10.231.n/10.232.n pools and compose fails with "Pool overlaps".
FREENET_LOCKS=${${(%):-%x}:A:h}/../runs-local/.netlocks
freenet() {
  local n=$1 used=$(docker network ls -q | xargs docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' 2>/dev/null)
  local locks=$FREENET_LOCKS; mkdir -p $locks; find $locks -mindepth 1 -mmin +3 -delete 2>/dev/null
  local k; for k in {1..230}; do
    (( n > 250 )) && n=20
    if [[ $used != *"10.231.$n.0/"* && $used != *"10.232.$n.0/"* ]] && mkdir $locks/$n 2>/dev/null; then print $n; return; fi
    (( n++ ))
  done
  print $1
}
