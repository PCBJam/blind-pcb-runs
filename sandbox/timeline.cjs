// node timeline.cjs <run dir> [maxChars]: the agent's run as a readable timeline (its text, every
// tool call with a short input, errors), then a "leak watch": web searches/fetches, network
// commands in Bash (curl/wget/git/pip/npm), proxy denials, and any mention of the board's origin
// (github, HALE, tg44, pcbjam, the board name) in what the agent typed or searched.
const fs = require("fs");
const p = require("path");
const out = process.argv[2];
const max = +(process.argv[3] ?? 400);
const ev = fs
  .readFileSync(p.join(out, "transcript.jsonl"), "utf8")
  .split("\n")
  .filter(Boolean)
  .flatMap((l) => {
    try {
      return [JSON.parse(l)];
    } catch {
      return [];
    }
  });
const short = (s) => {
  s = String(s ?? "").replace(/\s+/g, " ");
  return s.length > max ? s.slice(0, max) + "…" : s;
};
const WATCH = /github|githubusercontent|hale|tg44|pcbjam|h8e10|h4e2|macropad|kicad-arduino|sabogal/i;
const NET = /\b(curl|wget|git (clone|fetch|pull)|pip3? install|npm (i|install)|npx|apt|requests\.get|urllib)\b/;
const watch = [];
let n = 0;
for (const e of ev) {
  if (e.type !== "assistant" && e.type !== "user") continue;
  for (const c of e.message?.content ?? []) {
    if (c.type === "text" && e.type === "assistant") console.log(`\n[${++n}] SAY ${short(c.text)}`);
    if (c.type === "thinking") console.log(`\n[${++n}] THINK ${short(c.thinking)}`);
    if (c.type === "tool_use") {
      const inp = c.input.command ?? c.input.query ?? c.input.url ?? c.input.file_path ?? c.input.pattern ?? JSON.stringify(c.input);
      console.log(`[${++n}] ${c.name} ${short(inp)}`);
      const all = JSON.stringify(c.input);
      // The board name is in every file path, so it only counts on the web or in a network command.
      if (c.name === "WebSearch" || c.name === "WebFetch" || NET.test(all))
        watch.push({ n, tool: c.name, input: short(all), flag: WATCH.exec(all)?.[0] ?? null });
    }
    if (c.type === "tool_result" && c.is_error) console.log(`   ! ${short(typeof c.content === "string" ? c.content : JSON.stringify(c.content))}`);
  }
}
const res = ev.findLast((e) => e.type === "result");
console.log(`\n== result: ${res?.subtype} turns=${res?.num_turns} cost=$${res?.total_cost_usd?.toFixed(2)} ms=${res?.duration_ms}`);
console.log(`\n== leak watch (${watch.length})`);
for (const w of watch) console.log(`[${w.n}] ${w.tool}${w.flag ? ` FLAG(${w.flag})` : ""} ${w.input}`);
const log = p.join(out, "logs/access.log");
if (fs.existsSync(log)) {
  const hosts = {};
  for (const l of fs.readFileSync(log, "utf8").split("\n").filter(Boolean)) {
    const [, , st, , url] = l.split(/\s+/);
    const h = `${st.startsWith("TCP_DENIED") ? "DENIED " : ""}${url.replace(/^\w+:\/\//, "").split(/[:/]/)[0]}`;
    hosts[h] = (hosts[h] ?? 0) + 1;
  }
  console.log("\n== proxy hosts", JSON.stringify(hosts, null, 1));
}
