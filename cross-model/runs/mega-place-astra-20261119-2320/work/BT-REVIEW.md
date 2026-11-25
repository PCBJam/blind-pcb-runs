# Board tools on the Mega 2560

I used bt throughout placement, routing and verification. The counts are estimates from the retained trials and logs. The early placement trials and global-routing branches used separate board copies.

| Commands | Use on this board | What they contributed |
| --- | --- | --- |
| board, nets, part, rules, query, gap | An initial full read and dozens of targeted lookups | Pad numbers, nets, sides, rounded-pad dimensions and the real active rules were available without a GUI. This was especially valuable on the duplicated USB-C contacts, resistor arrays and the two jumper nets. |
| place, near | Several placement rounds | The first grouped trial rejected 30 moves. Per-part courtyard messages identified the dense crystal and power areas. I used a Python placement search for coordinated group moves, followed by KiCad courtyard checks. |
| probe, apply, via, escape | Repeated local trials and dozens of individual pad or via checks | Multiple via candidates could be compared in one call. In the first regulator-spreader trial, five of eight sites cleared; the three rejected sites all crossed RESET on the back. Checked application prevented those shorts. |
| route | Dozens of calls, including batches of up to 77 nets | The local 30-connection batch completed on F.Cu without a via. Ordered batches worked well for bypasses, clock feedback, the USB section and wide power feeds. Per-request timing and named blockers helped investigate congested pins. |
| fan, congestion, islands, ratsnest, fill, zone | Several fanout and plane experiments, repeated connectivity checks, several zone definitions | Plane-island reporting exposed separate rails which looked joined in a whole-board view. The stale-fill warning matters between moving copper and testing connectivity. |
| render, silk, drc, same | More than a dozen progress renders, silk trials, repeated rule and preservation checks | The annotated close-ups made trials reproducible. For front artwork overlapping pads I also exported the actual KiCad silk and mask plots. Comparing the original and edited footprint transforms was quick. |

## Where I used another approach

The global route is sensitive to routing order on this two-layer, 100-pin-QFP design. The multinet router reached a subset of the 77-net trial in about three minutes. Some short-looking connections became expensive once another pin had occupied the available exit. A whole-net or whole-board rip-up search using a local Specctra exchange with Freerouting let several signals move together. I used KiCad’s actual DRC and connectivity as the acceptance test after reimport. Python handled geometry comparisons and critical-path length checks.

The batch summary can say a requested pair failed even when another request later reconnects it. The +5V batch reported 19 of 20 links routed, while the final connectivity check found the rail complete. Reporting the final remaining connected groups alongside attempted links would distinguish the two results.

In the plane experiment, islands suggested a 60.44 mm connection with nine vias. The candidate did connect the indicated regions, but closer pour boundaries offered opportunities for shorter bridges. A search from reachable copper boundaries and a display of the candidate endpoints would help.

For a board with pours, I saw 24 nets in the ratsnest headline and only eight lines of net detail. I would like totals that explicitly distinguish open nets, isolated copper pieces and airwires. The JSON removal format also needs the full UUID, while query displays a shortened one. A copyable full-UUID option would remove an extra board-file lookup.

A batch request rejected the key lanes even though the command-line multi-net mode accepts it. The error listed the accepted keys. Including the per-mode supported options directly in the batch help would save a failed trial. The most valuable additions here would be a resumable global route with a saved best result, routing priorities per connection, and a silk/mask overlay in render.

## Final routing and verification

I used probe for the last two shield routes, rm and cleanup for individual copper edits, length for the two final detours, and check on two completed revisions. The final refilled baseline DRC took 28 seconds. The independent saved-board check also took 28 seconds and correctly kept the four original courtyard errors visible alongside zero disconnected nets and zero bt copper findings. The final regulator fanout differs from the first trial. A revised routing pattern cleared all eight proposed thermal vias. The finished board has six zones, including a local ground thermal relief at J5.

On the final escape, probe reported a 0.084 mm gap near C5.1 on an earlier AREF candidate. The actual KiCad roundrect geometry passed DRC and connected the net. I saw a similar discrepancy at D6.2 and C15.2 on PL5. Exact roundrect-distance reporting, or a flag identifying conservative pad bounds, would have saved several trial and refill cycles. I tested the exceptions on copies and accepted them only after KiCad checked the actual copper.

The final two-pin problem needed a clearance search finer than I could obtain economically through repeated route calls. I used the pad and trace polygons in pcbnew, searched the two copper layers on a fine grid, and adjusted the path against the actual copper outlines. Two small RXD3 via shifts let TXD3 pass without disturbing the clocks, USB, or power routing. Probe caught the nearby header via clearance, and cleanup removed a dangling PL0 branch. For difficult multinet runs I would prioritize preserving the best complete intermediate state and exposing a machine-readable blocker list with full UUIDs.
