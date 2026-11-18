# python3 place-prep.py <board.kicad_pcb> <keep regex> [front|back] [noedge] : placement variant of the blind test.
# Runs inside the sandbox image (needs pcbnew). Footprints whose reference matches <keep regex>
# stay where they are and get locked; every other footprint (logos excepted) is moved off the
# board into a grid below it, keeping its side and rotation, so the agent has to place it.
# With front/back, every moved footprint is also flipped onto that side. With noedge, the board
# outline (Edge.Cuts drawings) is removed too, so the agent draws its own.
# Writes the board in place and prints JSON {kept, moved} for the run's manifest.
import json
import re
import sys

import pcbnew

path, keep = sys.argv[1], re.compile(sys.argv[2])
flags = sys.argv[3:]
side = next((a for a in flags if a in ("front", "back")), None)
b = pcbnew.LoadBoard(path)
bb = b.GetBoardEdgesBoundingBox()
x0 = bb.GetLeft()
y = bb.GetBottom() + pcbnew.FromMM(15)
x = x0
row_h = 0
kept, moved = [], []
fps = sorted(b.GetFootprints(), key=lambda f: f.GetReference())
for f in fps:
    ref = f.GetReference()
    if keep.match(ref) or ref.startswith("REF**"):
        f.SetLocked(True)
        kept.append(ref)
        continue
    f.SetLocked(False)
    if side and f.IsFlipped() != (side == "back"):
        f.Flip(f.GetPosition(), pcbnew.FLIP_DIRECTION_TOP_BOTTOM)
    cb = f.GetBoundingBox(False)
    w, h = cb.GetWidth(), cb.GetHeight()
    if x + w > x0 + pcbnew.FromMM(120):
        x = x0
        y += row_h + pcbnew.FromMM(3)
        row_h = 0
    # Move so the courtyard box's top-left sits at (x, y).
    f.Move(pcbnew.VECTOR2I(x - cb.GetLeft(), y - cb.GetTop()))
    x += w + pcbnew.FromMM(3)
    row_h = max(row_h, h)
    moved.append(ref)
if "noedge" in flags:
    for d in [d for d in b.GetDrawings() if d.GetLayer() == pcbnew.Edge_Cuts]:
        b.Remove(d)
b.Save(path)
print(json.dumps({"kept": kept, "moved": moved}))
