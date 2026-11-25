# bt review

Written at the end of this session on the RaspberryPiNVMeNAS board (4 layers, 254 parts, 459 nets, CM4, ASM1184,
four M.2 slots, RP2040). The board is **not** finished: `bt check` ends CHECK FAILED with 77 open nets and 147
unconnected pads. So this review is about what bt did for me and where it fell short, not a finished result.

## Commands I used, roughly how often, and whether they helped

| command | uses | verdict |
| --- | --- | --- |
| `bt render` (PNG, with `--nets`, `--layers`, `--box`) | ~25 | Most useful tool I had. I read the picture at every stage and it caught most of my placement mistakes: CM4 pins with no exit, RP2040 decaps boxing in pins, converter clusters walled in. The `--layers In2.Cu` view showed the actual zone fill. |
| `bt query` (a box, optionally a layer) | ~35 | Essential for "what is blocking this pin". Its output tells me exactly which pad or track is in the way; the uuid output is what made surgical removal possible. |
| `bt near --each` | ~10 batches (about 250 parts) | Good for passives: one line of `REF:PAD` per part, sensible spots, legal by courtyard and copper. Slow: 60-100 s for 60-80 parts. |
| `bt place` (trial, then `--apply`) | ~12 | Reliable; "TRIAL ONLY" plus the per-part problem list made moves safe. It checks tracks as well as pads. |
| `bt escape` (a list of pads, or `--net`) | ~8 | The best routing tool I used. Planar stub-and-via fan-outs for the M.2 pins, the CM4 Ethernet pins, the ASM1184 power pins and 256 ground pads. Caveat: with `--net GND` it also plans every other unconnected GND pad on the board, not only the ones I listed (see below). |
| `bt via --near` | ~6 | Good for one-off spots and for checking a pad's surroundings; it says why the 8 neighbours fail. |
| `bt route --batch` with `through` | 3 batches | The only way I found to nest lanes in a fixed order (lowest pin turns furthest out). Needed my own geometry to choose the corners. |
| `bt route --nets` / `--net` (incl. `--order given`, `--neck`, `--grid`, `--width`) | ~60 runs | Connected most of the simple links (2-pin nets, short hops). Failed on the dense parts: see "what got in the way". |
| `bt apply --checked` | ~30 | The safety net that made it possible to apply a batch while other batches were still being routed. Every refusal named the copper it would have shorted. |
| `bt zone` (`--poly`, `--delete --at`, `--edit`) and `bt fill` | ~25 | Zones were quick and they connected pads that routing could not reach. Two same-net zones with different priorities that only touch do NOT join (see below). |
| `bt islands` (dry run) | ~15 | Excellent diagnosis: "pieces, what joins them, and why not" (boxed in, old fill, thermal spokes). I used it to find every walled-in converter input. |
| `bt unroute`, `bt merge` | ~12 | Needed to take copper out and put it back in a different order. Worked as described. |
| `bt ratsnest` / `bt nets` | ~20 | The progress measure; cheap and accurate once the fills were refreshed. |
| `bt drc --refill` | 6 | Good: KiCad DRC on a copy with grouped output. The `--refill` option was needed because the saved fills were older than the copper. |
| `bt check` | 4 | Clear one-line verdict and the right categories. Takes about 50 s. |
| `bt same` | 4 | Confirmed the locked parts did not move, every time. |
| `bt rules` (`--class`, `--dry`) | ~12 | Easy. `--dry` before writing was reassuring. The class changes it writes are exactly as stated. |
| `bt undo` | 1 | Saved the board after my `-o` mistake (see below). |
| `bt pair` | 3 | Did not work on the M.2 or CM4 pin rows: the P half routed, the N half was boxed in by it every time. I routed single nets instead. |
| `bt bus`, `bt planar`, `bt tune`, `bt fan`, `bt cleanup`, `bt seg`, `bt stitch`, `bt probe`, `bt offset` | 0 | Not used. (`bt probe` ran implicitly inside every `--checked` apply.) |

## What helped most

1. `bt render` plus `bt query`: the picture told me where, and the query told me what. Almost every fix started there.
2. `bt escape` for connector pins and for the ground pads: one call replaced hundreds of hand-placed vias.
3. `bt apply --checked`: a batch that would have shorted something was refused as a whole, and a rejected batch
   cost nothing except a re-route.
4. `bt islands`: the explanation ("every piece could be reached by a pour, but the fill as saved leaves 4 apart")
   told me exactly where to look, and separated the cases that need a track from the cases that only need a refill.
5. `bt zone` for the 3.3 V zones and the +5V island: far faster than routing the same copper.

## What got in the way (with the command and what happened)

1. **`bt islands --fix -o FILE` overwrote the board.** For `bt islands` `-o` means an items file (`bt islands ... --fix -o items.json`),
   but I passed the board path, and the board became 360 bytes of JSON. `bt undo` restored it (the earlier board was
   still in `.bt-undo`), but nothing warned me, and the next bt commands crashed with `n2.filter is not a function`
   because they were reading JSON as a board. Two suggestions: refuse an `-o` path that ends in `.kicad_pcb` for an items
   command, and say "not a KiCad board" instead of crashing.
