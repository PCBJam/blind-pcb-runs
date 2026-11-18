# Routing notes – RaspberryPiNVMeNAS (CM4 carrier, ASM1184 PCIe switch, 4× M.2, RP2040)

State: every net is routed. KiCad 10 DRC shows no clearance, short or copper-connection errors.
What DRC still lists is at the end of this file. No footprint was moved (`bt same` confirms; pad nets unchanged).

## What I changed besides copper
- **Stackup** (board file): was three equal 0.48 mm dielectrics. Now 0.21 mm prepreg / 1.065 mm core / 0.21 mm prepreg
  (the usual 1.6 mm 4-layer build). Reason: outer signal layers sit 0.21 mm above their planes, which is what makes
  ~90 Ω pairs possible at a sane width and keeps return loops small. **Order the board with this stackup.**
- **Net classes** (.kicad_pro): Default 0.2 mm / 0.15 clearance; `HS_DIFF` (PCIe, USB) 0.2 mm track, 0.155 mm gap;
  `ETH` 0.16 / 0.2; `Power` 0.5 mm. Board minimums untouched except `min_resolved_spokes` 2 → 1
  (three ground through-pads can only get one thermal spoke; they are also tied solidly elsewhere).
- GND zones: solid connection for SMD pads, thermal relief for through-hole pads; 0.3 mm pour clearance on F/B so the pour does not load the pairs.

## Layer use
| Layer | Use |
|---|---|
| F.Cu | parts, all pair escapes, USB, Ethernet, power pours (12 V bus, buck outputs), slow buses, GND fill |
| In1.Cu | **solid GND**, no splits. Reference for everything on F.Cu |
| In2.Cu | GND, with three islands: +5 V (buck U1 → CM4 pins and fan M4), +12 V patch (feeds the 1V2 and 3.3VA bucks), +1V2 (neck from buck, square under the ASM1184) |
| B.Cu | long PCIe trunks, hops under the F.Cu power buses, a few slow nets, GND fill |

The In2 islands were placed where **no B.Cu high-speed pair runs**, so every B.Cu pair sees ground on In2 for its whole length.
I checked this by construction (island edges vs. lane coordinates), not with a tool.

## PCIe (the part that drove the floorplan)
- Geometry 0.2 mm / 0.155 mm gap over 0.21 mm prepreg. My estimate is roughly 90 Ω; **not field-solved** – have the fab confirm or adjust.
- Upstream (CM4 ↔ switch): REFCLK and TX stay on F.Cu with no vias. RX has to cross the other two, so it runs on B.Cu (2 vias per line).
- Each M.2 port: pairs leave the QFN on F.Cu, drop to B.Cu, run as a three-pair trunk (pair-to-pair gap ≈ 0.95 mm) that passes
  3.3 mm east of the mounting holes, and come back up between the two pad rows of the socket. 2 vias per line.
  REFCLK drops right at the switch pins (in-line staggered vias) so RX/TX can cross it on the other layer – no pair crosses another on the same layer.
- **Polarity twist**: for RX and TX the P/N order at the ASM1184 pins is mirrored relative to the M.2 pins. I did not swap nets;
  the twist is done with two in-line vias at the socket. It un-couples the pair for about 2 mm.
- Lengths 60–110 mm (port 4 is the long one). Intra-pair skew, not tuned: ≤ 0.1 mm on REFCLK 1–3, up to 1.3 mm on some data pairs
  (upstream RX 1.3, port 3 RX/TX 1.2, port 4 REFCLK 1.2). Fine for Gen 2 (CM4 limit); I would add small compensation bumps before calling it Gen 3 ready.
- AC caps are where they were placed; GND vias at every M.2 ground pin, 22 extra return vias next to pair layer changes, 9 vias in the switch EP.

