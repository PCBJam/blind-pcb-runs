# bt review on OrangeCrab r0.2.1

I would use bt again for board inspection, rail escapes, straightforward routing, tuning and visual review. It got all three buck switch nodes right on the first pass. Closing the fixed 0.5 mm FPGA ball field and verifying the stacked HDI drills took a separate, layer-aware routing and checking workflow.

## Usage

I logged invocations through a shell wrapper after the initial survey. The counts include trials and rejected writes. The first survey and a few direct calls bypassed the wrapper, so the indicated lower bounds are deliberate.

| Command | Observed use |
|---|---|
| board, part, help | At least one full board survey, two logged part lookups, four logged help calls plus initial help |
| rules | 14 logged inspections or edits |
| route, pair | At least two route batches, for the three switches and for DDR/clock/USB signals, and at least one differential-pair trial |
| plane, apply | Eight logged plane calls and 17 logged apply calls |
| fill, ratsnest | 52 logged refills and one logged ratsnest inspection |
| length, tune | Four logged length reports and five logged tuning calls |
| render | 17 logged calls plus the initial image. Eighteen numbered stages are in progress/ |
| same, check, drc | Two logged placement comparisons, three final-stage composite checks and three explicit DRC calls |

## Where it helped

- The full board report put the outline, layer names, class assignments and FPGA ball nets in one searchable output. That saved repeated board parsing during the initial review. The class listing also made it easy to spot the previously unassigned memory clock.
- The first three-net route batch finished in about a second. It produced via-free switch links of 1.30, 1.44 and 1.65 mm. I kept all three. The DDR/clock/USB batch routed 33 of 51 nets in 115 seconds. It was a productive starting point for the middle of the memory bus.
- One ground-plane trial found connections for 236 of 264 pads. The proposals could be examined before writing them. I thinned the via pattern under U3 to keep signal exits open. Power-rail failures often named the closest useful copper and the obstruction, which saved searching coordinates by hand.
- The items files, checked application and scratch-copy fills made it practical to compare alternatives while protecting the project settings. The layer and net filters in render paid off repeatedly on a board where an all-layer picture obscures an individual launch.
- The final two tuning applications added 0.320 mm to CK+ and 0.430 mm to the shorter member of the upper-byte strobe. Limiting the search to the trunk layer kept the bumps off the clock termination branches. That removed almost all the physical pair skew in two short edits. The point-to-point measurement was performed separately.
- Same provided a quick pad-net and locked-placement check. I also compared every footprint, pad and outline UUID, including unlocked placements. I did not measure token savings. The timed route batches, accepted switch geometry and eliminated manual coordinate searches are more concrete measures here.

## Where it got in the way

- The RAM_LDQS pair trial routed the positive member first. The negative member then failed at the FPGA, and the obstruction report named the positive member's new tracks. Reserving both exits together would have avoided this attempt.
- On the 196-item BGA escape trial, apply with checked probing rejected five clearances. For example it reported a 0.074 mm gap between the RAM_A2 via at (164.200, 97.900001) and C1.1 against 0.089 mm required. The KiCad DRC on that candidate reported the expected single-ended fanout vias and zero copper-clearance violations. The discrepancy mattered at this pitch.
- Raw net length includes branches. On the final board, CK+ and CK− have about 20.13 and 21.15 mm of track including termination branches. Their actual FPGA-to-DRAM paths are 15.751 and 15.748 mm including vertical travel. Tuning the total net lengths together would have introduced skew at the DRAM.
- The final check correctly found zero unconnected items and zero nets in pieces. It also called all 385 laser vias undersized by comparing their 0.10 mm holes with the 0.15 mm through-drill minimum. The separate KiCad microvia minimum is 0.10 mm. Its proposed 0.28/0.15 resize would change the fabrication process and invalidate the escapes. The warning about 751 segments below 0.127 mm is a useful process-cost signal. The project explicitly requires a 0.089 mm process.
- The check reported 31 co-located-hole warnings that the saved project excludes for specific filled stacks. Native KiCad with the exclusions removed reproduces those 31 warnings. Native KiCad with the delivered project reports only the 270 inherited footprint, courtyard and text findings.
- A baseline DRC with refill and courtyards ended with “Maximum call stack size exceeded”. The standalone refill check reproduced it in 16 seconds. The baseline check without refill said ten zones were stale. Its example at (176.00, 108.47) was a RAM_D13 via spanning only L1–L2, flagged against a VDDQ pour on L4. I compared the native saved-board DRC against the original markers by type and object UUID, and separately refilled and compared all 22 filled polygon sets.

## What I used instead and what I would change

I used pcbnew to define the stack, split rails, local pours and ordered ball escapes. A custom grid router checked actual pad polygons and the occupied layers of each drill span. It tried short rip-ups and local shoves while retaining already-routed pairs. I compared alternatives per net, measured load-to-load travel including vias, and reran native DRC on each candidate worth keeping. I discarded a Specctra exchange trial after its reported completion and clearance results failed to agree with the imported copper and KiCad.

My priorities for bt would be span-aware laser and buried-via rules throughout probe, routing, check and resize; a two-ended, two-member escape planner for differential pairs; and pad-to-pad length and delay measurement that accepts named endpoints. For power routing, I would also like a report of the narrowest copper path from a regulator to its load after filling. Connectivity alone cannot distinguish a broad rail from a small bridge between islands.
