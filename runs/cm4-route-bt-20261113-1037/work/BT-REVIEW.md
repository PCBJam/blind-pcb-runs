# bt review

I used bt for almost everything except generating the coordinates of the critical routes. Counts are approximate (from memory of the session).

## What I used, and how much it helped

| Command | Uses | Verdict |
|---|---|---|
| `bt probe` / `bt apply --checked` | ~80 | **The most valuable part.** I wrote differential pairs, buses and fan-outs as Python-generated polylines and probed them before writing. Answers in 1–4 s, names the offending item and the gap. Caught every mistake I made (≈60 bad segments) before it reached the board. Without it I would have needed a KiCad DRC run (~40 s) per try. |
| `bt board`, `bt part`, `bt query` | ~40 | Very good. `bt board` in one dump was enough to plan the floorplan; `query` with a box was how I found what an autoroute had done. |
| `bt render` | ~25 | Good enough to judge topology; pad labels unreadable below ~100 px/mm, and `--pads` did not seem to change much. |
| `bt zone`, `bt fill` | ~35 | Worked. See problems below. |
| `bt route --net … --all` (one net) | ~120 | Useful for short, local nets (stubs, LEDs, feedback dividers). 0.3–2 s each when it works. |
| `bt route --nets …` (batch) | 4 | Mixed, see below. |
| `bt pair` | 2 | Fine on one layer. Dropped after the first try with vias. |
| `bt plane`, `bt stitch`, `bt escape` | 4 | `plane` and `stitch` are excellent: 173 + 269 vias in seconds, all legal, none on top of the pair lanes. |
| `bt unroute`, `bt undo`, removeAt in items.json | ~30 | Essential. `undo` saved me once (three writes back). |
| `bt drc --baseline`, `bt same`, `bt islands`, `bt length`, `bt ratsnest` | ~30 | Good. `--baseline` is the right idea: the unrouted board already had 440 irrelevant warnings. |
| `bt fan`, `bt bus`, `bt congestion`, `bt gap`, `bt near`, `bt place`, `bt free`, `bt cleanup`, `bt outline` | 0 | Not needed (placement fixed, QFNs fanned by hand). I should have tried `bt bus` for the control bus; by then I no longer trusted long routes to the router. |

## What got in the way

1. **Batch routing gives nothing back if it does not finish.** `bt route --nets <129 nets> --seconds 20` ran over 10 minutes and was killed; `-o` is only written at the end, so everything was lost – twice. Pass 2/3 (shove, rip-up) took 15–35 s *per failed net*. It needs a total time budget, incremental output (or `--apply` per net), and a way to turn the later passes off. I ended up writing my own loop: route one net, apply, next.
2. **Long routes.** Nets over ~100 mm either timed out or came back with 4 vias and a 195 mm path for a 115 mm net (`CM4_RUN`). `--through` waypoints made it worse (all six bus nets failed with the same waypoints that a hand-drawn straight line satisfied). Hand-drawn trunk + router for the ends is the pattern that worked – but the router then could not finish ends that all stop at the same x ("blocked by track … at 196,137"), i.e. it cannot enter a bus from the side.
3. **Shortest-first ordering boxes pins in.** On the CM4 connector and around the RP2040 the autorouted first nets fenced in later ones (SD_DAT1, RUN/RST, four ground pads enclosed by feedback traces, a ground pad enclosed by a 3V3 loop). I had to rip up and plan those areas by hand. A check "does this route enclose an unrouted pad?" would have saved the most time of anything on this list.
4. **`bt pair` with vias**: `PCIe_RX_P/N` came back with 8.3 mm skew and the two vias 17 mm apart. For anything with a layer change I generated the pair myself.
5. **Zones and connectivity.** (a) After `bt zone --replace` the zone is unfilled and `bt route` then treats the net as open: it added 11 pointless +1V2 tracks before I noticed. It should refill, or refuse, or warn. (b) `bt ratsnest` said 25 ground groups when KiCad said 9, and reported overlapping same-net zones as unconnected; I stopped trusting it for poured nets and used KiCad's JSON report. (c) `bt route --net GND --from <pad>` cannot find a way to a pour ("FAILED" after 34 s each, eight times); `bt plane` said "shares via" for pads that were in fact isolated.
6. **`bt zone` has `--solid` but no "thermal for through-hole only"**; I edited `connect_pads thru_hole_only` in the file by hand. Zone clearance and island mode are also not settable.
7. Small things: failure text only says "FAILED" unless you run the net alone without `-o`; `bt route` with `-o` on failure leaves no file (my script had to guess); each call reloads the board (≈20 s per call once zones were filled, so 16 single-pad routes took 5 minutes); the help is one 150-line screen with no per-command help.

## What I did myself instead, and why
- All 15 PCIe pairs, USB, Ethernet, the QFN power fan-out, the bottom control bus, the signal strip, RP2040 fan-out, PERST bus: a 40-line Python offset-polyline helper writing items.json, checked with `bt probe`. Reason: I needed exact lane positions (to keep In2 islands out from under the pairs, to keep 3.3 mm from mounting holes, to do the polarity twist), and the router has no notion of "this lane, this order".
- Zone connection style and two via sizes: direct text edits.
- Listing DRC items with coordinates: `kicad-cli pcb drc --format json` plus ten lines of Python, because `bt drc` prints zone islands at the zone's origin (80.4, 58.05) and I could not find them.

## What I would change
- Add: time budget and incremental writes for batch routing; an "encloses unrouted pad" guard; `bt route` able to end on a pour; a pair-with-vias primitive (side-by-side or in-line vias, with twist option) – this is what I wrote by hand most often; `bt zone` options for pad connection, clearance and auto-refill; coordinates for zone islands in `bt drc`.
- Keep exactly as is: `probe`, `apply --checked`, `removeAt`, `undo`, `plane`, `stitch`, `drc --baseline`, `same`.
- Would not miss: `--through` in its current state.

Overall: as a checker and bulk-via tool bt roughly halved the work and prevented nearly all my geometric mistakes. As an autorouter it was good for about 150 short connections and cost me time (several hours of rip-up and re-planning) on the dense or long ones.