## Power
- +12 V: jack → TVS → eFuse on F.Cu pours, then a 2.5 mm F.Cu bus (y 82–84.4) with a finger up to each M.2 buck's input capacitors.
  The 1V2 / 3.3VA bucks sit behind the mounting holes, so they are fed through the In2 patch (4 vias in, 2 out each).
- M.2 3.3 V: one pour per socket from inductor/output caps to the pins at both ends of the socket.
  Weak point: the pins at the far (key) end are fed through a ~1.2–3 mm strip below the socket; fine for one SSD (≈2.5 A) but it is the hottest copper on the board.
- +5 V: pour at U1, In2 island to the CM4 (3 vias at the pins) and fan M4; a 0.8 mm F.Cu track along y = 88.3 to fans M1–M3 and the standby LDO (≈70 mΩ, fans only).
- ASM1184: every 1V2 pin has a via inside the pin ring into the In2 island plus a direct track to its capacitor; 3.3VA pins go to a B.Cu ring under the chip fed by a 0.8 mm trace.
- Bucks: SW node kept to a 0.3 mm stub pin → inductor; GND pin has its own via under the IC; cap ground pads have vias to In1. Feedback traces go around the outside, away from SW.
  The fixed placement puts input-cap ground and IC ground on opposite sides of the IC, so the hot loop closes through In1 – acceptable, not ideal.

## Slow signals
- Between the 12 V bus and the 5 V track there is a 6-lane strip on F.Cu (M.2 enable, fan-4 PWM/tach, three NTC lines). They cross the buses with short B.Cu hops.
- RP2040 ↔ CM4 (RUN, RST, BOOT, EN, UART): 6-lane bus on F.Cu along the bottom edge.
- SD card: CLK/CMD/DAT0–2 on F.Cu between the CM4 connector columns, in socket pad order; DAT3 on B.Cu. No length matching (spread ≈ 10 mm, fine at 50 MHz).
- M.2 PERST#: B.Cu bus along the top edge, one drop per socket. LED supply: long loop round the east and north/west edges.
- USB2 and Ethernet: F.Cu only. Ethernet P/N differ by 1.6–3.2 mm because the magjack pins are staggered.

## Not finished / not good – please read
1. **One open link**: the left and right pairs of USB-C (J7) shield pads are not joined in copper (the shell joins them). In the netlist these shield nets are `unconnected-…`, i.e. not grounded; I left that as designed.
2. **RP2040 area is the least clean part.** The four NTC lines and the UART resistor links were placed by the autorouter after hand attempts failed; they run on B.Cu under the chip with up to 3 vias each. Electrically fine (DC/slow), not pretty.
3. Fan-3 tach and PWM 2/3 run on B.Cu 1.1–2.4 mm from the port-4 REFCLK trunk for ~15 mm. 25 kHz PWM edges; I expect no problem but it is the first place I would look if port 4 misbehaves.
4. Via-in-pad on C7 pad 2 (0402, 0.2 mm drill) – the only way to ground it without re-routing; may wick a little solder.
5. Two 0.41/0.2 mm vias and many 0.45/0.2 mm vias: within the board rules, but check your fab's minimum annular ring.
6. The LED-supply loop runs 0.2 mm from the fan-header pads and ~0.6 mm from the board edge on the east side.
7. Pair impedance, plane resonance and thermal behaviour were not simulated. No teardrops. Silkscreen untouched.
8. Schematic parity: KiCad reports 215 net-name mismatches (e.g. `Net-(C9-Pad2)` vs `Net-(U1-SW)`); they were there before routing and I did not touch them.

## DRC at hand-over (KiCad 10.0.8)
- 0 clearance / short / track errors, 1 unconnected item (point 1).
- Unchanged from the unrouted board: footprint_type_mismatch ×17, silk_edge_clearance ×6, lib_footprint_mismatch ×196, lib_footprint_issues ×24, text_height ×199.

Progress pictures are in `progress/`; my opinion of the `bt` tools is in `BT-REVIEW.md`.
