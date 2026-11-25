# 001 – first complete placement (no routing yet, except the FPGA fan-out stubs)

Pictures: `001-placement-top.png` (F.Cu side), `001-placement-bottom.png` (B.Cu side).

What I did
- Read the netlist and both schematic sheets to find which decoupling cap belongs to which IC
  (the netlist alone only says "+3V3 to GND").
- Found that the board already carries its silkscreen: function boxes and labels (STATUS LEDS, USER LEDS,
  LEVEL SHIFTERS A0..B7, ESD PROTECTION, PU/PD A/B, ADC/VREG/DAC A/B, VREG_1V2/3V3, FX2MEM, ICE_MEM,
  RESET, ...), a back-side "wave soldering keepout" drawing around the through-hole connectors and
  back-side test point labels. I used these as the floorplan, so every part lands in its labelled box.
- FX2 next to the USB-C connector (USB pins face the connector), FPGA right of it, rotated so that the
  LVDS balls face J5, port A balls face the level shifters, the FX2 FIFO balls face the FX2.
- Level shifters in the 2 x 8 grid the silk asks for; their two caps each on the back, directly below.
- ESD arrays right at the IDC headers, pull-up arrays between the two pin-socket rows.
- Regulators, DACs, INA233s in the east strip boxes; passives that do not fit there on the back.
- FPGA: dog-bone vias (0.4/0.2) and six 100 nF caps under the BGA, PLL filter caps at the PLL balls.

Result
- All 272 footprints on the board, no pad clearance problems, locked parts untouched (`bt same`).
- Courtyard overlaps left: only the 10k arrays between the DNP pin-socket rows and the ESD arrays next
  to the IDC header courtyards. The silk puts them there; the sockets are DNP.
- Rules changed: class clearance 0.15 -> 0.127, min track 0.15 -> 0.127, hole clearance 0.25 -> 0.2,
  needed to pass one track between two BGA vias (0.8 mm pitch).
