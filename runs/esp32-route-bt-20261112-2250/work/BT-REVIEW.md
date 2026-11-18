# bt – review after routing ESP32-PoE-ISO Rev.O

I used `bt` for almost everything except the geometry of the critical nets, which I computed by hand and fed to
`bt probe` / `bt apply` as items.json. Counts are approximate (from memory of the session).

## What I used, how often, and what it was worth

| Command | Uses | Verdict |
|---|---|---|
| `bt board` | 3 | **Very good.** One call gave rules, classes, every part and every net with pad coordinates. This replaced what would have been a pcbnew script and several hundred lines of parsing. Output is long (25 kB); it was truncated in my terminal and I had to page it. A `--nets-only` / `--parts-only` switch would help. |
| `bt part` | ~8 | **Very good.** Pad position + size + rotation + net in one line is exactly what hand-routing needs. |
| `bt probe` | ~20 | **The most valuable command.** I wrote ~450 hand-computed segments (Ethernet pairs, USB, PoE, PHY fan-out, RMII lanes); probe told me in 1–2 s which ones were wrong and by how much, with the offending object named. Every error it reported was real. It also applied my custom `.kicad_dru` isolation rule (1.4 mm) correctly. Without it I would have needed a KiCad DRC round trip per attempt. |
| `bt apply` | ~25 | Good, dependable. "skipped N already on the board" also turned out to be a handy way to detect that something had moved my copper (see shove below). |
| `bt zone` / `bt fill` | ~12 / ~10 | Good. Plain polygon in, zone out, project file untouched. Missing: a way to edit or delete an existing zone (I rebuilt the board from the original + zone script every time an outline changed), and thermal/solid/min-width options per zone beyond `--solid`. |
| `bt render` | ~12 | Good for the progress log and for a sanity look; labelled pads at high zoom were useful for planning. Two fills of different nets on different layers are drawn in the same colour, so an In1+In2 overlay is hard to read. |
| `bt plane` | 3 | **Good and fast** (3 s for 59 GND pads). It reports honestly which pads got no via. But it claimed "the vias join it once filled" for +3.3V vias that landed outside the +3.3V zone (inside the GND part of the same layer) – it should check the via position against the zone outline, not just the existence of a zone. It also says pads with the same number "share a via" without drawing a track to it. |
| `bt ratsnest` | ~10 | Good; "fills counted" is what I wanted. |
| `bt length` | 2 | Useful once in a way I did not expect: per-layer lengths exposed that a shove run had moved nets to inner layers. |
| `bt route` single / `--batch` | ~6 | Mixed. Good error messages ("boxed in by track X at x,y"). |
| `bt route --nets` (bulk) | 5 runs | Mixed to poor on this board, see below. |
| `bt drc` | several | Good: grouped, with baseline. |
| `bt same` | 1 | Good, one line of certainty that no footprint moved. |
| `bt congestion`, `bt bus`, `bt pair`, `bt escape`, `bt stitch`, `bt near`, `bt place`, `bt gap`, `bt query`, `bt free`, `bt islands`, `bt cleanup`, `bt unroute` | 0–2 each | Mostly not used: placement was fixed, and I did the pairs by hand because the end game at the TVS array / jack needed a specific topology that I did not expect a generic pair router to find. `bt query` used once, fine. |

## What got in the way or was wrong

1. **`--shove` ignores `--layers` for the nets it moves.** `bt route --net X --all --layers F.Cu,B.Cu --shove`
   pushed already-routed nets aside by re-routing them on **In1.Cu and In2.Cu** (my plane layers): after 22 such
   calls USB_D- had 29 mm on In1, the RMII clock 28 mm on In1 with 5 vias, TXD1 7 vias over four layers. Nothing in
   the output says a moved net changed layer – only "removes 35 of the board's own tracks/vias (moved)". I found it
   by accident with `bt length`. I had to throw the whole run away. Moved nets must stay within the layer list
   (or within the layers they were on), and the tool should print which nets it moved. `--fixed` exists, but the
   safe default would be the other way round.
2. **Default grid 0.05 is too slow for long nets.** With `--seconds 20`/`25` every 40–60 mm GPIO net timed out
   ("gave up after 20 s; got closest at …"); the same net with `--grid 0.1` routed in 7 s. Two bulk runs
   (about 40 minutes of wall time) were wasted before I tried the coarser grid. The tool could pick the grid from
   the net length, or retry coarser by itself, or at least say "try --grid 0.1" in the give-up message.
3. **`--nets` writes its result only at the very end.** A bulk run that I had to stop after 30 minutes left
   nothing behind. An incremental `-o` (or `--apply` per net) would have saved that. I ended up writing a shell
   loop that routes one net and applies it.
