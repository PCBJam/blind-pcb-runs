// node bounds.cjs <board.kicad_pcb>: the board outline's bounding box as JSON {minX,minY,maxX,maxY}.
// Reads the coordinates of every Edge.Cuts drawing (lines, arcs, rects, polys); arcs are bounded by their
// start/mid/end points, which is close enough for placing DRC marks and judging "near the edge".
const fs = require("fs");
const t = fs.readFileSync(process.argv[2], "utf8");
const xs = [], ys = [];
// One top-level item per chunk (KiCad writes them at one tab), so a match can't run into the next item.
for (const m of t.matchAll(/^\t\((gr_line|gr_arc|gr_rect|gr_poly|gr_circle)\b[\s\S]*?(?=^\t\(|^\)$)/gm)) {
  if (!m[0].includes('(layer "Edge.Cuts")')) continue;
  for (const p of m[0].matchAll(/\((?:start|end|mid|center|xy) ([-\d.]+) ([-\d.]+)\)/g)) { xs.push(+p[1]); ys.push(+p[2]); }
}
if (!xs.length) { console.log("null"); process.exit(0); }
console.log(JSON.stringify({ minX: Math.min(...xs), minY: Math.min(...ys), maxX: Math.max(...xs), maxY: Math.max(...ys) }));
