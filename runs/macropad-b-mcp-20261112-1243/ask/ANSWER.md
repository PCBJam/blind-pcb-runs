# Looking back at the macropad run

Numbers below are my own rough estimates from memory of the run, not measurements.

## 1. Tools I built, and which I'd want ready-made

All of these lived in `/tmp/s`:

- `lib.py` / `rlib.py`: `place(ref,x,y,rot)` (flip to back, rotate, move), `T(net,layer,width,points)`, `VIA(net,x,y)`, pad lookup, and a `save()` that puts the project file back after every board save.
- `place.py` + `placement.json`: rebuilds the outline and placement from the original board, then dumps every pad position and courtyard box to JSON.
- `route1..4.py`, `zones.py`, `stitch.py`, `build.sh`: the whole board is rebuilt from the untouched original each time, so any coordinate change is one edit and one re-run.
- `drc.sh`: runs `kicad-cli pcb drc`, prints counts by type and the first violations with coordinates.
- `render.sh`: SVG export → PNG, with optional crop to a region in board mm.
- One-off checks: zone islands without a via, locked-footprint/pad-net comparison against the original.

Want ready-made: the DRC summary, the cropped render, the pad/courtyard dump, the track/via helpers with a safe save, and the island check. The rebuild-from-original pipeline was the best decision of the run and should be the default way to work.

## 2. Tools that would have saved the most (ranked)

1. **Free-space / obstacle map query.** Input: layer, region, net. Output: copper-free rectangles and corridors with widths, accounting for pads, NPTH holes, the LED cut-outs and courtyards. Under 1 s. I derived all of this by hand arithmetic from footprint dumps, and got it wrong twice (rounded socket courtyard corner, real 0603 courtyard size). Would have saved roughly 30–40 % of the thinking.
2. **Point-to-point interactive router.** Input: net, start, end, layer(s), width, optional waypoints or "stay north of net X". Output: a DRC-clean path as a point list, or the reason it failed. Under 2 s per call. This replaces mental coordinate planning for the ~60 tracks I typed by hand. Roughly 30 % saved.
3. **Fan-out / escape helper for the QFN.** Given a pin set and which direction each net must leave, propose via positions and lane order, or report that the order forces a crossing. The six key lines on the east side of the RP2040 were the single worst loop. Roughly 10–15 % saved.
4. **Trial placement check.** Input: a list of (ref, x, y, rot, side). Output: courtyard overlaps, pad-to-hole and edge violations, without saving. Under 1 s. I did this through full place + DRC cycles (about 10–15 s each) and a lot of pre-computation. Roughly 5–10 % saved.
5. **Planarity / crossing check on a sketch.** Given ordered net endpoints around a region, say which pairs must cross on one layer. Most of my back-and-forth was discovering crossings one at a time. Roughly 5–10 % saved.
6. **Bundle and diff-pair helper.** Parallel traces with correct 45° nesting and jog offsets. I got the chamfer and jog offsets wrong three times (QSPI swing, USB jog). Small saving, maybe 2–3 %.

## 3. Hardest parts and what would have prevented the loops

- **Floorplan decision.** I spent a long time deciding whether to keep a left extension, then where the MCU, LDO, load switch and bulk cap go. The LDO moved between bottom-left, the middle gap and the right strip several times; C114 moved four times. Cause: every placement choice changed which power net had to cross the USB pair or the QSPI bundle, and I only found that out by reasoning each one through. A fast crossing check plus trial placement would have cut this to a few iterations.
- **Key-line fan-out at the MCU.** South-bound keys are on the northern pins and north-bound on the southern pins, all leaving the same side. I went through about six via/lane schemes before one closed. The autorouter was tried in between and routed two of six nets, badly.
- **3V3 distribution around the QFN.** Linking the supply pins on four sides with two layers kept colliding with key lanes and the USB jumper. At the end the MCU ground pad turned out to be isolated on the front layer, enclosed by 3V3 links and the USB jumper; only the island check and DRC caught it.
- **USB connector fit.** I planned a zero-extension board before checking the footprint's edge line and pad depth against D201. One early geometry query would have settled it.

What I should have done differently myself: stop planning in my head much sooner and iterate through the build-and-DRC loop, which was cheap and caught everything. The first DRC-clean routing stages each took only two or three runs once I wrote them down.

## 4. Brief and environment

- Saving through `pcbnew` silently rewrote `macropad-top.kicad_pro` with defaults. I had no copy; I restored the board rules and text variables from earlier printouts, but the schematic-side settings are gone. A warning in the brief, or a read-only backup of the project, would have avoided real damage.
- `FindFootprintByReference` returned an unusable object and removing drawings while iterating segfaulted Python. Small, but each cost a debug round.
- No image tooling was installed; I had to add `cairosvg` to see the board at all.
- "As small as is sensible" with no hint of how area is weighed against routing quality made the floorplan choice much longer. I picked the near-minimum outline and paid for it in density.
- No information on case, connector side preference or height limits, so the USB position and the 5.4 mm capacitor were my guesses.

## The KiCad MCP server

It helped very little. I loaded seven tool schemas (`autoroute`, `check_freerouting`, `export_dsn`, `import_ses`, `open_project`, `save_project`, `close_project`) and called three: `open_project`, `autoroute` once for the six key nets on a scratch copy, and `close_project`. The autoroute result was discarded.

Why I did not use more:

- I had already built a scripted rebuild pipeline in `pcbnew`. The MCP holds its own in-memory board and saves it; mixing that with a pipeline that regenerates the file risked one clobbering the other, and after the project-file accident I kept it away from `/work`.
- The tool list was 250 names with no schemas loaded. Most were schematic, library, export or GUI tools irrelevant here. The board-editing ones (`route_trace`, `add_via`, `move_component`) looked like one-item-per-call versions of what one Python script did for sixty items at once.
- I did not load `get_elements_in_region`, `check_placement_clearance` or `check_courtyard_overlaps`, which might have covered part of items 1 and 4 above. That was a miss on my side; I cannot say how well they work.
- The first `autoroute` call failed with "No board is loaded" despite a `boardPath` argument, which did not encourage further use.

A differently designed MCP would have changed how I worked if it were:

- **Stateless on the file** (path in, result out) or at least batch-oriented, so it composes with scripts.
- **Built around geometry questions**, not edits: free space, corridor width, "can this net get from A to B on this layer", trial placement.
- **Small:** about 15 tools with schemas visible up front, not 250 behind a search.
- **Equipped with a constrained single-net router** that returns coordinates I can keep in my script, rather than a whole-board autorouter that writes into the board.
