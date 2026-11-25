# bt review on Glasgow revC3

I used bt most for inspection, rendering, project-rule edits, and independent verification. The published revC3 layout matched every supplied pad. Importing its copper preserved hand-designed escapes and matched routes, so this job did not exercise the autorouter, fanout planner, bus router, or pair router. I have no routing-completion or speed measurement for those commands.

## Commands used

Counts below exclude help lookups.

| Command | Use on this job |
| --- | --- |
| `board`, `rules` | Two full board inventories and one initial board invocation missing its required filename. One rules read, two scratch trials setting edge clearance, and two final class definitions. The inventories took about a second each and the rules edits preserved unrelated project settings. |
| `part`, `query` | Two part inspections and two window queries. These located duplicate USB contacts, test pads, and the R40 via without opening the GUI. |
| `length`, `vias --under-min` | Four length reports and two via-size audits. The per-layer breakdown and via counts made the LVDS and USB checks quick. The explicit note that branch copper counts prevented me from treating whole-net USB totals as end-to-end skew. |
| `render` | Ten images, including the nine logged stages and a separate USB close-up. Generally one to two seconds per image. This saved writing a board renderer and made it practical to keep the failed via-spacing trial. |
| `fill`, `same` | One initial fill and two footprint comparisons. The fill left the real project rules intact. I also compared every complete footprint block because `same` specifically reports movement of locked parts. |
| `probe` | Three calls. A five-site trial returned individual blockers, then two single-site comparisons isolated an incorrect keepout rejection. |
| `drc --baseline`, `check` | Two baseline comparisons and two full checks. The first baseline comparison reduced hundreds of inherited items to 16 hole-spacing warnings and one dangling via in about 22 seconds. The final comparison with fresh fill took about 49 seconds and reported zero new findings. |

## What got in the way

**A keepout with a hole was treated as solid.** On the imported board before the USB return changes, `bt probe B --via 53.65,95.8 --net GND --via-size .6,.3` reported `keepout on F.Cu,B.Cu gap -0.3 < 0` as its only blocker. The rule area's outer contour covers the board, and its large inner cutout contains this location. KiCad accepted the actual via there with the rule area present. The same bt probe on the original board, before importing the rule area, reported clear. The region also appeared in queries over widely separated areas. Preserve polygon holes in probe and region queries. A regression test with a perimeter keepout would exercise both cases.

**The full-check headline mixes checking policies.** The project rates courtyard overlaps as warnings. Full check deliberately promotes them, changing four ordinary KiCad errors into a headline of 72 errors. Its separate counts of zero opens, zero split nets, and zero bt findings were valuable. Showing the project-severity count and the promoted courtyard count on the first line would have saved a manual comparison. Also, `bt board` displayed the general 0.25 mm edge minimum without mentioning the local SW1 edge-clearance rule. An explicit list of unsupported custom-rule types would help when judging a trial result.

**Whole-net lengths are insufficient at branched connectors.** On USB, bt measured 14.118 mm and 13.032 mm including the reverse contacts and test pads. Following only the main A-contact-to-FX2 path gives a 0.054 mm difference. A pad-to-pad length mode with a list of intervening vias would answer that question directly. I would keep the current whole-net mode for inventory and two-terminal pairs.

## Work done outside bt

I used pcbnew and a text-level merge to transfer only copper and the stackup into the supplied board. For drill spacing I moved the via centres and their attached track endpoints together, then refilled and ran KiCad DRC on scratch copies. A via-row edit that preserved the track connections, tested expansion in both directions, and reported the limiting obstacle would have replaced those iterations.

For release checks I compared the complete footprint records, compared schematic and PCB net membership independently of net names, computed the differential impedance of the proposed cross-sections, and generated fabrication plots with KiCad. A raw pcbnew save reset rules in one scratch project and produced a misleading flood of default-rule violations. Restoring the supplied project rules corrected the test. The isolation that bt uses for board writes avoided that problem on the working project.
