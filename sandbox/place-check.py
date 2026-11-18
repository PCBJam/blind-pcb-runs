# python3 place-check.py <input.kicad_pcb> <result.kicad_pcb> <keep regex> [back]
# Placement-variant checks, run inside the sandbox image: did the kept parts stay put (position,
# rotation, side), is every footprint inside the board outline, which side each placed part is on
# (with "back": every non-kept part must be on B.Cu), and the board's size (outline bbox and area).
import json
import re
import sys

import pcbnew

src, res, keep = sys.argv[1], sys.argv[2], re.compile(sys.argv[3])
want_back = len(sys.argv) > 4 and sys.argv[4] == "back"
a, b = pcbnew.LoadBoard(src), pcbnew.LoadBoard(res)
mm = pcbnew.ToMM


def key(f):
    return f.GetReference() + "|" + f.GetFPIDAsString()


before = {key(f): f for f in a.GetFootprints()}
after = {key(f): f for f in b.GetFootprints()}
kept_moved, missing, off_board, wrong_side = [], [], [], []
sides = {"F": 0, "B": 0}
outline = b.GetBoardEdgesBoundingBox()
poly = pcbnew.SHAPE_POLY_SET()
has_outline = b.GetBoardPolygonOutlines(poly, False)
for k, f in before.items():
    g = after.get(k)
    if g is None:
        missing.append(k)
        continue
    ref = f.GetReference()
    if keep.match(ref) or ref.startswith("REF**"):
        if (f.GetPosition() != g.GetPosition() or f.GetOrientationDegrees() != g.GetOrientationDegrees()
                or f.IsFlipped() != g.IsFlipped()):
            kept_moved.append(ref)
        continue
    side = "B" if g.IsFlipped() else "F"
    sides[side] += 1
    if want_back and side != "B":
        wrong_side.append(ref)
    cb = g.GetBoundingBox(False)
    if has_outline:
        inside = all(poly.Contains(pcbnew.VECTOR2I(px, py)) for px, py in
                     ((cb.GetLeft(), cb.GetTop()), (cb.GetRight(), cb.GetTop()), (cb.GetLeft(), cb.GetBottom()), (cb.GetRight(), cb.GetBottom())))
    else:
        inside = outline.Contains(cb)
    if not inside:
        off_board.append(ref)
area = sum(poly.Outline(i).Area() for i in range(poly.OutlineCount())) / 1e12 if has_outline else None
print(json.dumps({
    "footprints": len(before), "keptMoved": kept_moved, "missing": missing, "added": [k for k in after if k not in before],
    "offBoard": off_board, "wrongSide": wrong_side, "placedSides": sides,
    "outlineMm": [round(mm(outline.GetWidth()), 2), round(mm(outline.GetHeight()), 2)],
    "areaMm2": round(area, 1) if area else None, "outlineClosed": bool(has_outline),
}))
