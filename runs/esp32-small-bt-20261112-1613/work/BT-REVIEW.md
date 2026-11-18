# bt review – ESP32-PoE-ISO re-layout

Honest summary: `bt` was worth having. The look/check half (render, part, drc, probe, apply) saved a lot
of time and caught real mistakes. The route half did the easy two thirds of the nets well and then cost
me a lot of time on the rest, partly because of bugs listed below.

## What I used, and how much

| command | calls (approx.) | verdict |
|---|---|---|
| `bt board` | 3 | Good one-shot overview at the start (nets, pads, ratsnest lengths). |
| `bt part` | ~30 | Very useful. After every rotate/flip I needed the real pad positions and nets; this is the fastest way to get them. |
| `bt render` | ~25 | The most valuable command for placement. Pad-net labels on a mm grid let me fix orientation mistakes (bottom-side parts are mirrored) in one look instead of reasoning about them. |
| `bt drc` | ~45 | Essential. Grouped, with coordinates, `--refill` on a scratch copy. I ran it after every step. It read my custom `.kicad_dru` isolation rules correctly (it is KiCad's DRC). |
| `bt probe` | ~10 | Good for hand-written tracks before applying them. Saved several apply/DRC round trips. |
| `bt apply` | ~50 | Did exactly what it says; never touched the project file. I kept every routing step as an items JSON and rebuilt the board from placement + JSON files many times. |
| `bt route` (single) | ~8 | Fine. |
| `bt route --batch` | ~20 runs, ~400 requests (plain, In2, `--rip`, `--shove`) | Mixed, see below. |
| `bt escape` | 2 | Worked for 16 of 24 pads of the 3.3 V net; used the vias as the basis of a hand-drawn In2 tree. |
| `bt ratsnest` | ~10 | Handy quick check of what is open. |
| `bt congestion` | 1 | Not useful to me (see below). |
| `bt place`, `bt near`, `bt gap`, `bt query`, `bt cleanup`, `bt same`, `bt drc --baseline` | 0 | Not used. Placement was done with my own table + pcbnew script because I needed flips to the back side, a board outline and zones in the same reproducible step. |

## Where it helped

* Placement review: render + part + drc on a placement-only board found pad overlaps, hole clearances
  (mounting holes and fiducials carry 1.0–1.5 mm local clearances I did not know about) and parts on
  top of each other before any routing.
* `bt probe` output ("nearest pad X at 0.34 mm") is a good way to tune hand routes.
* `bt route` failure messages ("blocked by track … at x,y", "the start is boxed in") are specific enough
  to act on. Local nets around ICs (buck, charger, 5VP) routed first time on one layer.
* Speed on one or two layers is fine (0.1–0.5 s per link).

## Where it got in the way / wrong or confusing answers

1. **Custom rules are not seen by route/probe.** `bt route` and `bt probe` use net-class clearance only.
   My board has a 3 mm primary/secondary rule and a 1 mm shield rule in the `.kicad_dru`; `bt route`
   put a primary net 0.98 mm from the shield tab and `bt probe` called it clear. Same for pad-local
   clearances: the fiducials (1.016 mm) and mounting holes were violated ~20 times by routed tracks/vias.
   Only `bt drc` (KiCad) caught these.
2. **`--avoid` is not reliable.** Test: `bt route … --net "unconnected-(U6-NC-Pad17)" --layers F.Cu
   --avoid "146,107,150,110"` returned a track running down x=146.81 from y=106.5 to 109.85, straight
   through the box. It looks like the straightening pass ignores the avoid boxes.
3. **Batch input types.** In `--batch` JSON, `"layers":"F.Cu,B.Cu"` (a string, as on the command line)
   fails every request with "the target is outside the search window" – a misleading message; it needs
   a list. `"avoid":"x0,y0,x1,y1"` as a string crashes with `TypeError: avoid.some is not a function`.
4. **Pad names with dots.** Resistor arrays here have pads named `1.1`, `1.2`…; `--from RM2.1.1`
   answers "no pad RM2.1.1" and `bt escape` says "RM3.1.2: no such pad". I had to route those by net.
5. **`bt probe` checks new items against the board, not against each other.** A via and a track from
   the same file that shorted two nets passed with "all clear"; KiCad DRC found it.
6. **Multi-pin power nets.** `--all` on +3.3V (25 pads, three layers allowed) made bottom-layer rails
   that boxed in other parts, used 200+ segments and still left the net in 16 pieces; I threw it away
   and drew a via-per-load tree on In2 by hand. A "connect these pads to a plane/trunk with one via
   each" mode would have been the right tool.
7. **Dense fan-out.** Around the QFN PHY the router boxed pins in more than once (pin 7 twice), because
   each net is routed alone in list order. I ended up hand-routing the PHY as a bus. Pass 2/3 with
   In2 and `--rip` recovered only part of the leftovers.
8. **Speed with 3–4 layers / rip.** A failed link costs 10–120 s; a 25-net rip pass ran more than
   ten minutes with no output until the end (batch prints everything at the end, so no progress to
   watch).
9. **`--rip` output contains `remove` uuids of the live board**, so the result cannot be re-applied
   after rebuilding the board from scratch. That broke my "placement + ordered JSON files = board" flow
   and forced me to treat the board file as the master from then on.
10. **`bt congestion`**: listed 52 "IC pins with one way out or none", including QFN and SOT-563 pins
    that route out normally with a narrower track; the crossing counts (592) did not tell me what to
    change. I did not use it again.
11. **`bt ratsnest`** marks poured nets as "(poured)" and still lists their links, so after zones exist
    it cannot tell whether GND/Earth is really connected; again only `bt drc --refill` can.

12. **`--shove` was the most effective rescue mode** (16 failing nets -> 7 in one pass, where `--rip`
    only managed 12 -> 6), but it is not conservative: it removed 96 existing items, among them the
    hand-drawn 3.3 V trunk to the UEXT connector on In2 (the net was open again afterwards and I had to
    notice and repair it), and it parked a via in the only gap one of my manual pad-to-pad links needed.
    A `--fixed`-by-default for wide/power tracks, or a report of nets whose connectivity got worse,
    would have saved that.
13. **End result with bt as the only router: not finished.** 15 signal links and 9 GND pads stayed open
    after five passes. In fairness, part of that is my placement being too dense under the module; but
    the tool gave no early warning of it (the congestion report did not point at those clusters), and
    once pads are boxed in there is no tool support for opening them up (no "rip this cluster and
    re-route it as a group").

## What I did myself instead, and why

* Placement: own table file + pcbnew script (flip to back, rotation, outline, zones, rule file), then
  `bt render`/`bt drc` to check. `bt place` tries moves but does not write, and I wanted one reproducible
  build step.
* All isolation-critical and analogue routing (PoE primary, Ethernet pairs, USB pair, 3.3 V tree, PHY
  supplies and bus) as hand-computed coordinates written to items JSON, checked with `bt probe`, written
  with `bt apply`. `bt route` has no differential-pair mode and does not know the isolation rules.
* Removing tracks: small pcbnew script (bt can only remove by uuid).

## What I would change / add

* Read `.kicad_dru` clearance rules and pad/footprint local clearances in route, probe and escape; at
  least warn when the project has custom rules that are being ignored.
* Make `--avoid` hard (also after straightening) and accept polygons / "keep inside this polygon";
  honour rule-area keepouts.
* Validate batch JSON and say what is wrong; accept the same string forms as the command line.
* Accept dotted pad names (split REF from pad at the first dot).
* `probe`: also check the items of the file against each other.
* A differential-pair route (two nets, width/gap, same layer changes).
* A plane/trunk mode for power: "one stub + via per pad into layer X", then connect the vias.
* A fan-out/bus mode for QFN sides, or at least net ordering by pin position instead of list order.
* Progress output during batches, and a per-request time limit.
* A way to re-apply rip results on a rebuilt board (match by net + geometry instead of uuid).
* A "free area" query (largest empty rectangle on a side) for logos, fiducials, test points.
* Drop or rework `congestion`'s "pins with no way out" until it uses the real minimum track width.
