# M.2 → PCIe x4 adapter – layout notes

Status: placed, routed, zones filled. KiCad 10 DRC (with schematic parity): 0 errors / 0 warnings
introduced, 0 unconnected. The only remaining entries (20) are the "footprint library
'antmicro-footprints' not in configuration" notices that the board had before I touched it.
Locked parts are untouched (`bt same`), the .kicad_pro is byte-identical to the original
(no net-class or rule changes were needed).

## Layer use
| Layer | Use |
|---|---|
| F.Cu  | PCIe pairs (vertical runs, ref. In1), +3V3 feed column, +12V pour, +5V track, parts, GND fill elsewhere |
| In1.Cu | solid GND, uncut |
| In2.Cu | solid GND, uncut |
| B.Cu  | PCIe pairs (horizontal runs, ref. In2), +3V3 band, +12V pour, two sideband tracks, GND fill elsewhere |

Both inner layers are unbroken ground on purpose. Every pair changes layer, so each outer layer needs
its own adjacent ground reference (0.12 mm prepreg, the geometry the existing Z85_PCIE class of
0.185/0.145 mm was made for), and the return current only has to hop between two ground planes
through a ground via, never through a capacitor. Power is therefore carried on the outer layers.

## High-speed routing (the main decision)
The netlist forces a layer change: at the M.2 edge the pairs are in the opposite order to their
socket pins, and P/N are mirrored as well. I used that instead of fighting it:

- all pairs leave the M.2 fingers straight, on B.Cu, as horizontal rows at the native 1.5 mm pitch;
- each turns 90° *through its via pair*, with the two vias on the 45° mirror axis of the turn;
- they continue on F.Cu as vertical columns straight to the socket.

Because the transition is mirror-symmetric, the bend and the P/N swap add no intra-pair skew:
`bt length` gives identical P and N lengths for all 9 pairs. Pair lengths are 36.4–40.9 mm
(lane-to-lane mismatch is irrelevant for PCIe). No serpentines anywhere.
- TX pairs (socket side B, top pads): 1 via pair. RX pairs and REFCLK (socket side A, bottom pads):
  a second via pair 2 mm above the pads. All vias are full through vias, so no stubs.
- Crossings are always B-row against F-column with two ground planes in between.
- Ground: one via at every M.2 ground finger and every socket ground pin (placed in the half-column
  between pairs so it serves a top and a bottom pad), one return via at every layer change, and a
  fence via in every row/column gap of the crossing area, so the ground strips between pairs are
  tied to the planes at both ends and along their length (no floating copper fingers).
- Pairs stay coupled at 0.145 mm until ~0.5 mm before the pads; pour clearance to pairs is ≥0.3 mm.
- No AC-coupling capacitors exist in the schematic (host and add-in card carry them); none added.

## Power
- +3V3 (M.2 → socket, up to 3 A): all nine M.2 supply fingers land on a 7 mm wide F.Cu column right
  behind the edge connector; 18 vias take it to a 9 mm wide B.Cu band that runs under the F.Cu pair
  columns straight to socket pins A9/A10, with vias up to B8 and the capacitors. The band avoids the
  B.Cu pair rows completely. Finger groups are strapped together at their inner ends.
- +12V (Molex/pogo → socket): mirrored pours on F and B, ≥10 mm wide, 38 stitching vias.
- +5V: only Molex pin 4 → pogo J5, a 1 mm track on top.
- +3V3_AUX: fed through R1 (0 Ω) right at pin B10 with C5/C6.
- Zones use solid pad connections for SMD and thermal reliefs for through-hole pins only (J3).
- The exposed mask circle at the right-hand edge is the M.2 retaining-screw land. I kept +12V
  more than 3 mm away from it so it is GND on both sides (my first pour put +12V under it on the
  bottom – caught by DRC as a mask bridge).

## Placement
- Everything is on the top side: single-sided assembly, and nothing on the bottom near the M.2 end.
- All nine capacitors sit directly above the socket pins they serve, as the schematic asks
  ("Place close to the PCIe"): C4/C7/C8 (+C9/C3 behind them) at the 3V3 pins, C5/C6/R1 at 3V3_AUX,
  C1/C2 at the 12V pins. Each cap has its own ground via into both planes; 100 nF parts are nearest
  the pin.
- R2 (CLKREQ# to GND) is at the M.2 edge; R3/R4 (WAKE#, PERST#/PWRGD series links) are at the socket.
- WAKE# and PWRGD run on B.Cu under the REFCLK row, 0.5 mm from it; both are static signals.

## Known weak points / not done
- No field-solver check of the 85 Ω geometry; I kept the project's Z85_PCIE width/gap and the given
  stack-up. Ask the fab for impedance control on F/B against In1/In2.
- At each via pair and for the last 0.5 mm into the 1 mm-pitch socket pads the pairs are uncoupled
  (≈1.5 mm per transition). Signal via anti-pads are just the default plane clearance; not optimised.
- The 4.2 mm long socket pads and the M.2 fingers have ground plane underneath (no plane cut-outs
  under the pads). For Gen3 this is normally fine; a Gen4 design would deserve void tuning.
- The ground fence and stitching add up to 218 vias on a small board, 6 of them 0.45/0.25 mm
  (the rest 0.6/0.3). All are within the project's minimums.
- 3 ground vias sit inside the exposed screw land (untented there by the mask opening).
- The +3V3 B.Cu band is perforated by 21 ground-fence vias; plenty of copper remains (>6 mm net).
- WAKE#/PWRGD have two/three vias each and run 25 mm parallel to REFCLK at 0.5 mm; acceptable for
  DC-level signals, but it is the least elegant route on the board.
- Silkscreen: designators in the capacitor cluster are rotated/offset to stay off pads; C7/C8 are
  labelled in the gap above the parts. Legible, but tight.
- Bottom-side copper text and logos were left as they were; GND pour is knocked out around them.
- No teardrops, no test points added (footprints may not be added).
