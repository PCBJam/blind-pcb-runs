# 006 - Final state of this session (not finished)

Board saved in place: `/work/OrangeCrab.kicad_pcb` (KiCad 10 loads it; `kicad-cli pcb drc` runs on it).
Picture: `006-final-state.png` (whole board; green dashes are the unrouted connections).

**Counts (KiCad DRC on the saved file, with the project rules):**
- 153 errors: 84 copper-to-edge clearance (all from the Feather headers J1/J2 whose pads touch the outline, actual 0.00 mm),
  68 courtyard overlaps (placement), 1 malformed courtyard (J5). No shorts, no track clearance errors, no crossings,
  no track-width errors remain.
- 307 warnings: dangling track and via ends (open routes), footprint library not configured (111), silk text height (39), hole-to-hole (3).
- 120 unconnected items; 63 nets not fully connected (586 mm of ratsnest).
- 75 microvias (16 FPGA ground, 59 FPGA I/O), 2 zones (GND on In1.Cu and In3.Cu).

**Still open (see NOTES.md):** FPGA I/O (SD, JTAG, QSPI, LEDs, ADC mux, USB D+/-, EN, the Feather pins at the west and
north-west edge), DDR3 CK+/-, D11, D12, D15, A10, A13, BA0, CAS#, ZQ, VREF, power-in (VSYS, VBATT, PUSB_VBUS), a few
rail links (P1.35V, P2.5V, P1.1V, P3.3V), and some B.Cu decoupling ground pads under the FPGA.
