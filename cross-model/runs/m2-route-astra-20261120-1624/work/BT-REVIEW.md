# bt review

I used bt throughout the layout. Its largest contributions were copper probing, safe application of batches, and checking connectivity after a real KiCad refill. The standard router was most effective on the short sidebands. The differential-pair geometry and power distribution needed circuit-specific planning.

## Commands used

Counts are approximate for repeated inspection, rendering and retry commands. They include work on scratch copies.

| Command | Use on this board |
| --- | --- |
| help, board, part, rules | Several initial reads, two connector/component pad inspections, and two net-class writes including the scratch trial. The single board report exposed the two socket faces, pad nets, mask rings and existing PCIe class. |
| probe, apply | About ten explicit probes and about twenty application attempts, many with an additional checked probe. One call checked all 230 replacement signal segments against the completed board. This saved individual coordinate checks on 18 nets. |
| escape | Three connector trials. Avoid boxes yielded 0/21 socket and 0/14 M.2 ground escapes. Requiring socket vias outside the courtyard found 16/21. I retained the results as design feedback and generated the production ground stubs separately. |
| zone, fill | Nine zone commands including replacement of a local supply outline, and roughly a dozen explicit fills. The saved-fill workflow caught a real bottleneck at the three lower 3.3 V fingers. Widening their collector joined the contacts. |
| route | Five search invocations, including one socket ground connection, a five-net trial and local reroutes. The five-net pass took about three seconds and connected every net. The local paths provided a good starting point for the final socket and CLKREQ routing. |
| via, vias, query, ratsnest, length | Two single-via placement attempts, several via inspections, one socket-window query, and repeated connectivity and length reads. The length report made it easy to compare both members and count their transitions. |
| render | About a dozen renders for the log and close inspection. The connector zooms exposed the relation between pad rows and via positions. |
| drc, check, same | Three DRC runs including baseline, mounting trial and release comparison. Three complete checks and one placement comparison. I also compared every footprint and pad directly with pcbnew because the fixed-placement requirement included unlocked parts. |

## Where results needed interpretation

- With an insertion-area box, escape applied the avoidance to the entire stub, including its source inside the box. I wanted the copper to leave the finger normally while keeping the drill behind the fingers. A via-only keepout for escape would have avoided both failed searches.
- The outer-layer route for reset and wake used three vias per net. Repeating it with a one-via limit reported that three were needed. A planned corridor past the end of the via field produced one-via routes for both. The failure message would be more accurate if it distinguished the best path found from a proven minimum.
- A checked 12 V via near J4 passed the initial probe. After filling, it had acquired the ground net and KiCad reported a clearance and a hole-clearance error against J4. The proposed via was outside the intended rail fill. I replaced the array within the rail, checked the resulting net assignments, and repeated DRC. A before/after via-net diff in fill or check would expose this immediately.
- A clean electrical check could coexist with a missing M.2 retention drill. The board report did identify both mask rings. Correlating unmatched edge-centered rings with inherited edge-clearance exclusions would have surfaced the mechanical issue sooner.
- Fills on one layer share a render color. Distinct colors per net would make the power distribution and ground reference easier to inspect. I used pcbnew’s filled polygons to draw the final four-layer overview.

I constructed the coupled traces from matched centerline offsets and deliberately placed the via pairs and their ground returns. That gave control over the handedness change between the two fixed connectors. I used a cross-section calculation for impedance, sampled the actual adjacent ground fills, and inspected native KiCad mask and drill exports. The numerical probes and release checks made those manual decisions practical. The next features I would use most are a paired transition with specified entry and exit orientations, and a report of adjacent-plane voids under a routed pair.
