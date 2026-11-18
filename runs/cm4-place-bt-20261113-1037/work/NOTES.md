# RaspberryPiNVMeNAS – placement and routing notes

State of `/work/RaspberryPiNVMeNAS.kicad_pcb`: all 170 loose parts placed, every net routed, zones filled.

Checks run on the final file:
- KiCad 10 DRC (`kicad-cli pcb drc --schematic-parity`): **0 unconnected items, no clearance / short / hole / edge
  errors**. What it still lists was all there in the untouched input: 17 `footprint_type_mismatch` (locked connectors),
  215 schematic-parity items (the schematic names nets differently from the board file, e.g. `Net-(U3-CT)` vs
  `Net-(C6-Pad1)`; same count before I started - I did not touch pad nets), library-mismatch and text-height warnings.
- Courtyard overlaps: the project has that rule set to *ignore*; checked on a scratch copy with it on: none.
- `bt same`: no locked footprint moved, none added/removed, pad nets unchanged.
- Warnings left: 34 silkscreen text-height warnings (0.5 mm reference text of the library footprints), two
  dangling track ends of 0.06 mm and 0.42 mm at the RP2040 (leftovers of removed vias; harmless).

Not checked by anything here: impedance (no field solver), thermal behaviour, and the assumption about SSD clearance below.

## Rules I changed (and why)
- **Stack-up** was KiCad's default 3 x 0.48 mm. Set to a normal 1.6 mm 4-layer build (0.21 mm 7628 prepreg /
  1.065 mm core / 0.21 mm prepreg, 1 oz outer, 0.5 oz inner; JLC04161H-7628 style). The differential pairs are sized for
  this; with the old numbers they would be ~130 Ω. **Order the board with this stack-up or re-size the pairs.**
- Net classes: Default 0.2 mm / 0.15 mm clearance; `PCIe` and `USB` 0.2 mm track / 0.15 mm gap (~90 Ω by formula, not
  solver-checked), `ETH` 0.18 / 0.2 (~100 Ω), `Power` 0.4 mm. Slow signals at the 0.4 mm-pitch parts use 0.13–0.15 mm.
- Board minimums: via 0.45/0.2, hole clearance 0.15 (the USB-C footprints already have 0.165 mm inside them),
  copper-to-edge 0.3, `min_resolved_spokes` 1 (single-spoke thermals on fine-pitch ground pins that also have their own via).

## Layer use
- **F.Cu**: parts, all differential pairs (PCIe, Ethernet, USB), short local routing, ground pour.
- **In1**: solid ground, never cut. Reference for everything on top.
- **In2**: ground with power islands: 12 V trunk along the socket row, one 3.3 V island per M.2 socket, 1.2 V
  under the switch, 5 V from the buck to the CM4 pins and as a strip to the fans/LDO, small 3.3 VA and RP2040-core islands.
- **B.Cu**: bucks and decoupling, 12 V trunk pour (stitched to In2), long slow signals, ground pour.

## Placement
- **ASM1184 (U12)** on top between the sockets at (169.5, 80.5), rotated 180°. With that rotation the order of the
  ports round the chip equals the order of the sockets (J4, J3, J2, J5) and the upstream port faces the CM4, so no
  port has to cross another. Its 18 decoupling caps are on the bottom inside the pad ring, each on a via next to its pin.
- **M.2 3.3 V bucks** (U10/11/13/14) on the bottom directly under their socket; output goes straight up through vias
  into that socket's In2 island and to the 9 supply pins. Inductors are 2 mm tall, so they cannot sit under an SSD.
- **Switch bucks** (U2 1.2 V, U15 3.3 VA) on the bottom west of U12, placed so none of their vias hits a pair on top.
- **Input**: TVS (IC1) at the jack pin, hot-swap (U3) next to it, status LEDs D1/D2 beside it; 5 V buck (U1) right
  below, in the only top-side area not covered by a module.
- **RP2040** on top near its USB-C (J15), both buttons and the three fan headers; flash and crystal against the chip,
  decoupling under it.
- **Ethernet ESD** arrays in line between the RJ45 and the CM4 (flow-through), USB choke at J7.
- **LEDs**: one activity LED per SSD at the SSD's free end on the bottom board edge, the four RP2040 LEDs there too;
  CM4 LEDs in a column on the left edge. TMP117 at the left edge next to the QWIIC connector, away from the heat.
- Assumption: parts on top under the SSDs are ≤ 1.25 mm (QFNs, 0402/0603/0805). That fits under an SSD only with
  the tall (4.2 mm) variant of the M.2 socket, which is what I believe 1-2199230-6 is. **Please verify the socket
  height**; if it is a low one, U12, the RP2040 block and the passives under the drives need to move to the bottom.