2. **`-o` means different things in different commands.** `bt route -o`, `bt escape -o`, `bt unroute -o`, `bt islands -o`
   write items files; `bt zone -o`, `bt fill -o`, `bt apply -o` write boards. I used the wrong one twice. A single rule
   (or a `--items`/`--board` flag) would prevent it.
3. **Silent failures.** `bt route --nets GND --all` produced no output at all and exited; `bt route --net GND --all` ran
   for more than five minutes with no progress line before its first net, then I stopped it. A 1,081-character `--nets`
   list with `--order given --passes 2` exited with code 4 after six seconds and no message; the same nets in chunks of
   ten worked. Exit codes without a message are hard to act on.
4. **`bt route` necking.** On a 0.5 mm pitch row the router can only leave at 0.2 mm, and it then keeps the neck width for
   the whole run: a 50 mm PCIe lane came out at 0.2 mm end to end (`NECKED 49.61 mm at 0.2`). The summary's "NECKED"
   figure is a length, not a count of necked stretches, which makes it hard to see where the narrow copper is.
   A `--neck-only-in BOX` option (necks only inside a box, class width elsewhere) would have saved me a manual pass.
5. **`--width` cannot go below the class width.** A narrow LED or reset net stayed boxed in because its class forced 0.4 mm.
   I had to move those nets to another class with `bt rules`. A per-net `--width` that may go below the class with a
   warning would be simpler.
6. **Slow, opaque searches in dense areas.** Single nets took 2-25 s and often ended with "gave up after N s" with no
   hint of the blocking copper beyond the first object. The boxed-in messages name one blocker; the real fix was usually
   to move a capacitor or unroute a stub, which the tool cannot suggest.
7. **`bt escape --net GND` plans other nets' pads too.** I passed a list of 19 pads and it planned 202 vias, most of them
   for pads I had not listed. It is useful, but it is not what the flag name suggests; `--only` would be clearer.
8. **Same-net zones with different priorities.** My first +5V islands only touched at a corner (and then overlapped by 0.6 mm
   where GND vias cut the overlap). The fill left them apart and `bt islands` said so, but `bt zone` accepted both
   without a warning. A warning at creation time would have saved two rounds.
9. **`bt route` cannot finish a converter's +12V input.** The narrow (0.25 mm) track that worked for U15 and U13 failed
   for U10, U11 and U2, where the walls were copper from other nets' tracks and the ground stubs my own escapes created.
   The tool reports the blocker, but moving a whole cluster is a judgement only I could make.
10. **Pair routing on pin rows.** `bt pair` routed the P half and then boxed in the N half every time, even with
    necks at both ends.
11. **Speed.** Board-wide `--passes 2` runs took 20 minutes or more; chunks of 10 nets took 4-7 minutes each. Long
    background runs are workable with `--progress` and `--budget`, but the chunked pattern (route, apply, route) was the
    only reliable pattern.

## What I did by hand instead, and why

- Floorplan and the M.2/ASM topology: the router cannot find nesting or a whole-board floorplan; I chose the placement by
  reading the schematic and the drive envelope.
- Per-net class choices and the 0.4/0.2 pair geometry (from the stackup).
- The M.2 lane corner points for `--batch`, and the decision to route clocks last.
- The +5V island and the M.2 3.3 V zone polygons (I chose the shapes; `bt zone` drew them).
- Narrow-track workarounds for converter inputs, and the ground-stub removal round them.
- The decision to leave the converter inputs and the RP2040 control nets open rather than keep moving clusters.

## What I would change, add or remove

- **Add:** `--neck-only-in BOX`; `--width` allowed below the class width, with a warning; a progress line before a
  long link-list computation; an exit code and message for every bad argument.
- **Add:** a warning when same-net zones with different priorities touch or overlap in a way that will not join.
- **Add:** a "why not" for each boxed-in pad that names the cluster to move (e.g., "U10.1 is walled in by C18.2 GND
  stub and M1 link track"), not only the first object.
- **Change:** one meaning for `-o` (items file or board) across all commands, or a required suffix check.
- **Change:** `bt escape --net X` should plan only the pads listed unless `--all` is given.
- **Remove or fix:** `bt pair` on pin rows (or document that it is for pairs with room only).
- **Keep:** `bt render`, `bt query`, `bt escape`, `bt apply --checked`, `bt islands`, `bt undo`, `bt check`.

## Scope of my use

I did not use `bt cleanup`, `bt seg`, `bt tune`, `bt bus`, `bt planar` or `bt fan`. I would have liked `bt tune` for the
PCIe and Ethernet pairs, and `bt seg --width` to widen the clear stretches of the necked lanes; I did not get to them.
