# Board tools review

I used bt for the board survey, local routing, copper insertion, fills, tuning, visual records and verification. For this design I would use it again for those tasks. Its pair-router success condition was too permissive for PCIe, and large, congested multi-net searches needed a second routing method.

## Commands and outcomes

| Commands | Use in this job | Outcome |
|---|---|---|
| `help`, `board`, `nets`, `rules`, `part`, `query`, `congestion` | One full survey and congestion report, repeated focused reads, seven final rule edits and a scratch edge-clearance test | The initial summary exposed the 254 parts, 459 named nets, hole-clearance overrides and empty copper stack in one read. Pin coordinates and net names were especially helpful at the ASM1184 and repeated buck stages. |
| `pair` and `probe` | One detailed PCIe trial and a batch probe of custom pair geometry | The trial exposed an electrically unsuitable result before it reached the working board. The probe screened 627 items in one call. |
| `route --nets` and `route --batch` | Four main jobs, including two seven-converter trials, local links and a 118-net control pass | The explicit 21-request switch/inductor/bootstrap batch completed every connection without a via. The large outer-layer batch completed 91 of 118 nets in 303 seconds and retained useful partial routes. |
| `plane` and `via --near` | Six plane-escape runs, including three ground trials at different stages, and eight individual site searches | The final ground run found a connection for 253 of 268 requested pad entries. The CM4 5 V run found access for five of six contacts. Of the eight late individual searches, only U18.51 found a site, but the obstacle names helped identify what needed to move. |
| `zone`, `fill`, `apply` | Two initial ground zones and repeated in-place copper applications and refills, each used more than ten times for apply and fill | JSON items let me keep experimental routing outside the project until I chose a result. Merging items and refilling on a project copy avoided hand-editing thousands of segments or overwriting project settings. |
| `length` and `tune` | Several length audits and 20 P/N tune requests | Fifteen requests produced edits. The before/after lengths and explicit replacements made it practical to match the PCIe pairs and check the via counts separately. |
| `ratsnest`, `cleanup`, `same`, `drc`, `check` | Several connectivity snapshots, one targeted cleanup, baseline DRC, intermediate and final checks, and two placement comparisons | Cleanup initially shortened the selected nets by 20.946 mm and split six tracks at tees. The final large-stack check agreed with native KiCad on zero opens and reported zero nets in pieces and zero bt-specific findings. |
| `render` | All 13 progress images plus focus views | Window, layer and net filters made a reproducible visual log practical without a GUI. |

The timings above come from command output. I did not measure token savings. The main saving was the number of manual coordinate and clearance checks avoided by the batch route, plane and tune operations.

## Where the answers needed interpretation

- `bt pair RaspberryPiNVMeNAS.kicad_pcb --nets PCIe_RX_P_1,PCIe_RX_N_1 --width .2 --gap .16 --layers F.Cu,B.Cu --grid .15 --tune` reported “ok”, zero skew and “vias Infinity mm apart”. One member stayed on F.Cu and the other spent most of its length on B.Cu. The warning was accurate, but the success summary made it easy to accept an uncoupled pair. Progress image 002 records the discarded result.
- The first seven-net switch-node batch joined each switch pin, inductor and bootstrap capacitor with the same width and reported success. Specifying the high-current pin-to-inductor connection first, then the lighter capacitor branch, produced a better physical result. The explicit batch interface worked well here.
- `bt probe … coupled.json --quiet` reported two clearance failures against C57.1 and C27.2 at 0.113 and 0.123 mm. Native KiCad's detailed clearance check did not reproduce those two pad/trace findings. Round-rect geometry and the identity of the limiting copper feature would make the discrepancy easier to investigate.
- The 118-net batch frequently exhausted its three-second search budgets on long CM4/controller links. “Boxed in” reports naming the neighbouring pin and trace were actionable. Timeout lines did not give comparable guidance on whether a pin escape, another layer or more runtime was likely to help.
- On this board the ordinary final `bt check` exited with `Maximum call stack size exceeded`. Running the same checker through Node with a larger stack and `--no-fill` completed. I separately ran KiCad with a fresh refill and compared all saved zone polygons. The final CHECK FAILED status reflects inherited footprint and courtyard errors.

## Work outside bt

I used pcbnew, geometric clearance tests and a grid search to route the principal differential spans as one corridor, offset both conductors, and place paired vias. I used KiCad's connected-item graph to finish net fragments and a few local In2 breakouts. For power, I intersected actual front/back fill islands to select transfer vias. A copper-resistance mesh identified a weak 5 V path even after connectivity passed. The resulting CM4 feed reduced the estimated one-way resistance from about 66 to 6 mΩ. A separate headless FreeRouting trial was discarded.

## Changes I would make

1. Add a strict differential mode that routes a common centreline, requires equal layer transitions, and reports the longest uncoupled stretch, minimum/maximum gap and skew including vertical travel. A pair with an unmatched via should fail strict mode.
2. Add a multi-layer power-island view that reports the narrowest current-carrying connection and the number of parallel barrels at a layer change. A single stitching operation over each useful overlap would save considerable iteration.
3. Give batch routing an option to reserve escape vias and a short path onward on their destination layer before routing long spans. Preserve the current obstacle names and include the best partial path when a search times out.
4. Make the default checker handle large filled polygons without a stack-size override. Report native DRC, inherited findings, connectivity and bt-only observations independently in its final line.
