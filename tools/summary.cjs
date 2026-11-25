// node tools/summary.cjs [run dir ...]: write <run dir>/SUMMARY.md for each run (default: every run in runs/).
// SUMMARY.md is the committed face of a run: what the agent was asked, how it went, the scores, the agent's own
// status paragraph, its progress log, and where the raw files are (the run's archive in the GitHub release).
const fs = require("fs"), p = require("path");
const RELEASE = process.env.RELEASE || "runs-2026-11";
const repo = p.join(__dirname, "..");
const root = p.join(__dirname, "..", "runs");
const dirs = process.argv.length > 2 ? process.argv.slice(2).map((d) => p.resolve(d)) : fs.readdirSync(root).map((d) => p.join(root, d));
const hm = (s) => `${Math.floor(s / 3600)}:${String(Math.floor((s % 3600) / 60)).padStart(2, "0")}`;
const sum = (o) => Object.values(o || {}).reduce((a, b) => a + b, 0);

for (const dir of dirs) {
  const id = p.basename(dir);
  const f = (x) => p.join(dir, x);
  const has = (x) => fs.existsSync(f(x));
  const rd = (x) => fs.readFileSync(f(x), "utf8");
  if (!has("report.json")) continue;
  const r = JSON.parse(rd("report.json"));
  const a = r.agent || {};
  const brief = has("brief.md") ? rd("brief.md") : "";
  // agent.txt (later runs): "<claude|codex> <model> <effort> <image>"
  const [agentCli, agentModel, agentEffort] = has("agent.txt") ? rd("agent.txt").trim().split(/\s+/) : ["claude"];
  const codex = agentCli === "codex";
  const legs = fs.readdirSync(dir).filter((x) => /^(codex|claude)-resume-\d+\.jsonl$/.test(x)).length;
  const up = p.relative(dir, repo) || ".";
  const tools = /Board tools: `bt`/.test(brief) ? "bt (see the README)" : /MCP/.test(brief) ? "KiCad MCP server" : "none (pcbnew, kicad-cli, whatever it installed)";
  const place = has("keep.txt");
  const exit = has("exit.txt") ? rd("exit.txt").trim().split("\n").join("; ") : "";
  const stopped = /124/.test(exit) ? "stopped by the time limit" : exit ? exit : "finished on its own";
  const open = sum(r.unconnected), drc = sum(r.drcErrors);
  const out = [];
  out.push(`# ${id}`, "");
  out.push(`| | |`, `|---|---|`);
  out.push(`| Task | ${place ? "place the free parts and route" : "route only, placement kept"} |`);
  out.push(`| Model | ${a.model || agentModel || "?"} (${codex ? "Codex CLI, \`codex exec\`" : "Claude Code, \`claude -p\`"}${agentEffort && agentEffort !== "default" ? `, effort ${agentEffort}` : ""}) |`);
  out.push(`| Tools given | ${tools} |`);
  out.push(`| Time | ${r.seconds ? hm(r.seconds) : "?"} (${stopped}${legs ? `; resumed ${legs} time${legs > 1 ? "s" : ""} with \"Continue.\" after a plan usage limit, time is agent time only` : ""}) |`);
  out.push(`| Cost at API prices | ${a.costUsd != null ? "$" + a.costUsd.toFixed(2) + (codex ? " (OpenAI list price for the token counts Codex reported, reasoning counted as output)" : "") : "not reported (the run was stopped before Claude Code wrote its result)"} |`);
  if (a.turns) out.push(`| Turns | ${a.turns} |`);
  out.push(`| DRC errors | ${drc}${drc ? " (" + Object.entries(r.drcErrors).map(([k, v]) => `${k} ${v}`).join(", ") + ")" : ""} |`);
  out.push(`| Unconnected | ${open}${open ? ` items in ${Object.keys(r.unconnected).length} nets` : ""} |`);
  out.push(`| Copper | ${r.totalTrackMm} mm of track, ${r.totalVias} vias |`);
  if (r.place) {
    const q = r.place;
    out.push(`| Placement | outline ${q.outlineMm ? q.outlineMm.join(" × ") + " mm" : "?"}, parts on top ${q.placedSides?.F ?? "?"} / bottom ${q.placedSides?.B ?? "?"}` +
      `${q.keptMoved?.length ? ", locked parts moved: " + q.keptMoved.join(" ") : ""}${q.offBoard?.length ? ", flagged off the board: " + q.offBoard.join(" ") + " (the check also flags parts that overhang the edge on purpose)" : ""} |`);
  }
  if (a.hosts) out.push(`| Hosts reached | ${Object.entries(a.hosts).map(([h, n]) => `${h} (${n})`).join(", ") || "none"}${a.denied && Object.keys(a.denied).length ? "; denied: " + Object.keys(a.denied).join(", ") : ""} |`);
  out.push("", `DRC is KiCad 10 with zones refilled, on the board the agent saved. Some boards start with findings of their own; see \`${up}/boards/README.md\`.`, "");
  // Start / reference / result. The reference is the human-routed original in boards/, matched by the board file's name.
  const stem = has("input") ? (fs.readdirSync(f("input")).find((x) => x.endsWith(".kicad_pcb")) || "") : "";
  const bdir = stem && fs.readdirSync(p.join(root, "..", "boards")).find((b) => fs.existsSync(p.join(root, "..", "boards", b, stem)));
  const ref = (x) => bdir && fs.existsSync(p.join(root, "..", "boards", bdir, "render", x)) ? `${up}/boards/${bdir}/render/${x}` : null;
  out.push("## Pictures", "");
  out.push("Start is the board as the agent got it (pads and part outlines; in placement runs the free parts sit in a grid below the board). " +
    "Reference is the human-routed original" + (bdir ? ` ([boards/${bdir}](${up}/boards/${bdir}))` : "") + ". " +
    "The copper pictures show F.Cu (red) and B.Cu (blue) with zone fills left out so the tracks show; DRC errors are circled in magenta on the result.", "");
  out.push("| Start | Reference | Result |", "|---|---|---|");
  const cell = (x) => (x ? `![](${x})` : "");
  out.push(`| ${cell(has("img.before.png") && "img.before.png")} | ${cell(ref("ref.tracks.png"))} | ${cell(has("img.tracks.png") && "img.tracks.png")} |`, "");
  const inner = fs.readdirSync(dir).filter((x) => /^img\.In\d+\.png$/.test(x)).sort();
  if (has("img.all.png")) {
    out.push("All copper layers, tracks and vias only (inner layers in KiCad's colours, under the outer layers), then each inner layer with its zones filled, " +
      "so plane splits and tracks cutting through a plane show:", "", "| Layer | Reference | Result |", "|---|---|---|");
    out.push(`| all copper | ${cell(ref("ref.all.png"))} | ${cell("img.all.png")} |`);
    for (const l of inner) { const n = l.replace(/^img\.|\.png$/g, ""); out.push(`| ${n}.Cu | ${cell(ref(`ref.${n}.png`))} | ${cell(l)} |`); }
    out.push("");
  }
  if (has("work/NOTES.md")) {
    const notes = rd("work/NOTES.md").split("\n");
    const firstPara = [];
    for (const l of notes.slice(1)) { if (!l.trim() && firstPara.length) break; if (l.trim() && !l.startsWith("#")) firstPara.push(l); }
    out.push("## The agent's own summary", "", "From the start of its [NOTES.md](work/NOTES.md):", "", ...firstPara.map((l) => "> " + l), "");
  } else out.push("## The agent's own summary", "", "None: the run ended before the agent wrote NOTES.md.", "");
  if (has("work/BT-REVIEW.md")) out.push(`Its review of the bt tool: [BT-REVIEW.md](work/BT-REVIEW.md).`, "");
  if (has("work/progress")) {
    const mds = fs.readdirSync(f("work/progress")).filter((x) => x.endsWith(".md")).sort();
    if (mds.length) {
      out.push("## Progress log", "", "Saved by the agent as it worked, failed attempts included. The notes are here; the pictures are in the archive.", "");
      for (const m of mds) out.push(`- [${(rd("work/progress/" + m).split("\n")[0] || m).replace(/^#+\s*/, "")}](work/progress/${m})`);
      out.push("");
    }
  }
  if (has("ask/ANSWER.md")) out.push("## Follow-up", "", "Asked afterwards which tools would have made the job faster or cheaper: [ANSWER.md](ask/ANSWER.md).", "");
  out.push("## Raw files", "",
    `The prompt is [brief.md](brief.md); the scores are [report.json](report.json). Everything else is in \`${id}.tar.xz\`, attached to the \`${RELEASE}\` release:`,
    (codex ? "the full transcript (`transcript.jsonl`, converted from Codex's own `codex.jsonl` events, which are there too), the input board," : "the full transcript (`transcript.jsonl`), the input board,") + " the agent's working directory with its scripts and intermediate boards, the progress pictures, all renders, the raw DRC and metrics, and the proxy log.", "");
  fs.writeFileSync(f("SUMMARY.md"), out.join("\n"));
}
console.log("ok");
