# Board tools on the six-key RP2040 macropad

The largest time savings came from checking candidate copper before writing it and from routing the many ordinary point-to-point links. I used KiCad’s own DRC and schematic parity as the release checks. The frequencies below are approximate where retries were involved.

| Commands | Use on this board | Result |
|---|---|---|
| `board`, `part`, `query`, `length`, `congestion` | One initial board inventory, repeated pin and copper queries throughout layout, several length checks, one congestion analysis | Exact layer, pad, endpoint and UUID output made hand routing possible without a GUI. Length exposed a redundant flash route. |
| `outline`, `rules`, `place` | One replacement perimeter, two rule edits, several placement trials | The footprint-edge and power-class changes were straightforward. Placement caught copper and courtyard conflicts before saving. I used pcbnew to place the 42 parts together with a known orientation and pin assignment. |
| `render`, `same` | Thirteen logged images and several diagnostic close-ups, locked-part comparisons during layout and at release | The fixed-window views made the failed flash trial and the tight KEY4 escape easy to inspect. The locked-part check covered positions and net assignments. |
| `probe`, `apply --checked`, `query` | Dozens of candidate checks and copper edits | These were the most valuable commands. They caught a USB bend too close to a resistor and a proposed straight power rail too close to LED cutouts. The JSON interface also made it practical to test grids of possible via locations. |
| `route`, `escape`, `via --near` | Several grouped runs, a 19-link local-power batch, repeated individual retries, several escape plans | The local-power batch completed 18 of 19 prescribed connections in about nine seconds. In the six-net flash trial, an early SCLK route obstructed adjacent pins. Rebuilding the fanout by hand and letting bt finish the escapes produced shorter, verifiable routes. |
| `unroute`, `rm`, `cleanup` | Several targeted removals and a final KEY1 cleanup | UUID removal made it possible to change a few segments without discarding a good net. Cleanup removed a 2.855 mm dead KEY1 branch. |
| `zone`, `fill`, `stitch`, `ratsnest`, `islands`, `drc`, `check` | Two zones, repeated refills and connectivity checks, one stitching grid, initial and final DRC rounds | The fills exposed three ground islands after all the signal nets were connected. Stitching placed 16 legal ground vias. Final checking verified saved fills and added an independent connectivity check. |

## Where I changed methods

The grouped flash shove run reported a 12.17 mm SD0 link. After application, `bt length` measured 37.447 mm on that net and `bt query` showed parallel starts and repeated branches. I removed the trial. A per-net before/after copper total and a check for residual branches after a shove would make this discrepancy visible in the route result.

With three physical ground gaps, `bt ratsnest` printed “5 nets not fully connected” and listed only GND. KiCad reported three open connections. They were the MCU ground island, C115 and D201. The header should distinguish nets, isolated copper groups and missing links, and account for every reported item.

`bt islands --net GND --fix` identified those three groups but could not produce a join. I enumerated the actual filled polygons with pcbnew, found where an isolated front polygon overlapped the main back pour, and probed a stitching via there. Two digital routes had to move to make room for the other ground returns. A search for **overlapping filled polygons on opposite layers** before track routing would have saved several manual iterations.

The grouped supply router spent about 71 seconds on a 3.3 V connection it rejected because it would obstruct key pins. The warning identified real congestion, but explicit end escapes and choosing the order myself were faster here. A waypoint or coordinate endpoint was also more reliable than repeated whole-net attempts on a boxed-in pin.

I would add a placement preference for the **solder-mask gap from a via to every SMD pad, including same-net pads**. Several electrically legal escapes were very close to a neighboring ground pad. I checked the via bores against the actual pad shapes and moved two ground vias before release. Timing and token savings for the whole job were not instrumented.
