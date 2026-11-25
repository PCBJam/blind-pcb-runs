# Macropad, 2-layer JLCPCB board: placement, routing, decisions, open items

Board: `/work/macropad-top.kicad_pcb` (KiCad 10). Checks at the end of the work:
- `bt check`: CHECK OK, 0 DRC errors, 2 warnings, 0 unconnected, 0 nets in pieces.
- KiCad's own DRC (`kicad-cli pcb drc`): 0 errors, 2 warnings, 0 unconnected, 0 schematic-parity issues.
- `bt same` against the original: no locked footprint moved; no footprint added or removed; no pad net changed.

The two warnings: `lib_footprint_mismatch` on the RP2040 (the footprint definition in the board differs from the library copy; I did not touch footprint definitions) and `silk_over_copper` inside that same footprint (its silk polygon touches the pad of C112). Both are inside the locked-definition footprint, so I left them.

## Board and outline

- All 42 unlocked parts are on B.Cu, including the USB-C connector J101. The 12 locked parts (SW201..SW701, D201..D701) were not touched.
- The key area is unchanged: x 117..176.15, y 100..138.1.
- The left block is redrawn: x 89.55..117, y 97.35..133 (rounded corners, radius 1). Its top and left edges come from `bt outline --fit`. Its bottom edge sits at y = 133 so the USB-C front face (about y 132.5) is on the board edge.
- **The board is not smaller than the original.** Outline area is about 3230 mm2 (block about 27.5 x 35.7 mm plus the key area), against about 3070 mm2 for the original outline (its bottom-left notch removed about 313 mm2). The reason: the USB-C moved to the bottom edge, which made the block taller. A narrower block would need a different placement; I did not attempt one.

## Placement approach

- **RP2040 U103** at (109.8, 108.8), rotation 0, B side. On this side the key pins 31..37 face east toward the switches, the QSPI and USB pins face south, the crystal pins face north, and the LED data pins face west. The orientation was chosen so the keys leave toward the switch matrix.
- **USB-C J101** on the bottom edge: rotation 180, mouth facing down, pads at about y 125. The USB pins are directly above it, so D+/D- run straight down.
- **USB protection and power entry** between the MCU and the connector: ESD clamp U102, series resistors R103/R104 (27 ohm), fuse F101, CC pull-downs R101/R102 (moved to the south-west corner so the key corridor stayed open).
- **Flash U104** south-west of the MCU; **BOOTSEL SW101** beside the flash's CS pin.
- **Crystal Y101** north of the MCU with C109, C113 and R105 (1 k). It sits rotated so XIN and XOUT come out toward the MCU's north pins.
- **Power:** LDO U101 and bulk C101 at the lower left, C102/C104 around the LDO. Load switch U105 (TPS22917) and level shifter U106 (74AHCT1G125) at the upper left, next to the MCU's LED data and enable pins.
- **Decoupling:** most of the 11 +3V3 and 3 +1V1 caps sit on the MCU's left, top and right-bottom edges, as close as the escape lanes allowed.
- **LED decoupling:** C201..C701 each sit beside its LED on the free side of the key cell.

Net classes (set with `bt rules`, the board minimums unchanged):
- `Power`: +5V, +5V_LED, and the fuse's VBUS side, 0.5 mm.
- `Vdd`: +3V3 and +1V1, 0.3 mm.
- `Default`: everything else, 0.2 mm. Clearance 0.2 mm everywhere; vias 0.6/0.3.

## Routing approach

