# Looking back at the Mega 2560 run

Written from memory of the run; the time/token savings below are my rough estimates, not measurements.

## 1. Tools I built, and which I want ready-made

All were throwaway scripts in `/tmp/w`:

| Script | What it did | Want ready-made? |
|---|---|---|
| `place.py` | Table of ref → (x, y, rot), applied to a fresh copy of the original board, printed resulting pad positions | Yes |
| `rt.py` | `T(net, points, width, layer)`, `V(net, x, y)`, pad lookup — my whole "router" | Yes, with DRC built in |
| `chk.sh` | kicad-cli DRC → JSON → filtered to real errors with coordinates, hiding pre-existing ones | Yes, top priority |
| `render.py` | SVG export → cropped PNG of a board region | Yes |
| `near.py` | List tracks/vias in a rectangle (net, layer, endpoints) | Yes |
| `zones.py`, `stitch.py` | GND pours on both layers; grid stitching vias where both fills exist | Yes |
| `islands.py` | Tried to find which pour island was isolated; only half worked (ignored tracks/SMD pads) | Yes, done properly |
| `split.py`, `snap.py`, `mkdsn.py`, `imp.py`, `runfr.sh` | Make my tracks acceptable to Freerouting, export DSN with GND neutralised, import and filter the result | Only if the autorouter stays in the loop |
| `r1.py`…`r6.py`, `build.sh` | The actual routing as coordinates, replayed from scratch on every change | No — this is the thing to replace |

## 2. Tools that would have saved the most (ranked)

1. **Geometric query / "does this fit" endpoint.** Input: a candidate track polyline or via (net, layer, width). Output in <1 s: legal or not, plus the nearest obstacle and the gap. Also "free channel width between A and B on layer L" and "free via sites in this rectangle". Almost all my long thinking was doing this arithmetic by hand, pad edge by pad edge. Estimate: 50–60 % of tokens and time.
2. **Interactive point-to-point router** (push-and-shove style, one net or one bus at a time). Input: net, start/end pads, layer preference, optional waypoints, width. Output: the routed path or a concrete reason it failed (what blocks it). A few seconds per net is fine. This would replace hand-computed 45° fans, lane stagger and via stagger. Estimate: another 20–25 %, mostly overlapping with item 1.
3. **Bus/escape helpers.** "Fan out pins N..M of this QFP to lanes at pitch p", "route this ordered lane bundle to this header with one track between pins", "is this pin order planar with that target order, and which nets must change layer". I derived the crossing analysis for the MCU's left side and port A/C/G/L several times over. Estimate: 10 %.
4. **Connectivity/cluster report including zones.** Input: board. Output: per net, the disconnected clusters with bounding boxes and members; for GND, which pour islands hang on which pads. KiCad's DRC only gave the zone origin as location, so I guessed at the last isolated ground island for several rounds. Estimate: 3–5 %.
5. **Placement checker with a routability hint.** Input: placement table. Output: courtyard overlaps (excluding pre-existing), silk-label collisions, ratsnest length, and a per-region congestion estimate. I iterated placement about ten times by rendering and reading DRC text. Estimate: 5 %.
6. **Working headless autorouter, pre-installed**, that honours fixed tracks, can skip nets, and takes a region or net list. Setup cost me roughly 20 minutes (no Java, GitHub blocked, one build broken headless, another needing Java 25), and several 5–10 minute runs were wasted. Even working, it was only good for short local nets. Estimate: 10 % of wall time, few tokens.
7. **Fast region render** returning an image with a coordinate grid and net labels overlaid, in about a second. Mine worked but had no grid, so I converted pixels to millimetres by hand.

## 3. What was hardest, and where I went back and forth

- **The gap between the USB bridge and the MCU.** Two top-layer lane groups to the top headers, the TX/RX/L LEDs pinned by silk labels, RN3/RN4, and bottom-layer hops all compete there. I re-planned it many times, moved C9, RN1, U7's connections and the LED resistor hops repeatedly, and it is still the weakest area (cut-up ground, extra vias).
- **+5 V distribution and RESET.** I changed the 5 V feed to the MCU three times (east–west bottom spine, then a feed at C8, finally a spur from the south trunk). Each long bottom trunk or RESET run walled off something else — the "L" LED buffer signal, the comparator sense net, the ICSP RESET pin. I only found each wall when the next net failed.
- **U7 placement.** Putting the LMV358 in the power corner enclosed its PB7 and LED-buffer nets on both layers. I noticed late and worked around it rather than moving it.
- **Autorouter integration.** It counted my finished nets as unrouted until I snapped track ends to pad centres; removing GND from the netlist silently dropped GND vias as obstacles; one run was killed by the background time limit; I twice killed my own shell with `pkill -f`.
- **Ground pour connectivity at the end.** Several pads sat in pockets with no pour access; finding and fixing them was trial and error.

What would have prevented most of it: a cheap way to test a global topology before committing coordinates — a coarse channel/crossing model per layer where I could ask "if this trunk goes here, which nets become enclosed?". And routing in the order "long cross-board nets and power first, buses second" instead of the reverse; I routed the tidy MCU buses first and then had to thread RESET, 5 V and the LED nets around them.

## 4. Brief and environment

- **No schematic.** I reconstructed every sub-circuit from net names (which caps belong to which pins, what U7 and RN3/RN5 do). A one-page functional description or grouped netlist would have saved the first chunk of thinking.
- **Silkscreen artwork as implicit constraints.** The labels ("ON", "TX", "RX", "L", "RESET-EN", "MEGA 2560") dictated where parts could go, but the brief did not say whether they were fixed or movable. I treated them as fixed, which caused the corridor problem above.
- **Edge-clearance rule vs. locked geometry.** The 0.5 mm copper-to-edge rule in the project could not be met next to the mounting holes with the locked headers; I lowered it to 0.3 mm. A stated fab rule set would have removed that decision.
- **Tooling not present.** No Java, no autorouter, no SVG→PNG converter, GitHub blocked. All solvable, but trial and error.
- **Foreground `sleep` blocked and 10-minute background limit** cost a few restarts while waiting on the autorouter.
- **Pre-existing DRC noise** (51 library mismatches, 43 silk overlaps, 4 courtyard overlaps among locked parts) had to be filtered out of every check.
