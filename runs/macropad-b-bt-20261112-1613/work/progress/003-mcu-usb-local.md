# 003 – hand-routed MCU neighbourhood and USB entry
Hand-written tracks (scripts/stageA.py, stageB.py), each batch checked with `bt probe` before `bt apply`.
- +3V3 as a C-shaped ring on B.Cu between the QFN pads and the exposed pad; every IOVDD pin drops a 0.2 mm stub onto it.
- +1V1: C116 at pin 45/50 (a 0.2 mm track runs in the 0.65 mm slot between pad ends and cap pads), C115/C117 at pin 23,
  the two sides joined by one F.Cu link.
- USB: pins 46/47 escape inwards to two 0.5/0.3 vias, cross on F.Cu to R103/R104, then U102 flow-through and the connector.
  D+ pads joined under the shell, D- pads joined above the pad row. VBUS: both pads joined under the shell, out to the fuse.
- CC1/CC2: vias under the shell, F.Cu to R101/R102 under D501.
Failed/changed on the way: first version had D+ on the wrong side of U102 (the J101 pad order forces D+ to be the left
line), so U102 was turned and R103/R104 swapped. A via landed 0.18 mm from an LED cutout (probe caught it).
