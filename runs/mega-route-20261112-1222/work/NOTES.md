# Arduino Mega 2560 – routing notes

Board: `Arduino_Mega_2560.kicad_pcb` (KiCad 10.0.8), 2 layers, 1.6 mm, intended for JLCPCB standard service.
Placement is untouched (all 66 footprints verified identical to the original: position, rotation, side, pad nets).

## State of the board

- All nets routed: KiCad DRC reports **0 unconnected items** and **0 copper/clearance/hole violations**
  with the rules listed below.
- What DRC still reports are 113 items that were already in the unrouted board and come from the fixed
  placement / footprints, not from routing: `lib_footprint_mismatch` (51), `silk_overlap` (37),
  `courtyards_overlap` (12), `silk_over_copper` (8), `silk_edge_clearance` (5). I did not touch silkscreen
  or footprints.
- 1724 track segments, 342 vias (157 of them ground vias, 185 signal/power). Track length ≈ 3.2 m on top,
  ≈ 1.75 m on the bottom.
- Gerber and drill export with `kicad-cli` runs cleanly (I did not inspect the Gerbers in a viewer).
- There is no GUI here: everything was checked with `kicad-cli pcb drc` and rendered images only.

## Design rules (in `.kicad_pro`, chosen for JLCPCB 2-layer with margin)

| Rule | Value | JLCPCB limit (as I understand it) |
|---|---|---|
| min clearance / min track | 0.15 mm / 0.15 mm | 0.127 mm |
| via | 0.6 mm pad / 0.3 mm drill (power class 0.8 / 0.4) | 0.3 mm drill |
| annular ring | ≥ 0.13 mm (actual 0.15 / 0.2) | 0.13 mm |
| hole to hole | 0.5 mm | 0.5 mm (different nets) |
| hole to copper | 0.25 mm | 0.2–0.25 mm |
| copper to board edge | 0.3 mm | 0.2–0.3 mm |

Net classes:

- `Default` – 0.2 mm track, 0.15 mm clearance.
- `USB` (D+, D-, RD+, RD-) – 0.25 mm.
- `Power` (+5V, +3.3V, AVCC, USBVCC, XVCC, USHIELD, GND) – 0.5 mm nominal.
- `PowerIn` (VCC = VIN after the diode, and the barrel-jack net) – 1.0 mm nominal, 0.25 mm clearance.

Changes to the original rules that are relaxations, so you can judge them:

- `min_resolved_spokes` 2 → 1. One through-hole ground pin (J12 pin 6, ICSP GND) only gets one thermal spoke
  on the bottom because signal tracks pass both sides of it. It also has a top-side connection, so it is
  properly grounded, just not with two spokes on that layer.
- `Arduino_Mega_2560.kicad_dru` (new file) holds one custom rule: the USB-C footprint J1 has its own
  locating-peg holes 0.194 mm from its own ground pads. That is inside the footprint and cannot be fixed by
  routing, so the 0.25 mm hole clearance is relaxed to 0.15 mm **only between items of J1**.
- I added `min_connection` = 0.15 mm (it was 0 = off).

## Approach

1. **Ground**: both layers are poured with GND (zone clearance 0.25 mm, thermal reliefs on through-hole pads,
   solid connection on SMD pads). Before any routing, every SMD ground pad got its own via next to it
   (decoupling caps, regulator, bulk caps with 2–3 larger vias, four vias in the ATmega16U2 thermal pad, the
   ATmega2560 ground pins drop to vias under the package). After routing, the pours were tied together with
   extra vias wherever a piece of pour was not yet connected, plus a loose stitching grid. The ground net is
   one connected group.
2. **Hand-routed (scripted with explicit coordinates) critical parts**
   - USB-C receptacle escape: D+ straight to the series resistor, the two D+ pads joined by a small loop on
     the connector side, the second D- pad joined by one short bottom hop, CC1/CC2 straight to their 5.1 k
     resistors, USB data from the series resistors to the 16U2 as a short parallel pair.
   - VBUS: one side of the connector goes on top to the polyfuse, the other side joins through a bottom link.
   - 16 MHz resonator of the ATmega2560: two short parallel top-layer tracks, no vias.
   - VIN from the protection diode to the VIN header pin (0.8 mm, below the header row) and the
     regulator-input trunk (1.0–1.2 mm).
   - ATmega2560 supply pins: pins 10 and 80 go directly to their 100 nF caps (C8, C7); pins 31 and 61 have no
     nearby cap in the placement and drop to vias under the chip.
3. **Everything else was autorouted** with Freerouting 1.9 run locally (nothing was uploaded anywhere), in
   stages so that the important nets got first choice: critical/power nets near the connectors → top-layer-only
   pass for the buses that can be planar (port A/C/L to the double-row header etc.) → +5 V / +3.3 V with a
   preference for the bottom layer → remaining signals. Power nets were routed narrow and then widened
   segment by segment as far as clearance allows.
4. A few leftovers (RESET2, a handful of nets that had via holes closer than 0.5 mm, ground islands) were
   finished with a small grid router of my own and some manual edits around RN5.
5. Keep-out areas (rule areas) were added around the four fiducials (front copper only), around the six
   mounting holes (r = 2.45 mm, both layers, so an M3 screw head does not sit on tracks) and over the
   "Mega2560" copper text on the back.

## What is not good / not finished

Please read this section before ordering.

- **The signal routing is autorouter quality, not hand quality.** It is electrically complete and rule-clean,
  but it has more vias and detours than a careful manual layout would have: 14 signal nets use 4 or more
  vias (worst: ADC10 with 9, several other ADC lines with 5–7). The analog inputs have to cross from the top
  edge of the MCU to the bottom headers, which is where most of this comes from. For a board I cared about I
  would re-route the ADC lines and the MCU fan-out by hand.
- **The bottom layer is not a solid ground plane.** About 1.75 m of track runs on the bottom and cuts the
  pour into pieces, especially under and to the right of the ATmega2560. Return paths rely on the stitching
  vias and the top pour. Fine for a 16 MHz AVR board, not something I would call good EMC practice.
- **+5 V has narrow stretches.** About 200 mm of the +5 V net is 0.6 mm, but about 60 mm is only 0.25 mm and
  another ~55 mm is 0.3–0.4 mm, where it squeezes between other tracks. I did not trace which loads sit
  behind the narrow parts, so I cannot promise the 5 V header pins can deliver a full shield load without
  noticeable drop. This is the first thing I would improve.
- **USB is not impedance controlled.** 90 Ω differential is not realistic on a 1.6 mm 2-layer stack; the pair
  is short (≈ 10 mm connector to 16U2) and full-speed only, so this is normal practice, but D+ and D- are not
  length matched and one D- connector pad uses two vias.
- **VIN path**: mostly 0.8–1.2 mm, with about 2 mm at 0.3 mm (the tap to the RN5 divider, not in the main
  current path) and the barrel-jack net narrows to 0.6 mm for 1.5 mm at a pad entry.
- The RESET2 pull-up pad of RN5 has its via directly beside the pad (0.14 mm of mask between pad and via).
  Acceptable, but it is tighter than I like for hand soldering.
- No teardrops, no length tuning, no test points added.
- Fiducial FID4 sits under the ATmega2560 in the fixed placement; I only kept copper away from it.
- Not done: review in the KiCad GUI / 3D viewer, Gerber inspection in a viewer, any electrical simulation.
  The design has no schematic, so nets were taken from the board as given; I did not check the circuit
  itself.
