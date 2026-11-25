# 002 – PCIe lanes routed (switch U12 to four M.2 sockets, and CM4 uplink)

Picture: `002-lane3-bundle.png` (x 128–190, y 56–130, F.Cu red, B.Cu blue).

**What I did**

- Escape first, in the gap between the M.2 socket's two pin rows (the top row carries PCIe, the bottom row power):
  - Each PCIe pad gets a 0.25 mm stub and a through-via at y 60.0 or 61.6, alternating so neighbouring vias keep 0.6 mm centres. The stubs of the second pad of each pair pass the first via at 0.5 mm, which leaves 0.15 mm. Written as `/tmp/route/m2_pcie_escape.json`, probed clear.
  - CM4 pins: `bt escape` put vias in the gap between the module's two pin columns (x≈126.1) and on the east side (x≈128.3).
- Routes on B.Cu for the long runs (B.Cu has no parts and references In2), F.Cu only where a pair had to cross or the B.Cu was blocked.
- Each pair is routed as two single-ended `bt route` calls, the second beside the first. `bt pair` failed at the pads (0.5 mm pitch leaves no room for a 0.35 mm pair), so it was not used for the escapes.
- Switch-side cap hops (AC coupling, C52–C59, C48, C49) routed first, then the long legs, so the caps' F.Cu hops did not wall in the pins.

**Lane status**

| lane | socket | RX | TX | CLK | notes |
|---|---|---|---|---|---|
| 1 | M1 (J2) | B.Cu, 63–65 mm | cap C52/53 then 67 mm | 63 mm | good |
| 2 | M2 (J3) | 61–64 mm, 2.45 mm neck at U12 | 55–57 mm | 63–66 mm, 4 mm neck at U12 | tight bundle at U12 north |
| 3 | M3 (J4) | 75–79 mm | 69–70 mm, 3 vias | 77 mm / 74 mm | RX pair order had to be swapped at the socket (see below) |
| 4 | M4 (J5) | 84–92 mm | 93–94 mm | 87–88 mm | long, around the RP2040 east side |
| CM4 | – | 53–54 mm | 49–51 mm | 46–49 mm | CLK_N has 3 vias |

**Why the lane-3 escape was swapped**

The switch pins are in the order 41 above 42, but the socket pins run the other way for the route, so a plain pair from the socket would have to cross itself at the switch. I moved the RX_N escape to the west of RX_P at the socket (via at 139.6,61.6 instead of 141.25,61.6). That order matches the switch pins, and the pair then runs without a crossing.

**Known weak points (not finished)**

- Pair coupling is loose near the sockets: the two members leave the vias about 0.5 mm apart, and the router keeps them close on B.Cu, but at U12 the members sometimes split by 1–2 mm.
- Some legs (RX_N_2, CLK_N_2, RX_N_4, CLK_P_2) run on F.Cu for part of the way or carry a neck at the switch pad. The necks are short but not ideal for a PCIe pair.
- Length matching has not been done yet (`bt tune`); skews are 1–9 mm.
- Some PCIe control nets (PCIe_RST, PCIe_RST_M2, PCIe_LED_*, PCIe_CLK_REQ) are not routed yet; they are in the general pass.
