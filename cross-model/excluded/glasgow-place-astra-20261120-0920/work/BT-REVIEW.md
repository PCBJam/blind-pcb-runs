# bt review on Glasgow rev C3

I used bt for inspection, plotting, rule edits and independent connectivity checks. The published rev C3 board matched all footprint and pad IDs, so transferring its established placement and routing was a better fit for this job than running an autorouter. I did not exercise the route, bus, pair, fan, escape or shove algorithms.

| Command | Uses | What it contributed |
| --- | ---: | --- |
| help, board | 1 help, 2 board invocations | One invocation needed the board path. The successful inventory gave me the outline, original class rules, footprint count, locked positions and nets in one read. I kept the long output in a scratch file and searched it locally. |
| render | 10 | Six stage images and four layer views for the final montage. The ability to crop to RN3 or the reset switch made the failed trials legible without setting up a GUI. |
| drc, check | 1 baseline DRC, 2 checks | The baseline exposed the existing footprint, artwork and parity findings. The checks independently verified zero remaining nets in pieces. The final full check took 38 seconds. Its handling of exclusions obscured the release result. |
| same | 2 | Fast confirmation of the 243 allowed moves and the locked placements, part inventory and pad nets. I also compared UUIDs and normalized full footprint definitions because several artwork items share the same reference. |
| length, vias | 1 each | The length output explicitly says that whole-net totals include branches, which matters at USB-C. The via check confirmed the transferred vias met the project minimums. |
| part, query | 1 part, 4 queries | These gave the reset-switch coordinates, track widths, layers and local connectivity. The R40 query established that the flagged via sat directly in a jumper pad. |
| rules, fill | 1 rule edit, 3 fills | The readback confirmed the USB class and 0.30 mm edge rule. Refills worked for ordinary via changes. A rule-only change needed an independent KiCad refill. |

## Two reproducible discrepancies

1. On the final project, `bt check glasgow.kicad_pcb` prints **72 DRC errors, 346 warnings, 0 unconnected, 0 nets in pieces, 0 bt findings**. KiCad's direct error-only run with refill and all track errors enabled reports zero errors. The KiCad exclusions-only report contains exactly 68 individually reviewed courtyard pairs and four mixed-pad-type findings. bt requests all severities, promotes courtyards to errors and drops the JSON `excluded` flag and its comment when reading the report. Preserve both fields, show excluded counts separately and use active violations for the exit status.
2. On a routed candidate, I used `bt rules` to raise edge clearance from 0.05 to 0.30 mm, then ran `bt fill`. It reported “filled 32 zones”. DRC on the saved candidate still measured several shield and plane edges at 0.0505 mm. A direct `kicad-cli pcb drc --refill-zones --save-board` regenerated those edges under the new rule. The two shield vias and switch pad needed physical moves as well. I would use the same project-loaded refill path for `fill` and `check` and distinguish copper zones from rule areas in the count.

## What I did separately

pcbnew let me move the supplied footprints, match every pad, copy the reference copper by net, and adjust small groups of vias with their attached tracks. I used the schematic XML export to compare pin membership independently of generated net names. This resolved 199 apparent net conflicts without renaming a single board net.

I measured the actual front USB paths from connector pads to FX2 pins because whole-net totals made the positive side look 1.086 mm longer. On the direct paths the difference is 0.054 mm. A pad-to-pad electrical-path option in `bt length` would have saved that graph traversal. For assembly review, adding nominal body or pad separation beside each courtyard report would also reduce the work of distinguishing tight placement from a physical collision.