- **USB D+/D-**: on B.Cu from the series resistors through the ESD clamp to both connector pins of each polarity. D+ takes no vias; D- takes two, because its ESD pin is on the far side. The VBUS pads on the connector's back row are tied together with a short F.Cu bridge.
- **QSPI**: the three east-side nets (SD0, SD3, SCLK) run directly on B.Cu. The three west-side nets (SD1, SD2, SS) use F.Cu through vias, because the flash's west pins sit on the far side of the chip's bottom-left corner.
- **Keys**: the six key nets are the hardest part of the board. The MCU's key pins are at 0.4 mm pitch and the top keys' pins are on the opposite side of the pin row from the bottom keys', so greedy routing from the pads boxed the neighbours in. What worked: `bt escape` on the six pins (stubs and vias staggered in two rows, three vias inside the RP2040 body and three just outside it), then all six routed together from those vias with `--order escapes-first --prefer F.Cu`.
- **LED chain**: the five DOUT-to-DIN links route on B.Cu, 14 to 20 mm each. LED_DIN is 34 mm (F.Cu and B.Cu, two vias).
- **+5V_LED**: 15 links, all on B.Cu at 0.5 mm, no vias.
- **+1V1 and +3V3**: routed with escape vias for the pins that were boxed in (bottom pins 45 and 50 and top pin 22). Pin 33 connects through two vias.
- **GND**: a F.Cu pour over the whole outline, filled with `bt fill`. Each GND pad has a via into the pour (about 60 of the 92 vias in the board). The RP2040's exposed pad has three thermal vias. There is no B.Cu pour.

Board numbers: 437 track segments (265 at 0.2 mm, 85 at 0.5 mm, 70 at 0.3 mm, 17 at 0.127 mm), 92 vias.

## Decisions that a reviewer should look at

1. **Switch cutouts are not in Edge.Cuts.** The MX-style footprints carry only Dwgs.User corner marks for the 14 mm switch hole, and the reverse-mount LED footprints sit inside that square. I did not add cutouts, because the key area was supposed to stay as delivered. If the switches need a 14 mm hole in this board, it has to be added, and the LED pads would need to be checked against it. **Please confirm before ordering.**
2. **Board size** is slightly larger than the original (see above).
3. **Some decoupling is not tight.** C110 (flash VCC) is 1.8 mm from its pin; C114 (USB supply, pin 48) is 2.3 mm; C116 (VREG output, pin 45) is 5.1 mm; C118 (pin 26) is 4.5 mm. Two are not good: **C117 (+1V1, pin 50) is about 12.6 mm from its pin**, and **C120 (+5V_LED bulk) is about 9.7 mm from the load switch output**. The RP2040's bottom edge had no room for closer caps once the USB, QSPI and +1V1/+3V3 escapes were in place.
4. **USB impedance is not controlled.** D+/D- are 0.2 mm tracks on B.Cu with the F.Cu pour as their reference, on a 1.6 mm two-layer stack. That gives roughly 140 ohm single-ended and a differential impedance well above 90 ohm; a true 90 ohm pair needs about 1 mm tracks on this stack. USB full-speed tolerates this over short runs, but it is not a controlled pair. D+ is 10.3 mm and D- is 13.5 mm and they are not length-matched.
5. **QSPI**: SS is 19.8 mm (BOOTSEL sits at the left, away from the flash), SD1 is 12.6 mm, SD2 is 13.2 mm. The short east-side nets are 3.4 to 5.7 mm. Lengths are not matched. Boot-flash at the default clock should be fine, but this is the first thing I would tune on a real board.
6. **Narrow necks**: 17 segments run at 0.127 mm, the fab minimum, where a pin or via is boxed in. Most are at RP2040 pins and the ESD clamp's VBUS pin (which draws only leakage).
7. **GND**: F.Cu pour only, no B.Cu pour, no stitching fence beyond the per-pad vias. A return path beyond the pour is only as good as those vias.
8. **Power integrity of the LED rail**: +5V_LED is 0.5 mm copper (about 150 mm in total) through the key corridor. It should be fine for six LEDs at moderate brightness, but I did not calculate the voltage drop.

## Schematic observations (not changed; for whoever owns the schematic)

- RUN (RP2040 pin 26) is tied directly to +3V3, so there is no reset button.
- SWCLK and SWDIO (pins 24 and 25) are not brought out, so there are no debug or test points.
- C101 is a 5 x 5.4 mm electrolytic footprint. I left it.

## Not finished / not good

- The switch-cutout question above is open.
- Decoupling C117 and C120 are poorly placed, and C118/C116/C110 are not tight.
- USB and QSPI lengths are not matched and the USB impedance is not controlled.
- The board is not smaller than the original outline.
- The two DRC warnings are footprint-library and silkscreen issues inside a locked-definition footprint.
- I did not run a fab-specific check (JLCPCB's own DFM) — only KiCad DRC and bt's checks.
