// node tools/xm-index.cjs: the cross-model study's committed face. Writes cross-model/reviews/<review>/SUMMARY.md for
// every review (scores, ranking and human guess with the blind letters resolved through key.json) and
// cross-model/INDEX.md (one row per run, one per review). Reads only what is in cross-model/.
const fs = require("fs"), p = require("path");
const RELEASE = process.env.RELEASE || "cross-model-2026-11";
const X = p.join(__dirname, "..", "cross-model");
const hm = (s) => `${Math.floor(s / 3600)}:${String(Math.floor((s % 3600) / 60)).padStart(2, "0")}`;
const sum = (o) => Object.values(o || {}).reduce((a, b) => a + b, 0);
const read = (f) => fs.readFileSync(f, "utf8");
const has = (...x) => fs.existsSync(p.join(...x));
const agentOf = (d) => (has(d, "agent.txt") ? read(p.join(d, "agent.txt")).trim().split(/\s+/) : ["claude"]);
const NAME = { "claude-fable-5-2": "Fable 5.2", "gpt-6.2-astra": "GPT-6.2-Astra", "claude-haiku-5-5": "Haiku 5.5" };
const result = (d) => {
  if (!has(d, "transcript.jsonl")) return {};
  const lines = read(p.join(d, "transcript.jsonl")).trim().split("\n");
  for (let i = lines.length - 1; i >= 0; i--) { try { const e = JSON.parse(lines[i]); if (e.type === "result") return e; } catch {} }
  return {};
};
const legs = (d) => fs.readdirSync(d).filter((x) => /^(codex|claude)-resume-\d+\.jsonl$/.test(x)).length;
const job = (id) => id.replace(/-by-(fable|astra)-\d{8}-\d{4}$/, "").replace(/-(fable|astra|haiku)-\d{8}-\d{4}$/, "");
const entrant = (k) => (k === "human" ? "human" : k.replace(/-\d{8}-\d{4}$/, "").split("-").pop());

// ---- runs ----
const runRows = [];
for (const sub of ["runs", "excluded"]) {
  for (const id of fs.readdirSync(p.join(X, sub)).sort()) {
    const d = p.join(X, sub, id);
    if (!has(d, "report.json")) continue;
    const r = JSON.parse(read(p.join(d, "report.json")));
    const [, model, effort] = agentOf(d);
    const c = r.agent?.costUsd ?? result(d).total_cost_usd;
    runRows.push(`| [${id}](${sub}/${id}/SUMMARY.md) | ${job(id)}${sub === "excluded" ? " (excluded)" : ""} | ${NAME[model] || model} | ${effort} | ${r.seconds ? hm(r.seconds) : "?"}${legs(d) ? "*" : ""} | ${c != null ? "$" + c.toFixed(2) : "n/a"} | ${sum(r.drcErrors)} | ${sum(r.unconnected)} | ${r.totalVias ?? "?"} |`);
  }
}

