# 005 – bulk routing passes (several thrown away)
What: after the hand/guided stages (pairs, USB, PoE, buck, PHY local nets, RMII RX) I let `bt route --all` run net by net.
- Pass 1 (F/B only, no keep-outs for edges and mounting holes): DRC came back with 25 edge-clearance, ~60 mounting-hole keep-out and
  7 isolation errors – bt does not know the board edge clearance, pad-local clearances or my custom rule. Thrown away.
- Pass 2 with 22 `--avoid` boxes: clean, but ~15 nets stayed unrouted (earlier nets box in later ones). `--rip` routed some of them,
  but the tracks it moved ignored the avoid boxes and landed in the keep-outs again.
- Pass 3: I ripped all auto-routed nets to reroute "hardest first" – and by mistake also ripped my hand-routed RMII nets
  (my keep-list replaced `{slash}` in the net names, the board has it literally). Restored the checkpoint and started again.
- Pass 4 (hard nets first, In2 and finally In1 allowed): best result, shown in the picture, but 20 nets still have open links.
Picture: PHY area after a pass – every channel is used by long diagonal tracks, which is why the last nets are boxed in.
`005b` shows one of the ground pads (C22.2, buck output cap) that ended up with no free via site.
