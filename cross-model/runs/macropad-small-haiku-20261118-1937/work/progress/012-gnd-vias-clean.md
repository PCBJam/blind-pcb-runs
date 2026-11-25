# 012 GND vias, dangling vias removed: DRC clean

- GND: 52 of 56 pads routed into the F.Cu pour by `bt route --net GND --all` (one via each). The rest by hand: the top GND pin of the RP2040 (U103.19, via at 108.8,106.2 with a stub), C112's GND pin (0.45 mm via with a stub), the ESD clamp's GND pin (0.45 mm via beside it, the same-net pad touching it), and three thermal vias inside the RP2040's exposed pad. The connector GND pads already had a via spot.
- USB D- re-routed with a keep-out box so the ESD GND pin keeps room for its via.
- The pour was refilled (`bt fill`) after the D- change: an old fill had left two clearance errors.
- Removed three escape vias whose F side was never used (KEY1, KEY5, KEY6 escapes) and one dead KEY6 stub. No net came apart (`bt rm --dry` said so first).

DRC now: 0 errors, 2 warnings (the RP2040 footprint-library mismatch, which I leave alone, and a silkscreen clip inside that footprint). Unconnected: 0.
