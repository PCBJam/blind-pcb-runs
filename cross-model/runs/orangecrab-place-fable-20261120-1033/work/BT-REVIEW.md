# bt – review after the OrangeCrab job

I used `bt` for almost everything; pcbnew Python only for two small read-only look-ups and
`kicad-cli` only for the final DRC report. The board was written by `bt` throughout, so the
`.kicad_pro` problem never came up.

## What I used, and how often

Counted from my shell commands (a call inside a loop counts once, so `route` is really about
250 net attempts):

| command | calls | verdict |
|---|---|---|
| `probe` | 110 | the most valuable command |
| `apply` (mostly `--checked`) | 107 | reliable |
| `route` (single net, `--nets`, `--batch`) | 93 | good for one net in open space, poor as an autorouter here |
| `rm` / `unroute` | 66 / 54 | reliable |
| `ratsnest` | 65 | reliable, one reporting quirk |
| `render` | 64 | essential |
| `query`, `part`, `vias`, `nets`, `board`, `length`, `rules` | 47 / 39 / 21 / 6 / 4 / 13 / 12 | reliable, one trap in `vias` |
| `help` | 26 | good |
| `zone`, `fill` | 20 / 20 | fine |
| `place`, `near` | 19 / 12 | `near` very good |
| `plane` | 11 | very good |
| `pair`, `fan`, `free` | 5 / 4 / 5 | not useful on this board |
| `cleanup`, `islands`, `drc`, `same`, `undo` | 4 / 4 / 3 / 2 / 2 | useful; `islands --fix` did something I did not want |

Not used: `tune` (I never got to length matching), `silk`, `congestion` (looked at once
early on), `check`.

## What helped

* **`probe` + `apply --checked`.** Every hand-made track and via went through it. The line
  "nearest … at 0.094 mm" after each *ok* item let me tune a 15-net fan with 0.25 mm stub pitch
  and 20 vias to 0.09–0.11 mm gaps in three rounds. It caught things I would have missed by
  eye: hole-to-hole 0.22 < 0.25 in a via row, a via landing on a bottom-side capacitor pad,
  a track in the copper of a logo. I never caught it being wrong. A full file takes 1 s.
* **`probe --vias "x,y;…"`** as a via-site hunt: one call told me that 5 of 77 candidate
  sites north of the FPGA were free. That is the right primitive for dense areas.
* **`near --each`**: placed 22 of 25 FPGA decouplers and 16 of 17 RAM-side parts on legal
  spots in two calls. Large time saver.
