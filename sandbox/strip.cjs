// node strip.cjs <src project dir> <board stem> <out dir>
// Copies a KiCad project into <out dir> with every routing hint taken out, for the blind
// agent test (pcb-layout 0002 §13). From the board: tracks, arcs, vias, all zones (copper
// pours, keepouts / rule areas, teardrops, with their fills) and group members that pointed
// at them. Footprints, the outline, silk/fab graphics and text stay, so the placement is kept.
// Files: only the .kicad_pcb, .kicad_pro, .kicad_dru, the schematics and a local
// fp-lib-table / *.pretty. No .kicad_prl, backups, caches, lock files or git metadata.
// Writes <out dir>/../<stem>.strip-manifest.json (kept / dropped) next to the sandbox input.
const fs = require("fs");
const path = require("path");

const [srcDir, stem, outDir] = process.argv.slice(2);
if (!outDir) throw new Error("usage: strip.cjs <src dir> <stem> <out dir>");

/** Top-level children of the (kicad_pcb ...) form: [start, end) offsets and the head word. */
function topLevel(text) {
  const out = [];
  let depth = 0;
  let inStr = false;
  let start = -1;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inStr) {
      if (c === "\\") i++;
      else if (c === '"') inStr = false;
      continue;
    }
    if (c === '"') inStr = true;
    else if (c === "(") {
      depth++;
      if (depth === 2) start = i;
    } else if (c === ")") {
      if (depth === 2) {
        const head = /^\(([a-z_]+)/.exec(text.slice(start, start + 40))[1];
        out.push({ start, end: i + 1, head });
      }
      depth--;
    }
  }
  return out;
}

const DROP = new Set(["segment", "arc", "via", "zone"]);
const pcbPath = path.join(srcDir, `${stem}.kicad_pcb`);
const text = fs.readFileSync(pcbPath, "utf8");
const items = topLevel(text);
const dropped = {};
const droppedUuids = new Set();
let out = "";
let pos = 0;
for (const it of items) {
  if (!DROP.has(it.head)) continue;
  const body = text.slice(it.start, it.end);
  const uuid = /\(uuid "([^"]+)"\)/.exec(body);
  if (uuid) droppedUuids.add(uuid[1]);
  dropped[it.head] = (dropped[it.head] ?? 0) + 1;
  // Take the whole line (leading tab + trailing newline) with it.
  let s = it.start;
  while (s > 0 && text[s - 1] === "\t") s--;
  let e = it.end;
  if (text[e] === "\n") e++;
  out += text.slice(pos, s);
  pos = e;
}
out += text.slice(pos);
// Groups: drop members we removed; a group left empty goes too.
let groupsTrimmed = 0;
out = out.replace(/\(members((?:\s+"[^"]+")*)\s*\)/g, (m, list) => {
  const ids = [...list.matchAll(/"([^"]+)"/g)].map((x) => x[1]);
  const keep = ids.filter((id) => !droppedUuids.has(id));
  if (keep.length === ids.length) return m;
  groupsTrimmed++;
  return `(members ${keep.map((id) => `"${id}"`).join(" ")})`;
});
const kept = {};
for (const it of topLevel(out)) kept[it.head] = (kept[it.head] ?? 0) + 1;

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, `${stem}.kicad_pcb`), out);
const files = [`${stem}.kicad_pcb`];
for (const f of fs.readdirSync(srcDir)) {
  const p = path.join(srcDir, f);
  const ok =
    f === `${stem}.kicad_pro` ||
    f === `${stem}.kicad_dru` ||
    f.endsWith(".kicad_sch") ||
    // KiCad 5 projects: legacy schematic sheets and their symbol cache, plus a schematic PDF we plotted
    // (named *schematic*.pdf; layout PDFs and plots stay out).
    f.endsWith(".sch") ||
    f.endsWith("-cache.lib") ||
    (f.endsWith(".pdf") && /schematic/i.test(f)) ||
    f === "fp-lib-table" ||
    f === "sym-lib-table" ||
    (f.endsWith(".pretty") && fs.statSync(p).isDirectory());
  if (!ok) continue;
  fs.cpSync(p, path.join(outDir, f), { recursive: true });
  files.push(f);
}
const skipped = fs.readdirSync(srcDir).filter((f) => !files.includes(f));
const manifest = { src: path.resolve(srcDir), stem, files, skipped, dropped, groupsTrimmed, kept };
fs.writeFileSync(path.join(outDir, "..", `${stem}.strip-manifest.json`), JSON.stringify(manifest, null, 2));
console.log(JSON.stringify(manifest));
