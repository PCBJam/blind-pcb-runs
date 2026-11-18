#!/bin/zsh
# pack.sh [run dir ...]: one dist/<run>.tar.xz per run (default: every run in runs/), the whole folder, for the
# GitHub release named in SUMMARY.md (RELEASE, default runs-2026-11). Upload: gh release upload <tag> dist/*.tar.xz
H=${0:A:h}; cd $H/../runs; mkdir -p ../dist
for r in ${@:-*(/)}; do r=${r:t}; [[ -f ../dist/$r.tar.xz ]] && { echo "$r: already packed"; continue; }
  tar -cf - $r | xz -T0 -9 > ../dist/$r.tar.xz && echo "$r: $(du -h ../dist/$r.tar.xz | cut -f1)"; done
