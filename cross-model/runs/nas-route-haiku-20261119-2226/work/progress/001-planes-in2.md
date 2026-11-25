# 001 – layer plan: In1 GND plane, In2 power zones, net classes

**What I did**

- Net classes (via `bt rules`, in the .kicad_pro only):
  - `Default` (signals): 0.15 mm track and clearance, via 0.45/0.2.
  - `PCIe` (30 nets, all PCIe_RX/TX/CLK pairs): 0.35 mm, pair 0.35/0.15 (about 98 ohm on this 0.48 mm stack, eps_r 4.5).
  - `ETH` (8 CM4 pairs): 0.35 mm, pair 0.35/0.15 (100 ohm).
  - `USB` (CM4 USB, USB-C J7 side, RP2040 USB): 0.4 mm, pair 0.4/0.15 (about 93 ohm).
  - `Power_HC` (+12V, +12P, +5V, +3.3V_M1..M4): 0.6 mm, via 0.6/0.3.
  - `Power` (+3V3, +3.3VA, +3.3VSTB, +1V2, +1V8): 0.3 mm, via 0.6/0.3.
- In1.Cu: one solid GND zone over the whole outline. This is the reference for all signal layers.
- In2.Cu: power zones, non-overlapping, one per rail or per region:
  - `+3.3V_M1..M4` directly under each M.2 socket (y 57.2 to 73.6), so the socket power pins drop straight into their own plane.
  - `+12V` band (x 122.5 to 224, y 75.6 to 97.8) over the buck regulators' inputs.
  - `+1V2` under the PCIe switch U12 (x 161 to 186, y 99.5 to 132.5).
  - `+3.3VSTB` for the RP2040 side (x 200.5 to 224, y 109 to 139.5).
  - `+5V` west block (x 84 to 121, y 77 to 135) for the CM4 5 V pins and fan M4.

**Why**

- The stack is signal / GND / power / signal. F.Cu always references In1 GND, which is solid, so the high-speed pairs go on F.Cu where they can.
- B.Cu is the long-run layer. It references In2, so B.Cu routes that cross a zone boundary see a reference change. Keeping the boundaries short and away from the PCIe corridors limits that.
- +3V3 and +1V8 are CM4 outputs with small loads: they stay as traces. +5V is spread across the board, so the west block only feeds the CM4 and fan M4; the rest of +5V will be a B.Cu trunk.

**Result**

- Zones fill (`bt zone` / fill), no overlaps. See the picture: amber = In2.
- Holes with GND pads are cut out of the zones by the clearance rule.

**Next**: escape the big parts (CM4, PCIe switch, M.2 sockets, RP2040), then route the pairs, then the rest.
