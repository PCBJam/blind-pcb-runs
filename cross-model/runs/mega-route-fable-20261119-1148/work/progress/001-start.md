# 001 – starting point and rules

Board as delivered: 66 footprints placed, no copper. Read the netlist with `bt board` and
identified the circuit (ATmega2560 + ATmega16U2 USB bridge, USB-C, barrel jack → NCP1117-5,
LP2985-3.3, LMV358/PMV48XP auto power select).

Before routing, changed the rules to something JLCPCB builds without trouble:
- board minimums: clearance 0.15, track 0.15, via 0.6/0.3 (annular ≥0.13), hole-to-hole 0.5
- Default class: 0.25 mm track, 0.2 mm clearance, 0.6/0.3 via (was 0.2 / 0.1 clearance — below JLC's 0.127)
- Power class (GND, +5V, VCC, Net-(D4-A), USBVCC, XVCC, +3.3V, AVCC): 0.5 mm track, 0.8/0.4 via
- hole clearance: 0.25 for all routed copper via a .kicad_dru rule; the board-wide floor is 0.19 only
  because the USB-C land pattern has its pegs 0.194 mm from its own pads (first try at exempting
  J1 by a custom rule failed: board-setup minimums are a floor, custom rules can only tighten).

Picture: the unrouted board with ratsnest.