* **`plane`**: GND 93 of 100 pads with 51 shared vias in one call, with a reason per missed
  pad ("26 spots too close to track RAM_CK- on In2", "spots that fit miss the pour: In4 has
  P1.1V there"). The "misses the pour" messages made me reshape the In4 islands early.
* **`render --layers X --pads`**: single-layer pictures were how I understood congestion.
* **`unroute --box / --layer`, `rm --uuid`, `removeAt` in items files**: precise undo of
  router output without touching my own copper.
* **`same`**, **`drc --baseline`**: exactly the two questions I had at the end (did a locked
  part move; which violations are mine).
* Warnings that were worth having: "runs through other nets' pours: 11.3 mm in RAM_VDD on
  In4", "a detour: 60.9 mm for 16.4 mm straight", "fills older than the copper".
* Help texts are dense but complete; I rarely had to guess a flag.

## What got in the way or misled me

* **`route` as an autorouter on a dense board.**
  * `bt route --nets "*"` (0.12 mm, 3 layers): pass 1 needed more than 9 minutes for 75 of
    85 nets and was killed by my 10-minute limit before passes 2/3. `--budget` does not
    bound a single failing net (10–40 s each).
  * `bt route --nets <22 nets> --order escapes-first --passes 3`: pass 1 failed 12 nets,
    passes 2/3 produced SD0_CMD 43 mm and SD0_DAT2 with 8 vias. Thrown away.
  * Routing nets one after the other works until the first nets have taken the scarce lanes;
    then the rest fail or detour (ADC_CTRL1 33 mm for 15 mm, ADC_MUX2 63 mm with 38 mm on
    the top layer). There is no notion of a bus or of lane order, and no "leave room for the
    nets that have to follow".
  * With `--layers …,In4.Cu` it happily ran ADC_MUX2 diagonally through the 1V1 island and
    ADC_MUX3 down and across the 1V35 column. The "may split them: bt islands after a
    refill" note was there, but `bt islands` then said "with pours on every layer they would
    make 2" (fine) while the refilled board's ratsnest showed the buck cut off from the FPGA.
    I believed `islands` for a while. A route that severs a pour from its feed should fail,
    or at least `islands` should look at the fill.
* **Failure messages name blockers, not causes.** "start is boxed in … blocked by via
  RAM_A9" when the cause was stub pitch too tight for the track width; "blocked by track
  (SPI_CONFIG_SCK) at 156.34,106.71" for ten different nets, 20 mm from where each was
  actually stuck (it is where the search front died). I learned to ignore the list and look
  at a render. Several "boxed in" verdicts were simply wrong: IO_A2 "boxed in" had a legal
  0.09 mm way out that I then drew by hand in one probe round.
* **`--all` summary is confusing:** "1/2 routed; FAILED: ADC_MUX0" for a net that was fully
  connected afterwards (ratsnest clean). Same with "2/3 routed; FAILED: ADC_SENSE_HI". I
  spent several calls re-routing nets that were done.
* **`probe` ignored `"remove": [uuid-prefix]`** in an items file (help says removals are
  taken out before checking); `bt rm --uuid` with the same prefixes worked. I had to remove
  first and probe after, which loses the "trial" property.
* **`bt vias --box` without `--all`** listed 43 of 108 vias in the box (the 0.28 mm ones were
  missing) with nothing saying it was filtered. I built a wrong via map from it.
* **`islands --fix`** joined 3V3 balls with 0.089 mm tracks on In4 through another net's
  island (a 4 mm slot in the core plane) without saying which layer it would use. For power
  nets it should refuse other nets' pours or ask for a width.
* **`fan`** on the csBGA-285: a via per ground ball, depopulated sites ignored, In2 under
  row A. Not usable; I wrote my own generators.
* **`pair`**: fine for the FPGA-side USB pair; the connector-side call returned "ok" but had
  joined N to a test point 1.5 mm away and sent P on a 17 mm walk alone. Only the 16 mm skew
  figure gave it away.
* **`route --batch` pad → pour** for ~120 plane stubs did not finish in 9 minutes; `plane`
  did the same job in 20 s. `--batch` with through-points draws greedy straight lines, so
  the second lane of every RAM row gap was blocked.
* **`place`**: omitting the side keeps the current side (surprised me once); parts without a
  courtyard get a bounding-box pseudo-courtyard, so test points and the oscillator always
  "overlap"; "already so where it is now, not counted" hid a real pad-on-track conflict.
* **`free --side B`** offered the flash's exposed pad as free area – it ignores pads/copper.
* **`rm x,y`** takes tracks *and* vias under the point (I wanted `--via-only` to be the
  default when a via is there). Applying an old generator file re-adds copper that was
  removed since; `apply` could warn when it re-creates something `rm` took out.
* Stale stubs after moving a part show up only in `cleanup --dry`.
* Pictures cannot be measured: zoomed renders have no grid labels and the box is padded to
  the image aspect, so I mis-read coordinates from pictures twice.

## What I did myself instead, and why

* All BGA escapes, the DDR lanes, the flash fan, the south header bus, the lattice lanes
  under the FPGA and the JTAG fan: Python scripts that emit items JSON, then `probe`. Reason:
  these only work when via positions and lane order are chosen together, which the router
  does not do.
* Layer planning for the DDR bus (which net on which layer) by a pin-order analysis in
  Python: longest monotone subsequence stays on In2, the rest goes to the bottom.
* Via-site hunting with probe grids instead of `fan`.

## What I would change, add or remove

1. **A bus/ordered-escape command**: given N nets leaving one edge and their targets, choose
   lane order and via rows together (what `escapes-first` hints at but does not deliver).
   This is where all my hand work went.
2. **Make failures say the cause**: narrowest gap on the best partial path ("needs 0.268 mm
   between via A and via B, has 0.22"), not three far-away blockers. And never report
   "FAILED" for a net whose ratsnest is clean.
3. **Protect pours**: refuse (or need a flag for) signal routes that disconnect a pour from
   pads it feeds; let `islands` judge by the refilled copper; `islands --fix` must not cross
   other nets' islands with minimum-width tracks.
4. **`probe` must honour `remove` uuid prefixes**, the same way `rm` does.
5. **`vias`**: print "N more not shown (--all)" when it filters.
6. **Hard time bounds**: `--budget` should stop a running net too; long batch calls should
   checkpoint so a killed run can resume.
7. **Render**: always draw grid labels, or print the px→mm mapping; an option to mark the
   free via sites for a given size would have replaced my probe grids.
8. **`route` on plane layers**: when `--layers` names a plane layer, say per net how much
   pour it cuts *before* writing, and offer `--no-pours "P1.1V,…"`.
9. Remove or rework `fan` for depopulated BGAs; `pair` should fail rather than degrade.
10. Keep `probe`, `apply --checked`, `near`, `plane`, `same`, `drc --baseline` exactly as
    they are – those carried the job.

## Bottom line

`bt` made the hand-crafted parts fast and safe: I could place about 900 segments and 250
vias from scripts with confidence, at about 1 s per check. It did not make the hard part –
deciding lane order and via positions in congested areas – any easier, and the autorouting
modes cost me a lot of time and, at the end, quality: the worst routes on the board (tracks
in the ground plane, thin links through the core plane) are ones I accepted from it under
time pressure. The board is not finished; that is my planning (see NOTES.md), but better
failure messages and pour protection would have shown me the dead ends much earlier.
