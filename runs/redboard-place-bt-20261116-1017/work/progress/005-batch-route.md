# 005 – first batch route (thrown away)
Ran `bt route --nets "*"` over everything that was left (65 nets, F.Cu/B.Cu, all three passes). Result after ~37 min: 27 nets done, 38 given up – the picture shows that state.
Why it was thrown away:
- the shove/rip passes had moved my hand-routed pairs (DSI_D1- and two CSI legs came back with extra vias and a bottom-layer detour) – I had not passed `--fixed`;
- the router's supply links ran diagonally across the bottom layer under the P4 (VDD_FLASH corner to corner) and a 3.3V_P trunk ran right along the west pad column, so the in-ring vias had no way out;
- the USB serial pair I had put on B.Cu was itself a wall from the P4 to J2 that every north-bound signal had to cross.
Restored the snapshot taken before the batch and changed the plan (see 006).
