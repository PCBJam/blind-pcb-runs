# 003 – LVDS pairs FPGA -> J5 (13 pairs) and VIO_AUX

- Tried `bt pair` with all seven top-layer pairs in one call (29 s). Result thrown away: three pairs were necked to
  0.15 mm for 6–17 mm of their length and Z11_P wandered between the J5 pad rows.
- Generated the geometry with my own script instead: centre line per pair, both halves offset +-0.17 mm
  (0.19 track / 0.15 gap, the project's pair setting), 0.15 only inside the ball field. Lanes are nested so nothing
  crosses: westmost pair takes the southmost lane. 7 pairs on F.Cu to the near pad row, 6 pairs (the ones whose balls
  are in rows 2–4) on B.Cu to vias between the J5 pad rows and a 0.9 mm stub to the far row.
- P/N order at the FPGA was chosen to match the J5 pad order, which meant swapping two escape sides and one via site.
- VIO_AUX (FPGA bank supply, comes in on J5.44) cannot leave the BGA anywhere except north between two pairs, so it runs
  beside the B.Cu pairs to J5 and then along the top edge to pin 44 (0.3 mm, about 40 mm long). Known weak point, see NOTES.
- `bt probe`: first try 17 errors (launch offset at a bend, one stub 0.09 mm from a cap pad), second try all 299 clear.
- Intra-pair skew: 0 for three pairs, 0.8–1.0 mm for the others (a ball in row 2 has 0.8 mm more breakout). Not tuned yet.
