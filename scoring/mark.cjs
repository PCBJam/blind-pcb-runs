// node mark.cjs <in.svg> <drc.json> <minX> <minY> <out.svg>: circles on the DRC errors
// (not warnings). KiCad's board-area SVG starts at the board's top-left corner.
const fs = require("fs");
const [svgIn, drc, minX, minY, out] = process.argv.slice(2);
const r = JSON.parse(fs.readFileSync(drc, "utf8"));
const pts = r.violations
  .filter((v) => v.severity === "error" && !["starved_thermal", "courtyards_overlap"].includes(v.type))
  .map((v) => v.items[0].pos);
const marks = pts
  .map((p) => `<circle cx="${(p.x - minX).toFixed(3)}" cy="${(p.y - minY).toFixed(3)}" r="0.9" style="fill:#ff00ff;fill-opacity:0.25;stroke:#ff00ff;stroke-width:0.25"/>`)
  .join("\n");
fs.writeFileSync(out, fs.readFileSync(svgIn, "utf8").replace(/<\/svg>\s*$/, marks + "\n</svg>\n"));
console.log(pts.length, "marks");
