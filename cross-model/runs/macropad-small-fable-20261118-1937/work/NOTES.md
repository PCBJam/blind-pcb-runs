# 6-key macropad – placement and routing notes

Result: `macropad-top.kicad_pcb`, 2 layers, 67.15 × 38.1 mm rectangle (R1 corners).
KiCad 10 DRC (with courtyards and schematic parity): **0 errors, 0 unconnected, 0 parity issues,
3 warnings** (see "Known issues"). Locked switches/LEDs untouched; all 42 placed parts are on B.Cu.
The step-by-step picture log is in `progress/`.

## Board outline

- The old L-shaped controller block (30 × 27 mm left of the keys) is gone. The board is now a plain
  rectangle: the key area plus a strip 10 mm wide to its left (left edge moved from x = 87 to
  x = 109). Bounding box 89.15 → 67.15 mm wide, area about 3070 → 2560 mm².
- I did not go narrower. The strip is set by the USB-C receptacle (7.9 mm deep behind the edge)
  plus the RP2040's west side, which needs its decoupling, the USB series resistors and the QSPI
  fan-out next to it. An earlier attempt at x = 110 left no room for the west column.
- A rectangle rather than a tab or an L: same bounding box (same price), stiffer, easier to case.

## Floorplan (everything on the back)

- **USB-C (J101)** on the left edge near the bottom, opening to the left. The top edge was my first
  choice (cable leaves at the rear), but the connector then sits exactly where the MCU's USB/flash
  side needs its parts, and every pin order came out crossed. On the left edge the RP2040 side with
  USB_DP/DM faces the connector and the QSPI pins face the flash.
- **RP2040 (U103)** in the one pocket big enough for it: left of D201, between the two socket rows.
  Rotated so that pins 43-56 (USB, QSPI, regulator pins) face west, GPIO6/7 north, crystal east,
  key GPIOs south.
- **Flash (U104)** directly above the MCU's west side. Turned so SS/SD1/SD2 go straight into pins
  1-3 and SD0/SCLK/SD3 wrap round the end of the package: all six QSPI lines on one layer, no vias
  (5-24 mm).
- **USB path**: connector → ESD (U102, flow-through, directly above the pads) → 27 Ω (R103/R104)
  → pins 46/47. All on B.Cu over ground except one 2.7 mm front-layer hop that joins the two D−
  pads of the connector. D+ and D− are 31.0 / 31.1 mm long in total.
- **Power entry** right at the connector: VBUS → fuse F101 → LDO U101 with C102/C104 within 3 mm.
- **Crystal** (Y101, R105, C109, C113) in the strip between the key rows just east of the MCU;
  XOUT 6.5 mm, XIN 13.6 mm including its branch to C109, both on B.Cu; no front-layer trace runs under the crystal parts.
- **LED power**: load switch U105 with C119/C120 between D501 and D601, bulk cap C101 between D601
  and D701 on the same +5V trunk. Level shifter U106 with C121 right at GPIO6 north of the MCU,
  10 mm of trace from D201's data input. One 100 nF beside every LED's supply pad.
- **BOOTSEL (SW101)** between D201 and D301 (the only free 8.5 × 6 mm spot near the MCU).

## Decoupling

- Each capacitor sits at the pin it serves with a ground via beside it: C105 at pins 48/49,
  C112 (1 µF) + C108 at 42/43/44, C116 (1 µF) at VREG_VOUT 45, C103 + C111 at pin 1, C106 at pin 22,
  C115 + C117 at DVDD 23, C107 at pin 33, C114/C110/C118 at the flash.
- Under the QFN, on B.Cu between the pad rows and the exposed pad, three short links join pins of
  the same rail: +1V1 45-50-23, +3V3 1-10-22 and +3V3 44-43-42-33-26. That is why pins 10, 26 and 50
  have no capacitor of their own outside the package (see "Known issues").
- 5 ground vias in the exposed pad.

## Layers and routing

- **B.Cu**: components and nearly all signals. **F.Cu**: ground plane, plus only what had to cross
  something on the back: KEY1/2/3, the 0.4 mm +3V3 trunk from the LDO to the MCU capacitors, +5V
  to U102's VBUS pin, the VBUS pad link under the connector, LED_EN, the BOOTSEL line, +5V_LED to
  U106. GND is poured on both layers, 118 vias in total (48 of them stitching).
- Widths: +5V trunk 0.5 mm, VBUS/+5V_LED 0.4 mm, +3V3 trunk 0.4 mm, signals 0.2 mm, 0.15 mm only
  in the fan-out of the 0.4 mm-pitch QFN and for XIN/XOUT past the D201 window. Clearance 0.2 mm,
  all vias 0.6/0.3 mm – inside JLCPCB's standard 2-layer limits without extra-cost options.
- A `Power` net class (0.4 mm) was added for +5V, +5V_LED and VBUS; no other rule changes.
- **+5V_LED** is one loop: from U105 east above the bottom LEDs, up the right edge, back west under
  the top LEDs. That way it never crosses a key trace. LED data follows the chain order on B.Cu.
- **Keys**: KEY4 straight to its socket, KEY5/KEY6 on B.Cu under the SW501 socket, KEY1-3 on the
  front (KEY3 changes layer twice more to pass the LED bus; it is a static signal).

## Known issues / not ideal

- **BOOTSEL trace is long**: QSPI_SS runs 47 mm on F.Cu along the top edge to SW101 – an
  unterminated stub on the flash chip-select. The short way is blocked on both layers (KEY1 on the
  front, QSPI/USB on the back). Chip-select is not a clock, so I expect no trouble, but it is the
  net I would test first on a prototype, and a 1 kΩ in series at the flash end (schematic change)
  would remove the concern.
- **LED_EN is 63 mm on F.Cu** round the top edge and its vertical run cuts the front ground plane
  between x = 139 and 140 over 31 mm; the plane is joined round both ends and through the back pour
  and stitching vias. Static signal, so only the plane cut matters.
- **Pins 10, 26 (RUN) and 50** rely on the under-chip links (2-4 mm) to reach a capacitor; pin 33's
  capacitor is 2 mm away because the key fan-out needs the space directly below it.
- **U105 is 80 mm of 0.4 mm trace away from D201** (the far end of the LED loop): about 0.1 Ω,
  roughly 10-25 mV at full white. Fine for six LEDs.
- **Two cosmetic silkscreen warnings** (new): the pin-1 marks of U103 and U104 come within 0.1 mm
  of C103's pad/silk. The third warning (QFN-56 footprint differs from the library copy) was
  already in the original board.
- Reference designators are hidden in the supplied footprints and I left them so; there is no
  assembly silk.
- GND pours connect SMD pads solid (no thermal reliefs), including the hot-swap socket pads; those
  need a hot iron if hand-soldered.
- C101 is 5.4 mm tall and sits under the keys with the other back-side parts (USB-C is 3.3 mm):
  the case needs that clearance under the board.
- Not done: length tuning or impedance control for USB (full-speed only, 31 mm, not needed on
  this stack-up), teardrops, fiducials/tooling holes for assembly, test points.
- `.bt-undo/` in the project folder holds the tool's backup of the original `.kicad_pro` (before
  the Power class was added); it can be deleted.
