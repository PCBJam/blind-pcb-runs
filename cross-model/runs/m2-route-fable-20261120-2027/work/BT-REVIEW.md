# bt review

Board: M.2 → PCIe x4 adapter, 4 layers, 9 differential pairs, 3 power rails. About 35 minutes of
work from first look to CHECK OK.

## Short version

I used bt as a checker, writer, pourer and camera, and did not use its routers at all. In that
role it was good: nothing reached the board unprobed, the project file was never clobbered, and
one command told me whether the board was finished. The pair geometry itself I generated with my
own Python (scripts/gen_*.py), because the board needs a mirrored via pair that turns each pair
90° and swaps P/N, with exact symmetry. I did not test whether `bt pair` or `bt route` could have
produced that, so I cannot say they could not; I assumed not and went straight to coordinates.

## What I used (approximate counts)

| Command | Times | Verdict |
|---|---|---|
| `bt help`, `bt help stitch` | 3 | Complete but a wall of text; see below |
| `bt board` | 1 | Very good. One call gave rules, every pad with coordinates and side, mask openings |
| `bt part --boxes` | 2 | Good. Pad boxes were what I needed for hand clearance sums |
| `bt congestion` | 1 | Little use here |
| `bt rules` | 2 | Good. Changed one class's via size, nothing else in the .kicad_pro (I diffed it) |
| `bt probe` (items file) | 7 | The most valuable command |
| `bt apply --checked` | 5 direct, 4 more inside my build script | Very good |
| `bt zone` | 10 by hand, 12 per rebuild × 4 rebuilds | Works; gaps listed below |
| `bt fill` | 4 (in the build) | Fine |
| `bt stitch` | 4 | Useful as a proposal, edited by hand afterwards |
| `bt check` | 7 | Very good |
| `bt drc --refill --baseline` | 1 | Good; confirmed nothing new against the unrouted board |
| `bt ratsnest` | 1 | Fine |
| `bt length` | 2 | Good; confirmed 0.000 mm skew on all pairs |
| `bt vias --under-min` | 1 | Fine |
| `bt same` | 1 | Good, cheap proof that no footprint moved |
| `bt render` | about 22 | Very good; I could not have reviewed pours without it |

Not used: `route`, `pair`, `bus`, `planar`, `fan`, `escape`, `plane`, `offset`, `tune`, `islands`,
`via`, `rm`, `seg`, `unroute`, `cleanup`, `place`, `near`, `silk`, `outline`, `free`, `query`,
`gap`, `undo`, `merge` (apply's built-in merge was enough).

## What helped, and how much

- **`bt probe` / `bt apply --checked`.** I wrote about 420 segments and 190 vias from computed
  coordinates. Probe caught five real mistakes before they were written (two 0.4 mm stubs 0.125 mm
  from NC fingers, three clashes in the cap cluster), each with the offending item, the net and
  the gap. The first 275-item pair batch came back "all clear" in 2 s, which let me trust the
  arithmetic and move on. Without it I would have been iterating through full KiCad DRC runs
  (15–25 s each) and reading JSON. Biggest saving of the session, in time and in mistakes.
- **`bt check`.** One line, CHECK OK or CHECK FAILED, with fill freshness, DRC, unconnected items
  and nets in pieces together. The failed run named the two track ends that were not joined, which
  pointed straight at the walled-in +3V3 fingers.
- **`bt render`.** Per-layer and zoomed pictures with fills are how I found the walled-in pour,
  judged the cap-area pours, and saw that the gold fingers were being bridged by my first +3V3
  bars. `--pads` labels are readable at 1 mm grid.
- **Writing copper as text and leaving the .kicad_pro alone.** I rebuilt the board from the
  unrouted file four times; the project file stayed byte-identical apart from my one rules edit.
- **`bt board`.** Saved a dozen small queries at the start.

## What got in the way or confused me

- **No keepout / rule areas.** I needed "no zone fill on In1 under these pads". `bt zone` cannot
  make one, so I used pcbnew (scripts/add_voids.py) and had to save and restore the .kicad_pro
  around it myself. bt's fill and DRC then respected the rule areas correctly.
- **`bt zone` warning "N pads just outside the outline (not joined by this zone)".** It fired for
  J1.B8, J1.A9/A10 and the +3V3 fingers. All of those were joined: the outline overlaps the pad
  top, or a track reaches into the zone. The warning seems to go by pad centre. It reads as an
  error and is wrong in the case where the outline deliberately covers only the end of a long pad.
- **`bt zone` is one layer and one zone per call**, and prints two lines of boilerplate each time.
  Twelve calls per rebuild; I wrapped them in a shell function and grepped the noise away. A zones
  file (like items.json) would be better. There is also no way to name a zone.
- **`bt stitch`** put a column of GND vias at x = 181.8, exactly on the edge of my +12V zone
  outline. Legal, but nobody would put them there. It also proposed one via 0.17 mm from a
  differential-pair via. I dropped and moved those by hand. The "passed over" counts by reason
  were helpful.
- **`bt congestion`** printed directions like "only +y→(145.21,116.11)" for a pad at y = 118.8,
  so "+y" means towards smaller y. That is the opposite of the "KiCad mm, y down" stated in the
  help. Its headline (191 crossings between 190 net pairs) was true but did not say the useful
  thing: that the pin order is fully reversed. `bt planar` probably says that directly; I did not
  run it, which is my omission.
- **The help text.** Everything is there, but as dense paragraphs. Finding whether `bt zone` had
  a keepout option meant reading the whole Write section.
- **`bt render` header line** becomes unreadable on small zoomed images. Cosmetic.

## What I did myself instead, and why

- Pair geometry, corner via pairs, J1/J2 ground vias, +3V3 finger stubs: computed in Python. The
  requirement was exact mirror symmetry (zero skew by construction) and specific via positions
  relative to pads on both sides of the board. Coordinates were faster for me than steering a
  router with constraints, and probe made that safe.
- Zone outlines: hand-written polygons following the line of pair corners.
- Plane cut-outs: pcbnew, as above.
- A build script that regenerates the board from the unrouted file, so every change was a rebuild
  and a `bt check` rather than an edit-and-undo.

## What I would change, add or remove

1. Add rule areas to `bt zone` (no fill / no tracks / no vias, per layer), and zone names.
2. Accept a zones file, several layers per zone, and a quiet mode.
3. Make the "pads just outside the outline" warning test real overlap with the pad or with copper
   joined to it, not the pad centre.
4. `bt stitch`: keep a margin from other nets' zone outlines, and a `--keep-off "NET*" D` option
   to stay a set distance from named nets (differential pairs).
5. Fix or relabel the `+y`/`-y` directions in `bt congestion`.
6. A primitive for a differential pair's layer change, with the via pattern as an option (side by
   side, in line, mirrored 90° with P/N swap) and the return vias. That is the piece I had to
   build by hand, and the piece most likely to be got wrong.
7. A pour neck report: narrowest width of a zone's fill between two named pads. I estimated the
   +3V3 path width from pictures.
8. Split `bt help` into short per-command pages with one example each, and a one-screen index.
9. Nothing to remove. The commands I did not use were not in the way.