// ---- reviews ----
const revRows = [];
for (const id of fs.readdirSync(p.join(X, "reviews")).sort()) {
  const d = p.join(X, "reviews", id);
  if (!has(d, "key.json")) continue;
  const key = JSON.parse(read(p.join(d, "key.json")));
  const rv = has(d, "review.json") ? JSON.parse(read(p.join(d, "review.json"))) : null;
  const [, model, effort] = agentOf(d);
  const res = result(d);
  const secs = has(d, "seconds.txt") ? Number(read(p.join(d, "seconds.txt"))) : null;
  const who = (l) => `${l} = ${entrant(key[l] || "?")}`;
  const out = [`# ${id}`, ""];
  out.push("| | |", "|---|---|");
  out.push(`| Job | ${job(id)} |`);
  out.push(`| Reviewer | ${NAME[model] || model} (effort ${effort}) |`);
  out.push(`| Boards | ${Object.keys(key).map(who).join(", ")} |`);
  out.push(`| Time | ${secs ? hm(secs) : "?"}${legs(d) ? ` (resumed ${legs(d)} time${legs(d) > 1 ? "s" : ""} after a plan usage limit)` : ""} |`);
  if (res.total_cost_usd != null) out.push(`| Cost at API prices | $${res.total_cost_usd.toFixed(2)} |`);
  out.push("");
  out.push("The reviewer saw the boards only as letters, each re-saved by pcbnew so the formatting gives nothing away. " +
    "The letters are resolved here from `key.json`, which stayed outside the sandbox. The prompt is [brief.md](brief.md).", "");
  if (rv) {
    out.push("## Scores", "", "| Board | Entrant | EMI | SI | Power | Placement | Routing | Overall | Summary |", "|---|---|---|---|---|---|---|---|---|");
    for (const l of rv.ranking || Object.keys(rv.scores)) {
      const s = rv.scores[l] || {};
      out.push(`| ${l} | ${entrant(key[l] || "?")} | ${s.emi ?? ""} | ${s.si ?? ""} | ${s.power ?? ""} | ${s.placement ?? "n/a"} | ${s.routing ?? ""} | **${s.overall ?? ""}** | ${(s.summary || "").replace(/\|/g, "/").replace(/\n/g, " ")} |`);
    }
    out.push("", `Ranking, best first: ${(rv.ranking || []).map((l) => `${l} (${entrant(key[l] || "?")})`).join(" > ")}.`, "");
    const g = rv.human_guess;
    if (g) out.push(`Human guess: ${g.board} (${entrant(key[g.board] || "?")}), ${g.confidence}% sure. ${(g.why || "").replace(/\n/g, " ")}`, "");
    out.push("The full reasoning per board is in [REVIEW.md](REVIEW.md); the scores as the reviewer wrote them are [review.json](review.json).", "");
  } else out.push("No review.json: the review did not finish.", "");
  out.push("## Raw files", "", `Everything else is in \`${id}.tar.xz\`, attached to the \`${RELEASE}\` release: the transcript, the boards as the reviewer got them (\`work/boards/\`), its own scripts and measurements, and the proxy log.`, "");
  fs.writeFileSync(p.join(d, "SUMMARY.md"), out.join("\n"));
  const g = rv?.human_guess;
  const ranking = rv ? rv.ranking.map((l) => `${entrant(key[l] || "?")} ${rv.scores[l]?.overall}`).join(" > ") : "unfinished";
  revRows.push(`| [${id}](reviews/${id}/SUMMARY.md) | ${job(id)} | ${NAME[model] || model} | ${ranking} | ${g ? `${entrant(key[g.board] || "?")} (${g.confidence}%)` : "n/a"} | ${secs ? hm(secs) : "?"} | ${res.total_cost_usd != null ? "$" + res.total_cost_usd.toFixed(2) : "n/a"} |`);
}

fs.writeFileSync(p.join(X, "INDEX.md"), `# Cross-model runs and reviews

Generated by \`node tools/xm-index.cjs\`. See [README.md](README.md) for the setup.

## Runs

DRC errors and open (unconnected) items are KiCad 10 DRC with zones refilled, on the board the agent saved, as
counted. Some boards bring errors of their own (footprint-type mismatches on the NAS, courtyard overlaps between
the fixed parts on the Mega and the OrangeCrab); the blog post subtracts those. Time is agent time; * marks a run
that was resumed with "Continue." after a plan usage limit. Cost is the API list price (Claude Code's own report;
for Codex, OpenAI's price for the token counts it reported).

| run | job | model | effort | time | cost | DRC errors | open | vias |
|---|---|---|---|---|---|---|---|---|
${runRows.join("\n")}

## Reviews

Each job's boards, the human original included (except the macropad shrink, which has no human board), were
reviewed blind by a Fable and an Astra agent. Ranking is best first with the overall score out of 10.

| review | job | reviewer | ranking | human guess | time | cost |
|---|---|---|---|---|---|---|
${revRows.join("\n")}
`);
console.log(`ok: ${runRows.length} runs, ${revRows.length} reviews`);