4. **Pass 2/3 are very slow** (60–200 s per net) and gave little: in the 30-minute run pass 2 fixed 8 of 24.
5. **Unguided bulk routing makes poor choices for buses**: first RMII attempt put vias at the module pads, ran the
   50 MHz clock 35 mm on the wrong layer, and boxed its own later nets in at the PHY. Fixed order + no-via box
   helped a little but still boxed pins in. I drew the PHY fan-out by hand in the end.
6. `-o` for a failed multi-pad net contains the partial links without marking them; fine once you know, but the
   summary says "0/22 nets connected" when in fact 148 segments of useful partial copper are in the file.
7. Probe compares a 0.127 gap to a 0.127 limit as failing ("gap 0.127 < 0.127") – float rounding; KiCad's DRC
   accepts it. Harmless, but it made me widen the pair pitch by 6 µm.
8. `pkill -f "bt route"` matched the harness; not bt's fault, but a `bt` process title would help.

## What I did myself instead, and why

* All diff-pair, USB, PoE and PHY geometry: computed coordinates by hand (with `bt part` data), because the
  topology had to be planned (which side of TVS1 each pair passes, which lane the clock takes, where the barrier
  is). `bt probe` made this practical.
* Net class and `.kicad_dru` edits: by hand in the JSON / text file. bt read them correctly afterwards.

## What I would change / add

* Shove/rip must respect `--layers`, and must report moved nets. Make hand-placed copper lockable in one switch
  (`--fixed-existing`).
* Incremental output for `--nets`, adaptive grid, and a per-net time budget that scales with length.
* A fan-out helper for QFN/QFP: "give every pin of U4 a stub and, where needed, a via, without boxing in the
  neighbours" – that was the single most time-consuming manual job.
* `bt zone --replace` / `--delete`.
* `bt plane` should verify the via lands inside the target zone.
* A "lane"/"channel" query: how many tracks of width w fit between two rows of pads at a given clearance (I did
  that arithmetic dozens of times; `bt gap` does it for two pads, I wanted it for a corridor).

## Late additions (things I only learned near the end)

9. **A plane layer in `--layers` is treated like any signal layer.** When I allowed In2 as an overflow layer
   (without shove) the router put ~450 mm of GPIO tracks through my +3.3 V and GND zones. Zone fills are not
   obstacles, there is no cost for crossing a zone of another net, and no warning. After the refill
   `bt ratsnest` showed +3.3 V in 11 pieces (one track cut the regulator off from the ESP32). That was my decision,
   but the tool made it very easy to get wrong. Wanted: `--zone-cost N` or `--keep-planes`, i.e. "use this layer
   only if the zones on it stay connected", and a line in the route output such as "crosses zone +3.3V on In2".
   I ended up scripting exactly that: route one link → apply on a copy → `bt fill` → compare the group counts from
   `bt ratsnest` → keep or drop. That loop worked well and is a good candidate for a built-in command.
10. **`bt route --net N --all` stops at the first link it cannot do** ("0/1 routed"), so the other open links of
    a multi-pad net are never tried. Explicit `--from/--to` per link was needed.
11. `bt unroute --box` also removes vias inside the box (I lost the clock's PHY via that way). Fine, but the
    summary line could list what kind of items went.
12. `bt unroute --layer In2.Cu` leaves the now-orphaned vias and outer-layer stubs; `bt ratsnest` then lists
    zero-length "links" for them. A `--with-orphans` option would keep things tidy.
13. `bt drc --baseline` was excellent at the end: one line told me 0 new errors, and it caught a via sitting on
    the copper layer-number text, which nothing else had flagged (probe/route do not see `gr_text` on copper).

## Numbers

* Hand-computed copper checked by `bt probe`: ~460 segments, ~45 vias; 9 probe rounds found real mistakes
  (27 bad segments in total), none of its reports was a false alarm apart from the 0.127-vs-0.127 rounding.
* Router: 36 nets from the first bulk pass, ~25 more links from the per-link loops; about 75 minutes of wall
  time went into router runs that had to be discarded (grid too fine, shove onto planes, plane cuts).
* The board is **not** fully routed (see NOTES.md); the open links are mostly long GPIO nets that the router
  could not thread through its own earlier tracks. With rip-up that respects layers and planes I think it would
  have got there.

## Bottom line

`bt board`, `bt part`, `bt probe`, `bt apply`, `bt zone/fill`, `bt plane`, `bt drc` saved a great deal of time and
mistakes; I would not want to do a board head-less without them. The router is useful for short local nets and as a
finisher, but on this dense board its bulk mode cost me more time than it saved, and `--shove` did real damage.
