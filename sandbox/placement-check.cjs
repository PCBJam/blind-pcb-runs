// node placement-check.cjs <input.kicad_pcb> <result.kicad_pcb>: did the agent keep the placement?
// Compares each footprint's reference, (at x y rot) and side. Prints JSON {footprints, moved: [...]}.
const fs = require("fs");
function fps(file) {
  const t = fs.readFileSync(file, "utf8");
  const out = new Map();
  for (const m of t.matchAll(/^\t\(footprint "([^"]*)"([\s\S]*?)\(property "Reference" "([^"]*)"/gm)) {
    const head = m[2];
    const at = /\(at ([-\d.]+) ([-\d.]+)(?: ([-\d.]+))?\)/.exec(head);
    const layer = /\(layer "([^"]+)"\)/.exec(head);
    out.set(m[3] + "|" + m[1], { x: +at[1], y: +at[2], rot: +(at[3] ?? 0), layer: layer[1] });
  }
  return out;
}
const [a, b] = process.argv.slice(2).map(fps);
const moved = [];
for (const [k, p] of a) {
  const q = b.get(k);
  if (!q) moved.push({ ref: k, missing: true });
  else if (Math.abs(p.x - q.x) > 0.001 || Math.abs(p.y - q.y) > 0.001 || ((p.rot - q.rot) % 360 + 360) % 360 > 0.01 || p.layer !== q.layer)
    moved.push({ ref: k, from: p, to: q });
}
for (const k of b.keys()) if (!a.has(k)) moved.push({ ref: k, added: true });
console.log(JSON.stringify({ footprints: a.size, moved }));
