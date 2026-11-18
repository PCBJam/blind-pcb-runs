// node stats.cjs <board.kicad_pcb>...: track length (mm) per layer, via count.
const fs = require("fs");
for (const f of process.argv.slice(2)) {
  const t = fs.readFileSync(f, "utf8");
  const len = {};
  for (const m of t.matchAll(/^\t\(segment\s+\(start ([-\d.]+) ([-\d.]+)\)\s+\(end ([-\d.]+) ([-\d.]+)\)[\s\S]*?\(layer "([^"]+)"\)/gm))
    len[m[5]] = (len[m[5]] || 0) + Math.hypot(m[3] - m[1], m[4] - m[2]);
  const vias = (t.match(/^\t\(via\b/gm) || []).length;
  const total = Object.values(len).reduce((a, b) => a + b, 0);
  console.log(f.split("/").slice(-2).join("/").padEnd(55), "length", total.toFixed(0), JSON.stringify(Object.fromEntries(Object.entries(len).map(([k, v]) => [k, +v.toFixed(0)]))), "vias", vias);
}
