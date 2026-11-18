// node report.cjs <run dir>: fold a scored sandbox run into <run dir>/report.json, the router-lab
// report shape (drcErrors, unconnected, totalTrackMm, totalVias, roles) plus the placement check,
// the agent's stats from its transcript and the hosts the egress proxy saw (allowed / denied).
const fs = require("fs");
const p = require("path");
const out = process.argv[2];
const rd = (f) => fs.readFileSync(p.join(out, f), "utf8");
const has = (f) => fs.existsSync(p.join(out, f));

const drc = JSON.parse(rd("drc.json"));
const drcErrors = {};
const unconnected = {};
for (const v of drc.violations) if (v.severity === "error") drcErrors[v.type] = (drcErrors[v.type] ?? 0) + 1;
for (const u of drc.unconnected_items) {
  const n = u.items?.[0]?.description?.match(/\[([^\]]+)\]/)?.[1] ?? "?";
  unconnected[n] = (unconnected[n] ?? 0) + 1;
}

const events = (has("transcript.jsonl") ? rd("transcript.jsonl") : "")
  .split("\n")
  .filter(Boolean)
  .map((l) => {
    try {
      return JSON.parse(l);
    } catch {
      return null;
    }
  })
  .filter(Boolean);
const result = events.findLast((e) => e.type === "result") ?? {};
const tools = {};
const web = [];
for (const e of events)
  for (const c of e.message?.content ?? [])
    if (c.type === "tool_use") {
      tools[c.name] = (tools[c.name] ?? 0) + 1;
      if (c.name === "WebFetch" || c.name === "WebSearch") web.push({ tool: c.name, q: c.input.url ?? c.input.query });
    }

const hosts = {};
const denied = {};
for (const l of (has("logs/access.log") ? rd("logs/access.log") : "").split("\n").filter(Boolean)) {
  const [, , status, , url] = l.split(/\s+/);
  if (!url) continue;
  const host = url.replace(/^\w+:\/\//, "").split(/[:/]/)[0];
  const bucket = status.startsWith("TCP_DENIED") ? denied : hosts;
  bucket[host] = (bucket[host] ?? 0) + 1;
}

const report = {
  board: p.basename(out),
  seconds: has("seconds.txt") ? +rd("seconds.txt") : null,
  drcErrors,
  unconnected,
  ...JSON.parse(rd("metrics.json")),
  placement: JSON.parse(rd("placement.json")),
  place: has("place.json") ? JSON.parse(rd("place.json")) : null,
  agent: {
    model: events.find((e) => e.type === "system")?.model,
    costUsd: result.total_cost_usd,
    turns: result.num_turns,
    subtype: result.subtype,
    isError: result.is_error,
    tools,
    web,
    hosts,
    denied,
    notes: has("work/NOTES.md") ? rd("work/NOTES.md") : null,
  },
};
fs.writeFileSync(p.join(out, "report.json"), JSON.stringify(report, null, 1));
const sum = (o) => Object.values(o).reduce((a, b) => a + b, 0);
console.log(
  `${report.board}: ${sum(drcErrors)} DRC errors, ${sum(unconnected)} unconnected, ${report.totalTrackMm} mm, ` +
    `${report.totalVias} vias, moved ${report.placement.moved.length}, $${result.total_cost_usd?.toFixed(2)}, ` +
    `${result.num_turns} turns, denied ${JSON.stringify(denied)}`,
);
