#!/usr/bin/env node
// codex2claude.cjs <run dir> <seconds> [model]: turns the run's `codex exec --json` event streams (codex.jsonl, then
// codex-resume-1.jsonl, ... from resume.sh) into Claude Code
// stream-json events (system / assistant / user / result), so report.cjs, timeline.cjs and ask.sh read an Astra run
// the same way they read a Claude run. Writes to stdout.
//
// Cost: Codex reports tokens only. The result's total_cost_usd is OpenAI's list price for the model
// (short context, Standard tier, see PRICES), with output_tokens taken to include the reasoning tokens.
// The raw counts are kept in result.usage and result.codex_usage. A turn that dies (usage limit, timeout) reports no
// turn.completed, so the counts come from the session rollouts (codex-config/sessions) when those are higher.
const fs = require("node:fs");
const path = require("node:path");
const [, , dir, secs, model = "gpt-6.2-astra"] = process.argv;
// USD per 1M tokens: input, cached input, output. developers.openai.com/api/docs/pricing, read 2026-11-18.
const PRICES = { "gpt-6.2-astra": [8, 0.4, 40], "gpt-6-astra": [10, 1, 50], "gpt-6.2-sol": [2, 0.1, 10] };
const files = fs.readdirSync(dir).filter((f) => /^codex(-resume-\d+)?\.jsonl$/.test(f))
  .sort((a, b) => (Number(a.match(/\d+/)?.[0] ?? 0)) - (Number(b.match(/\d+/)?.[0] ?? 0)));
const ev = files.map((f) => fs.readFileSync(path.join(dir, f), "utf8")).join("\n").split("\n").filter(Boolean).flatMap((l) => {
  try { return [JSON.parse(l)]; } catch { return []; }
});
const out = [];
const emit = (e) => out.push(JSON.stringify(e));
const thread = ev.find((e) => e.type === "thread.started")?.thread_id;
emit({ type: "system", subtype: "init", model, session_id: thread, agent: "codex" });
const u = { input_tokens: 0, cached_input_tokens: 0, cache_write_input_tokens: 0, output_tokens: 0, reasoning_output_tokens: 0 };
let calls = 0, msgs = 0, errors = [];
const kinds = {};
for (const e of ev) {
  // turn.completed usage is the thread total so far (a resumed leg includes the legs before it): keep the largest.
  if (e.type === "turn.completed" && (e.usage?.input_tokens ?? 0) > u.input_tokens) for (const k in u) u[k] = e.usage?.[k] ?? 0;
  if (e.type === "turn.failed" || e.type === "error") errors.push(e.error?.message ?? e.message ?? JSON.stringify(e));
  if (e.type !== "item.completed") continue;
  const it = e.item, id = `codex_${it.id}`;
  kinds[it.type] = (kinds[it.type] ?? 0) + 1;
  if (it.type === "agent_message") { msgs++; emit({ type: "assistant", message: { content: [{ type: "text", text: it.text }] } }); continue; }
  if (it.type === "reasoning") { emit({ type: "assistant", message: { content: [{ type: "thinking", thinking: it.text ?? "" }] } }); continue; }
  let name, input, result, isErr = false;
  if (it.type === "command_execution") {
    name = "Bash"; input = { command: it.command.replace(/^\/bin\/(ba)?sh -lc /, "") };
    result = it.aggregated_output ?? ""; isErr = it.exit_code !== 0;
  } else if (it.type === "file_change") {
    // apply_patch: one call may touch several files. Shown as Edit (update) / Write (add) per file.
    const ch = it.changes ?? [];
    name = ch.every((c) => c.kind === "add") ? "Write" : "Edit";
    input = { file_path: ch.map((c) => c.path).join(", "), changes: ch };
    result = it.status ?? ""; isErr = it.status === "failed";
  } else {
    // web_search, mcp_tool_call, todo_list, sub-agent calls, ...: kept under their own type name.
    name = it.type; input = it; result = it.status ?? "";
  }
  calls++;
  emit({ type: "assistant", message: { content: [{ type: "tool_use", id, name, input }] } });
  emit({ type: "user", message: { content: [{ type: "tool_result", tool_use_id: id, content: String(result), is_error: isErr }] } });
}
// Rollout totals: the last token_count of each session is cumulative for that session.
const roll = { input_tokens: 0, cached_input_tokens: 0, cache_write_input_tokens: 0, output_tokens: 0, reasoning_output_tokens: 0 };
const walk = (d) => (fs.existsSync(d) ? fs.readdirSync(d, { withFileTypes: true }).flatMap((x) =>
  x.isDirectory() ? walk(path.join(d, x.name)) : x.name.endsWith(".jsonl") ? [path.join(d, x.name)] : []) : []);
const bySession = {};
for (const f of walk(path.join(dir, "codex-config", "sessions"))) {
  let sid = f, last = null;
  for (const l of fs.readFileSync(f, "utf8").split("\n")) {
    if (!l.includes('"token_count"') && !l.includes('"session_meta"')) continue;
    try {
      const r = JSON.parse(l);
      if (r.type === "session_meta") sid = r.payload?.id ?? sid;
      const t = r.payload?.info?.total_token_usage;
      if (t) last = t;
    } catch {}
  }
  if (last && (!bySession[sid] || last.input_tokens > bySession[sid].input_tokens)) bySession[sid] = last;
}
for (const t of Object.values(bySession)) for (const k in roll) roll[k] += t[k] ?? 0;
const fromRollout = roll.input_tokens > u.input_tokens;
if (fromRollout) Object.assign(u, roll);
const [pi, pc, po] = PRICES[model] ?? [NaN, NaN, NaN];
const cost = ((u.input_tokens - u.cached_input_tokens) * pi + u.cached_input_tokens * pc + u.output_tokens * po) / 1e6;
emit({
  type: "result", subtype: errors.length ? "error" : "success", is_error: errors.length > 0, agent: "codex",
  duration_ms: Number(secs) * 1000, num_turns: calls + msgs, total_cost_usd: cost, session_id: thread,
  usage: { input_tokens: u.input_tokens - u.cached_input_tokens, cache_read_input_tokens: u.cached_input_tokens, output_tokens: u.output_tokens },
  codex_usage: u, usage_source: fromRollout ? "rollout" : "events", codex_files: files, codex_items: kinds, price_per_mtok: { input: pi, cached_input: pc, output: po },
  errors, result: ev.filter((e) => e.type === "item.completed" && e.item.type === "agent_message").at(-1)?.item.text ?? "",
});
console.log(out.join("\n"));
