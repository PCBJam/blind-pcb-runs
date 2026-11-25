# 001 – starting point

All 272 footprints placed, no copper at all (0 tracks, 0 vias, 0 zones). 251 nets, 4 layers.
Rules from the project: track >= 0.15, clearance 0.15, via >= 0.4/0.2.

Decisions made before any copper:
- F.Cu: components + signals. In1.Cu: solid GND, no tracks. In2.Cu: power. B.Cu: signals, decoupling, GND pour.
- In2 is +3V3 everywhere except two comb-shaped islands for VIOA / VIOB (teeth under the VCCB pins of the
  level shifters, band past the ESD arrays to J2.2 / J3.2 and the LDO outputs) and a +5V strip along the south edge.
