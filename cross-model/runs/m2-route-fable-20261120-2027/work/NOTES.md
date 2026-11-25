# M.2 (key M) → PCIe x4 adapter: routing notes

State: routed, poured, ready to order. KiCad 10 DRC at all severities: 0 errors, 0 unconnected,
schematic parity clean. The only messages left are 20 "footprint library 'antmicro-footprints' not
configured" warnings that the unrouted board already had. No footprint was moved.
362 track segments, 189 vias, 21 zones (5 of them no-fill rule areas).

## The problem this board poses

The nine differential pairs (4× PER, 4× PET, REFCLK) leave the M.2 fingers (J2, all on B.Cu) in
the opposite order to the one they arrive in at the PCIe socket (J1), and P/N inside every pair is
reversed as well. No route on one layer exists. So every pair has to change layer once in a way
that also swaps P and N, and the pairs that end on J1's B.Cu side (PER lanes, REFCLK) have to come
back to B.Cu.

## Layer use

| Layer | Use |
|---|---|
| F.Cu | pairs, J1 side (vertical lanes); +3V3 pour; +12V pour; +5V track; GND fill elsewhere |
| In1.Cu | solid GND, never split: reference for the F.Cu pairs |
| In2.Cu | GND under everything the B.Cu pairs cross; +3V3 island (x 136–144) and +12V island on the right |
| B.Cu | pairs, J2 side (horizontal bundle); slow signals; decoupling; GND fill |

The stackup in the file (0.876 mm, 0.12 mm prepreg outer-to-inner) and the existing Z85_PCIE class
(0.185 mm / 0.145 mm gap) only give 85 Ω on the outer layers against the adjacent plane, so pairs
are on F.Cu/B.Cu only and both inner layers are planes. A side effect I wanted: every pair via
runs the full F↔B height, so there are no via stubs.

## Differential pairs

- Shape: B.Cu out of the fingers, a common 45° run (the bundle stays parallel), horizontal to the
  corner; a mirrored via pair at the corner (N via up-left, P via down-right on the 45° axis)
  turns the pair 90° and swaps P/N symmetrically; then straight down on F.Cu at 2 mm lane pitch.
  PET lanes end on J1's F.Cu pads. PER lanes and REFCLK drop to B.Cu through a second via pair
  1.7 mm above their pads.
- Every crossing is a B.Cu pair under an F.Cu pair at 90° with both ground planes between them.
- Intra-pair skew is 0.000 mm on all nine pairs, by construction (`bt length`). Lane lengths are
  34.7–40.1 mm; lane-to-lane matching is not needed for PCIe and I did not add any.
- Vias: 0.5/0.25 mm on the pairs (smaller barrel and pad than the 0.6/0.3 default, less
  capacitance). I changed the Z85_PCIE class via to 0.5/0.25 in the .kicad_pro to match; this is
  the only edit to the project file. It is inside the board minimums but adds a second drill size.
- Return path: two GND vias at every corner via pair (one for REFCLK), a GND via at the end of
  every J2 ground finger between the pairs, a GND via between J1's ground pads on either side of
  every pair, and GND vias every 2–3 mm between the F.Cu lanes.
- REFCLK's F.Cu lane is 1 mm right of its pads, so it keeps the 2 mm lane pitch to PET0 instead
  of running 0.5 mm beside it; it steps back on B.Cu just above the pads.
- The F.Cu and B.Cu ground fills use 0.5 mm clearance. On B.Cu that deliberately leaves no fill
  between the pairs: a strip there would be a long guard trace grounded only at its ends.
- Plane cut-outs under the connector pads (rule areas, named in the board): In1 under J1's PET
  pads, In2 under J1's PER pads, In2 under the J2 finger row. A 0.7 × 4.2 mm pad 0.12 mm above a
  plane is close to 1 pF; with the cut-out it sees the far plane. REFCLK's pads are not cut out
  (100 MHz, and CLK− sits back-to-back with a PET0 pad that needs In2 there).

## Power and slow signals

- +3V3 (up to 3 A from the M.2 host): F.Cu pour from the fingers, across the top of the board
  above the pair corners (5 mm at the narrowest), down to J1 between x 136 and 144, where the In2
  island and a B.Cu pour at the caps join it through 12 vias. Each +3V3 finger has its own stub;
  the bars that join them are past the pad ends, under solder mask.
- +12V (J3/J4 → J1): pour on F.Cu and In2 along the lower half of the right block and down the
  leg to J1, plus a B.Cu pour at C1/C2 and the J1 pads; 28 vias. Kept 2.3 mm clear of the
  mounting-screw land at the right edge, which is GND on both sides.
- +5V only links J5 to J3 pin 4: 1 mm track.
- Decoupling caps each have a GND via within about 1 mm and sit in local pours.
- PERST# and WAKE# leave J2 on F.Cu, drop to B.Cu below REFCLK, and cross under all the F.Cu
  lanes to R4/R3. CLKREQ# goes straight to R2.

## Things that are not ideal

- The 85 Ω geometry is taken from the project's net class, not from a field solver. Order the
  board as controlled impedance and let the fab confirm 0.185/0.145 on their 0.12 mm prepreg.
  The pad cut-outs are engineering judgement, not simulated.
- PER lanes and REFCLK have two via pairs each; PET lanes have one. The pinout forces this.
- On the 45° run the gap between neighbouring pairs is 0.545 mm (about 3× the track width) for
  6.4 mm; elsewhere it is 0.985 mm or more.
- J2 ground finger 51 has its via 3.3 mm from the pad end instead of right at it, because the
  PERST#/CLKREQ#/WAKE# fingers on the other side need that space. REFCLK has one corner return
  via instead of two, to leave room for WAKE# and PERST#.
- WAKE# runs 0.52 mm beside REFCLK+ on B.Cu for about 20 mm. Both slow nets are static in use.
- The +3V3 run is mostly a single F.Cu pour (18 µm base copper); In2 only parallels the last
  18 mm. Estimated 5–10 mΩ end to end, 15–30 mV at 3 A. The pour is perforated by GND vias.
- J3's through-hole pins connect to the pours through thermal spokes on every layer (easy to
  solder; fine for a few amps, not for a 75 W card on 12 V).
- Silkscreen, mask and paste are untouched. No teardrops, no test points. All vias are tented,
  as the board setup had it.

## Rebuilding

`scripts/build.sh scripts/m2-pcie-adapter.unrouted.kicad_pcb` regenerates the whole board:
`gen_pairs.py` (pairs), `gen_misc.py` (GND vias, slow signals, +3V3 fingers), `gen_power.py`,
`stitch.json`, the zones, `add_voids.py` (rule areas), then a fill. `progress/` has the pictures.
