# Looking back at the Mega 2560 routing run

Answers are from memory of the run; the time/token estimates are rough guesses, not measurements.

## 1. Tools I built for myself

All lived in /tmp/s and were not shipped.

- **Autorouter bring-up** (not a tool, but ~25 min): Freerouting 1.9 jar from jitpack, a JRE from the
  `jdk4py` wheel, Xvfb unpacked from Debian .debs with a binary patch for the xkbcomp path, a
  framebuffer screenshot script and an XTEST click script to dismiss its dialogs.
- `stage.py` – export DSN, filter the netlist, inject layer/via costs, run Freerouting, import SES.
- `prep.py` / `stubs.py` / `hand2.py` – rules and net classes, keep-outs, a via next to every SMD
  ground pad, and hand routes given as coordinate lists.
- `widen.py` – split power tracks and widen each piece as far as clearance allows.
- `maze.py` – my own 2-layer grid A* router for leftovers and for joining ground islands.
- `fix.py`, `prune.py`, `dangle.py`, `nudge.py`, `boxdel.py`, `strip.py` – clean-up after each import
  (duplicates, slivers, dangling stubs, via pairs under 0.5 mm hole spacing, local rip-up).
- `stitch.py` – fill zones, find disconnected ground groups, add joining and grid vias.
- `drc.py`, `render.py` – DRC summary; PNG render with a mm grid and crop.

Want ready-made next time: a working headless autorouter with staging, the render-with-grid tool,
the DRC summary, ground stitching with island analysis, and a "route this path and tell me the
clearance" helper. The clean-up scripts should not need to exist at all.

## 2. Tools that would have saved the most (ranked)

1. **Headless autorouter endpoint** (~50 min, ~35% of tokens). Input: board, net subset, per-layer
   cost, via cost, which nets are fixed or rippable, widths. Output: board with tracks merged
   correctly, plus a list of unrouted nets with the reason. Minutes per call is fine; what matters
   is no GUI dialogs and a correct import.
2. **Interactive "connect A to B" router** (~25 min, ~25% of tokens). Input: net, two
   pads or points, layer preference, width. Output: the legal path or the blocking item, in under
   2 s. This replaces the long in-head coordinate arithmetic for the USB-C escape and the RN5 rework.
3. **Local rip-up-and-reroute** (~15 min). Input: a net or region. Output: rerouted, with neighbours
   pushed if needed. My A* router could not shove, so boxed-in pins needed manual surgery.
4. **Query endpoint** (~10 min). "What copper is within box X on layer L", "clearance of this
   segment to everything", "which connected groups does net N have". Sub-second.
5. **Zone fill plus stitching with connectivity report** (~8 min).
6. **Fast cropped render with grid and net labels** (~5 min). Mine worked but had no net names, so
   I guessed which track was which from colour and position.

## 3. Hardest parts and back-and-forth

- **Getting a router to run at all.** GitHub was blocked, there was no Java or X server. Then
  three silent failures: a non-ASCII "Ω" in the DSN, `autoroute_settings` rejected inside the DSN
  (it had to go in a `.rules` file), and a warning dialog that blocked loading.
- **SES import semantics.** I assumed in turn that import replaces all tracks, then that the
  session contains all tracks. Neither is true: it is additive and omits fixed wires. That cost
  two wasted 20-minute router runs and one result full of shorts before I worked it out.
- **Staging strategy.** I went through five variants (all at once, power first, power thin then
  widened, top-only buses, buses unfrozen). Each full attempt was 10–25 minutes of wall time.
  Frozen bus routes left 13–16 nets unroutable; unfreezing fixed completion but undid much of the
  tidy bus structure.
- **USB-C escape and the RN5 corner.** Both were done by mental geometry against pad coordinates,
  with several dead ends each. A path-with-feedback tool would have removed this.
- **pcbnew Python quirks.** A second `LoadBoard` in one process, or `GetTracks()` after `Remove()`,
  returns raw SWIG objects; I hit this three times.
- Self-inflicted: `pkill -f` patterns that matched my own shell, and waits that hit the 10-minute
  tool limit.

What would have prevented most of it: items 1 and 2 above, and a one-page note on what the
DSN/SES round trip does and does not preserve.

## 4. Brief and environment

- The brief was clear. "Route it the way an experienced designer would" pulled me toward hand
  planning that I could not afford without interactive tools; the result is still mostly
  autorouted, as NOTES.md says.
- No schematic meant I inferred circuit intent (decoupling pairs, pull-ups) from net names.
- Blocked sites and no root made the tool setup slow; a preinstalled router would have removed it.
- The 10-minute foreground limit against 20-minute router runs forced detached jobs and polling.
- The existing DRC noise (113 silk, courtyard and library items) had to be filtered on every check.
