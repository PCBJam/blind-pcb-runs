# BT review on Glasgow revC3

I used bt for inspection, candidate checks, rule editing, refill and verification. The exact published revC3 layout matched the supplied board, so I imported its copper and made targeted edits. I did not exercise the autorouter, bus, pair or fanout commands. I have no performance result for routing this board from scratch with bt.

| Command | Calls | What it contributed |
| --- | ---: | --- |
| `board` | 3 | Two successful inventories and one invocation without the board filename. The first inventory exposed the power class, pad overrides, dimensions and all 272 placements together. The final one identified a custom rule the routing engine could not evaluate. |
| `render` | 9 | Produced the first nine progress images. The layer and box filters made it quick to compare the same power array before and after the failed trial. I used KiCad's own layer plots for the final overview. |
| `length` | 2 | One call covered the clocks, crystal and USB nets. The other covered all 13 LVDS pairs. The output explicitly includes branches, which matters at the USB connector. |
| `query` | 3 | Inspected the RECOVER jumper, one bank-power transition and the switch shell. The coordinates and UUIDs let me distinguish a via with a purpose from the single-layer via on R40.1. |
| `fill` | 1 | Refilled the imported zones in place while preserving the project file. KiCad then reported zero opens, down from 499 on the input. |
| `probe` | 5 | Tested small sets of return-via sites and two 437-site grids. The clearance numbers found useful candidates. A polygon-hole error prevented using the full-board result directly. |
| `rules` | 1 | Added the USB class and raised edge clearance in a single invocation on the candidate project. A text diff confirmed the changes were confined to those requested fields. |
| `same`, `vias --under-min` | 2 each | Quick checks for locked placement, net assignments and via dimensions. I separately compared every complete footprint definition to cover unlocked parts, artwork and duplicate reference strings. |
| `drc --baseline … --refill --courtyards` | 2 | Each run reported about 53 s. The final three-line result compared 418 PCB findings and 421 parity findings, and confirmed zero new findings and zero opens. This saved manual inspection of hundreds of repeated entries. |
| `check --no-fill` | 1 | Independently reported zero open items, zero nets in pieces and zero bt findings. Its overall result was CHECK FAILED because it includes inherited footprint and courtyard findings. |
| `help` | 8 | Used the general help and seven command-specific lookups. The short forms were easier to use during local edits. |

## Where the tools disagreed

- **Rule-area holes.** On the board with its perimeter rule area, `bt probe BOARD --via 54.6,97.4 --net GND --via-size .4,.2` corresponds to one candidate from the multi-site probe. Its only reported conflict was the F.Cu/B.Cu keepout. This rule area is a border with a large interior cutout. The candidate is inside that cutout. Omitting just the rule area on a scratch copy made the probe pass, with 0.174 mm to the nearest other-net trace. I added the via to the board with the rule area intact. Native KiCad DRC accepted it. Handling every contour and its holes would have saved two grid sweeps and made the result usable on the real board.
- **Baseline project context.** My first baseline copy lacked the two child schematics. bt reported 255 new parity findings. Putting the child sheets and symbol table beside the baseline produced zero new parity findings, in agreement with native KiCad. A diagnostic naming a missing sheet would make this easier to catch.
- **Courtyard severity.** `bt check --no-fill` reported 72 errors while native project DRC reported four. The difference was exactly the 68 pre-existing courtyard overlaps that the full check promotes from warnings. Printing the severity override next to the summary would clarify the result.
- **Custom constraints.** `bt board` explicitly identified the unsupported reference condition in the SW1 pad-specific edge rule. That disclosure helped. Printing the same qualification in a probe near the affected item would make the local result easier to interpret.

## Work outside bt

I used pcbnew to compare pad geometry and read back fills, then transferred only the reference copper and perimeter rule area. I adjusted the same-net via arrays together with their track endpoints and used native KiCad JSON reports to check every revision. I also compared schematic and PCB nets as sets of terminals so legacy net-name changes could be distinguished from actual wiring differences.

For USB, I measured J1 pin to U1 pin for each connector orientation. A `length --from PAD --to PAD` option that reports planar length and barrel traversal separately would improve on whole-net totals for this case. I used an external cross-section model for impedance and native KiCad exporters for fabrication. The changes I would prioritize are correct keepout holes, pad-to-pad length measurement and a more explicit baseline/override report. I would keep the compact query and baseline DRC outputs.
