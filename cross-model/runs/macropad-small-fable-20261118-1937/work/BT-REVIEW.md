# bt review

I used bt for almost every write and every check on this board. The floorplan, the layer plan and
nearly all track coordinates I worked out myself and handed to bt to verify and write.
Counts below are approximate (from my command history).

## What I used, and how much

| command | calls | verdict |
|---|---|---|
| `bt probe` (items file) | ~30 | the most valuable command |
| `bt apply --checked` | ~18 | used for every copper write |
| `bt place` (trial, `--pads`, `--apply`) | ~22 | very useful, one wrong answer |
| `bt render` | ~12 | needed; no GUI |
| `bt part`, `bt query`, `bt board`, `bt ratsnest`, `bt length`, `bt vias` | ~25 | good |
| `bt rm --uuid` / by point | ~8 | good |
| `bt check` | 5 | very good |
| `bt drc --baseline`, `bt same` | 3 | good |
| `bt outline` | 3 | good |
| `bt zone`, `bt via`, `bt rules` | 2 / 5 / 1 | good |
| `bt escape` (GND pads) | 1 | good |
| `bt islands`, `bt stitch`, `bt cleanup` | 1 each | good |
| `bt route` | 2 | did not help here |
| `bt silk --fix`, `bt undo --clean` | 1 each | nothing to do / fine |
| `bt near`, `bt congestion`, `bt planar`, `bt fan`, `bt bus`, `bt pair`, `bt tune`, `bt offset`, `bt plane`, `bt seg`, `bt merge`, `bt free` | 0 | not used |

## What helped

- **`bt probe` + `bt apply --checked`.** I wrote polylines in a small Python helper, probed, fixed,
  applied. Every miss came back with the other item, its net and the gap ("pad U103.21 gap 0.183
  < 0.2"), so one edit usually fixed it. About a dozen of ~30 probes found something. Two would have
  been real board faults and easy to miss by eye: the crystal trace 0.02 mm inside the LED window
  cut-out of D201 (reported as "board edge gap"), and a via 0.39 mm from a switch peg hole against
  the 0.45 mm hole-to-hole rule in the `.kicad_dru`.
- **`bt place --pads`.** Printing each pad's net and position after a trial move is how I got every
  rotation right on the flipped side without a GUI (7 capacitors were the wrong way round on the
  first trial). The "pad blocks U103.50's way out" warnings were accurate.
- **`bt check`.** One line, fills refreshed, KiCad's DRC with courtyards, unconnected items. It
  found the two errors I had left (below). I confirmed its final result with `kicad-cli pcb drc`
  directly: same 3 warnings, 0 errors.
- **`bt escape` on 38 ground pads**: 31 vias placed in one call, and for the 7 it could not do it
  said what was in the way and what the nearest ground copper was. That list was exactly my to-do
  list for the last rework.
- **`bt islands`** told me the two pours were not joined before I had any vias – clear and correct.
- **`bt rm`** saying "comes apart: 1 → 4 pieces" per net made removing 26 segments at once safe.
- Writes never touched the `.kicad_pro` (I compared it after every placement step).

## What got in the way or was wrong

- **`bt place` passed two placements that KiCad's DRC rejects.**
  `bt place B --move U106,120.2,110.0,0,B --apply` reported ok; `bt check` later gave
  `courtyards_overlap U106 ↔ SW201`. SW201's back courtyard is drawn as separate segments and arcs
  (the hot-swap socket outline); bt seems to have used only part of it. Likewise C501 was accepted
  with its courtyard over SW501's centre hole (`npth_inside_courtyard`). Each cost a rework of
  already-routed copper (about 30 segments for U106). This is the one place the tool gave me a
  wrong "ok".
- **`bt route --nets "/KEY4,/KEY6,/KEY5" --layers B.Cu --max-vias 0`** ran 120 s (it hit my shell
  timeout and went to the background) and connected 1 of 3. The failure text was honest ("boxed in
  for a 0.2 mm track") but pass 2 spent 80 s on a rip-up that could not work. The fan-out needed
  0.15 mm traces in a specific stagger, which I drew by hand in a few minutes.
- **`bt route --net /KEY5 --from 123.0,121.75,B.Cu ...`** from the end of a 0.15 mm stub necked
  4.95 mm to 0.127 mm instead of continuing at the 0.15 mm it started from. I did not use it.
- **`bt place --apply` with the USB connector**: "courtyard reaches past the board outline" blocks
  the whole batch, and `--force` then forces every move in the call, not only that one. An edge
  connector overhanging the edge is normal; I would like a per-part allowance.
- **`bt help` is about 400 long lines.** Reading it cost more tokens than any other single step.
  `bt help CMD` exists but I only knew that after reading the long form.
- **`bt silk --fix`** said "0 references overlapped something" – true, but only because all
  references are hidden. The two real silk warnings (footprint graphics against a neighbour's pad)
  are outside what it handles; a line saying "N references hidden, not checked" would help.
- Minor: `bt cleanup` wanted to "tidy 15 track runs"; with hand-placed 0.2 mm gaps I only applied
  it through `--checked` because I could not tell from the summary which runs it would move.

## What I did myself, and why

- **Topology.** The hard part of this board was deciding which nets may cross where: KEY5/6 and
  the LED bus on the back plus KEY2/3 on the front wall off north from south. I worked that out on
  paper (several wrong turns, visible in the progress log). `bt planar` might have answered parts
  of it; I did not try it because the question involved obstacles and more than two parts, which
  its help text says it ignores.
- **All track geometry** except the ground stubs. With clear rules and probe as a checker, writing
  coordinates was faster and more predictable than steering the router.
- **Decoupling placement** by hand rather than `bt near --each`, because the west side of the QFN
  needed capacitors, resistors, the USB pair and the QSPI bundle arranged together.

## What I would change, add or remove

1. Make `bt place` use the same courtyard geometry as KiCad's DRC (open outlines made of
   segments/arcs, and NPTH-in-courtyard). A trial that says ok must mean DRC-ok.
2. A crossing/topology query for a whole board: "these nets on this layer between these regions –
   which pairs must cross, given the copper already there". That would have saved me the most time.
3. `bt route`: start at the width of the track it continues from; give up on a net as soon as the
   pad is boxed in at class width instead of running the shove/rip passes; accept `--width` below
   class width for a named box without necking to the fab minimum.
4. `bt place --allow-overhang REF` (or treat a footprint with an edge line on a drawing layer as
   an edge connector).
5. `bt help` should print a one-screen index by default and the long text on request.
6. Keep: probe, apply --checked, place --pads, escape, islands, check, rm's per-net summary.
   I cannot judge the commands I did not use.