## PCIe (the part I spent most thought on)
- All 15 pairs are on the top layer over In1. Pin orders (switch, M.2, CM4) make it impossible to route RX, TX
  and REFCLK of a port on one layer; the pair that has the AC-coupling caps anyway (switch TX of each port, and the
  switch-to-CM4 direction upstream) dips to the bottom for ~4 mm right at the switch, through its 0402 caps,
  and comes back up on the other side of its neighbour. In2 is ground under each hop. Everything else has no via.
- At a socket, RX/TX go through the M-key gap of both pad rows and turn back onto the pads from the board-edge
  side (this also gives the right P/N order); REFCLK comes in between the pad rows from the gap between sockets.
  The ground pins between the pairs (45, 51) have their own via to In1.
- The U-turn makes one track of each pair 0.9–2.9 mm longer; compensated with one bump on the short track between
  the pad rows. Intra-pair skew of all data pairs < 0.01 mm (bt length). REFCLK pairs: 0.27 / 0.27 / 0.31 /
  **1.43 mm (port 4, not compensated)**, fine for a 100 MHz clock but not tidy.
- Lengths: 28–52 mm for ports 1–3, **100/106 mm for port 4 (J5)**, 69–73 mm upstream. Port 4 has to go round two
  mounting holes; no problem for Gen 2, but it is the long one.
- The four M.2 3.3 V rails, 1.2 V and 12 V never run under a pair on the adjacent layer.

## Power
- 12 V: jack → TVS → hot-swap on a top pour, then vias into a trunk on In2 + B.Cu along the top edge (3 mm, both
  layers, stitched), feeding the four M.2 bucks directly on the bottom. The trunk has a 2 mm neck beside the jack
  (two layers in parallel there). The two switch bucks get 12 V by a 1 mm bottom track.
- Each buck: input cap straddling VIN/GND with SW leaving between its pads, second input cap beside it, boot cap
  under the IC, output caps after the inductor, feedback taken from the output plane through its own via.
- 5 V: In2 shape from the buck output to the six CM4 5 V pins (three vias) and a 2.7 mm strip across the board to
  the fan headers and the RP2040 LDO.

## Other routing
- Ethernet: four pairs, top layer only, straight through the ESD arrays. Intra-pair mismatch 1.7–3.4 mm, which comes
  from the staggered RJ45 pins; not compensated (fine for 1000BASE-T).
- USB2 host: top layer, no via, 57 mm, skew 0.6 mm.
- SD: top layer between the two pad columns of the CM4 connector; DAT3 has a short bottom hop, DAT2 goes round
  the socket (not length-matched, 25 MHz/50 MHz is tolerant).
- Slow nets (GPIO, LEDs, enables, fans, thermistors): fan PWM/tacho 1–3 hand-routed on top; the rest autorouted
  with `bt route`, mostly on the bottom.

## Known weak points / not finished
1. **Autorouted slow nets are not pretty.** About a dozen cross-board nets (CM4_RUN/BOOT/RST, PICO_UART_TX/RX,
   PICO_PWM4/Tacho4, TSENSE_0, PCIESWPWR_EN, PCIe_RST) change layer 8–12 times. Electrically harmless, but I would
   re-route them by hand as a bus before calling this a finished product. They also cut the bottom ground pour into
   more pieces than I like (it is stitched, and In1 is solid).
2. Thermistor inputs (TSENSE_x, RP2040 ADC) run long distances on the bottom next to digital nets; add filtering in
   firmware or re-route if the readings are noisy.
3. A few ground vias sit in or at the edge of pads (R25, R27, crystal ground pad, some decoupling caps under U12/U18):
   acceptable for reflow with 0.2–0.3 mm drills, better tented or moved.
4. The RP2040 1.1 V core rail is joined by a small In2 island rather than short tracks.
5. Impedances are from formulas for the stack-up above, not from the fab's calculator; ask the fab for controlled
   impedance (90 Ω PCIe/USB, 100 Ω Ethernet) and let them adjust widths.
6. Silkscreen was not touched: reference designators keep their library positions and many overlap pads or each
   other in the dense areas. Needs a pass before ordering assembled boards. No fiducials or tooling holes were added
   (not allowed to add footprints).
7. The shell pads of the two USB-C connectors are their own nets in the netlist (not ground); I joined each
   connector's four shell pads together and left them floating, as the schematic says.
8. REFCLK skew on port 4 (see above); the port-4 lane length.

## How it was built
`scripts/` holds everything: `place.py` (placement), `rules.py` (stack-up, classes), `gen_*.py` (hand-planned
copper as JSON in `copper/`), `zones.py`, `cy.sh` (courtyard check). `scripts/build.sh` replays placement + copper
files in order from the original board; the last clean-up steps (dangling stubs, stitching, fill) were applied on top
and are only in the final board file. `orig/` is the untouched input. `progress/` has the visual log.
