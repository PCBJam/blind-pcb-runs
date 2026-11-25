#!/bin/zsh
# pack.sh [run dir ...]: one dist/<run>.tar.xz per run (default: every run in runs/), the whole folder, for the
# GitHub release named in SUMMARY.md (RELEASE, default runs-2026-11). Upload: gh release upload <tag> dist/*.tar.xz
# ROOT=cross-model/runs (or reviews, excluded) packs that folder instead, into dist/cross-model/.
H=${0:A:h}; base=${ROOT:-runs}; cd $H/../$base
d=$H/../dist; [[ $base == cross-model/* ]] && d=$H/../dist/cross-model; mkdir -p $d
for r in ${@:-*(/)}; do r=${r:t}; [[ -f $d/$r.tar.xz ]] && { echo "$r: already packed"; continue; }
  tar -cf - $r | xz -T0 -9 > $d/$r.tar.xz && echo "$r: $(du -h $d/$r.tar.xz | cut -f1)"; done
