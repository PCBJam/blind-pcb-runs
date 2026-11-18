// node lab-metrics.cjs <board.kicad_pcb> <roles json> <bounds json>: the router lab's numbers.
// Per role: length per layer and vias. Analog: vias, length within 1 mm of noisy copper (LED,
// power, digital) on the same layer, crossings with noisy copper on the other layer and how many
// of them are at 90°. Power: width, share of length within 3 mm of the board edge, bends.
const fs = require("fs");
const [board, rolesJson, boundsJson] = process.argv.slice(2);
const t = fs.readFileSync(board, "utf8");
const roles = Object.entries(JSON.parse(rolesJson)).map(([k, v]) => [k, new RegExp(v)]);
const b = JSON.parse(boundsJson);
const roleOf = (n) => (roles.find(([, re]) => re.test(n)) || [null])[0];
const segs = [...t.matchAll(/^\t\(segment\s+\(start ([-\d.]+) ([-\d.]+)\)\s+\(end ([-\d.]+) ([-\d.]+)\)\s+\(width ([\d.]+)\)\s+\(layer "([^"]+)"\)\s+\(net "((?:[^"\\]|\\.)*)"\)/gm)].map(
  (m) => ({ ax: +m[1], ay: +m[2], bx: +m[3], by: +m[4], w: +m[5], layer: m[6], net: m[7], role: roleOf(m[7]) }),
);
// Vias are one line when we wrote them and several when KiCad did.
const vias = [...t.matchAll(/^\t\(via\b[\s\S]*?\(net "((?:[^"\\]|\\.)*)"\)/gm)].map((m) => ({ net: m[1], role: roleOf(m[1]) }));
const len = (s) => Math.hypot(s.bx - s.ax, s.by - s.ay);
const r1 = (v) => Math.round(v * 10) / 10;
function pointSeg(px, py, s) {
  const dx = s.bx - s.ax, dy = s.by - s.ay, L2 = dx * dx + dy * dy;
  const u = L2 ? Math.max(0, Math.min(1, ((px - s.ax) * dx + (py - s.ay) * dy) / L2)) : 0;
  return Math.hypot(px - s.ax - u * dx, py - s.ay - u * dy);
}
function crossAt(a, c) {
  const d = (c.bx - c.ax) * (a.by - a.ay) - (c.by - c.ay) * (a.bx - a.ax);
  if (!d) return false;
  const u = ((c.ax - a.ax) * (c.by - c.ay) - (c.ay - a.ay) * (c.bx - c.ax)) / -d;
  const v = ((c.ax - a.ax) * (a.by - a.ay) - (c.ay - a.ay) * (a.bx - a.ax)) / -d;
  return u > 0 && u < 1 && v > 0 && v < 1;
}
const angle = (a, c) => {
  let d = (Math.abs(Math.atan2(a.by - a.ay, a.bx - a.ax) - Math.atan2(c.by - c.ay, c.bx - c.ax)) * 180) / Math.PI;
  d %= 180;
  return d > 90 ? 180 - d : d;
};
const out = { totalTrackMm: Math.round(segs.reduce((s, x) => s + len(x), 0)), totalVias: vias.length, roles: {} };
for (const [role] of roles) {
  const mine = segs.filter((s) => s.role === role);
  if (!mine.length && !vias.some((v) => v.role === role)) continue;
  const layers = {};
  for (const s of mine) layers[s.layer] = (layers[s.layer] || 0) + len(s);
  out.roles[role] = { mm: Math.round(mine.reduce((s, x) => s + len(x), 0)), layers: Object.fromEntries(Object.entries(layers).map(([k, v]) => [k, Math.round(v)])), vias: vias.filter((v) => v.role === role).length };
}
const NOISY = new Set(["led", "power", "digital"]);
const analog = segs.filter((s) => s.role === "analog");
if (analog.length) {
  const noisy = segs.filter((s) => NOISY.has(s.role));
  let near = 0;
  for (const v of analog) {
    const L = len(v), n = Math.max(1, Math.ceil(L / 0.1));
    for (let i = 0; i < n; i++) {
      const px = v.ax + ((v.bx - v.ax) * (i + 0.5)) / n, py = v.ay + ((v.by - v.ay) * (i + 0.5)) / n;
      if (noisy.some((a) => a.layer === v.layer && pointSeg(px, py, a) - a.w / 2 - v.w / 2 <= 1.0)) near += L / n;
    }
  }
  const crossings = [];
  for (const v of analog) for (const a of noisy) if (a.layer !== v.layer && crossAt(v, a)) crossings.push(angle(v, a));
  Object.assign(out.roles.analog, { nearNoisy1mm: r1(near), crossings: crossings.length, crossings90: crossings.filter((d) => d >= 85).length });
}
const power = segs.filter((s) => s.role === "power");
if (power.length) {
  let edge = 0, total = 0;
  for (const s of power) {
    const L = len(s), n = Math.max(1, Math.ceil(L / 0.2));
    for (let i = 0; i < n; i++) {
      const px = s.ax + ((s.bx - s.ax) * (i + 0.5)) / n, py = s.ay + ((s.by - s.ay) * (i + 0.5)) / n;
      if (Math.min(px - b.minX, b.maxX - px, py - b.minY, b.maxY - py) <= 3) edge += L / n;
      total += L / n;
    }
  }
  // Bends: direction changes between consecutive segments that share an end, per 10 mm.
  let bends = 0;
  const key = (x, y) => `${x.toFixed(3)},${y.toFixed(3)}`;
  const ends = new Map();
  for (const s of power) for (const p of [key(s.ax, s.ay), key(s.bx, s.by)]) ends.set(p, [...(ends.get(p) || []), s]);
  for (const list of ends.values()) if (list.length === 2 && list[0].layer === list[1].layer && angle(list[0], list[1]) > 1) bends++;
  Object.assign(out.roles.power, { width: Math.max(...power.map((s) => s.w)), edgeShare: Math.round((100 * edge) / total), bendsPer10mm: r1((10 * bends) / total) });
}
// Parallel: share of a role's length that runs beside another net of the same role (same layer,
// copper edges at most 1 mm apart, within 10°), the way a person bundles a bus.
for (const [role, r] of Object.entries(out.roles)) {
  const mine = segs.filter((s) => s.role === role && len(s) > 1e-3);
  let par = 0, total = 0;
  for (const s of mine) {
    const L = len(s), n = Math.max(1, Math.ceil(L / 0.2));
    for (let i = 0; i < n; i++) {
      const px = s.ax + ((s.bx - s.ax) * (i + 0.5)) / n, py = s.ay + ((s.by - s.ay) * (i + 0.5)) / n;
      if (mine.some((o) => o.net !== s.net && o.layer === s.layer && angle(s, o) <= 10 && pointSeg(px, py, o) - o.w / 2 - s.w / 2 <= 1.0)) par += L / n;
      total += L / n;
    }
  }
  if (total) r.parallel = Math.round((100 * par) / total);
}
console.log(JSON.stringify(out));
