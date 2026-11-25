# 003 — USB connector and transceiver routed (J1, U15, FX2 D+/D-, CC, VBUS, shield)

**What I did**
- Differential pair USB_P/USB_N from the connector's A6/A7 pads to FX2 pins 8/9, 0.3 mm tracks with a 0.15 mm gap, 6.2 mm long, skew 0.05 mm, on F.Cu. Pair width is 0.3 (not the 0.45 class width): the 0.5 mm pin pitch at both ends cannot take 0.45 mm tracks, so 0.3 is the widest the connector-to-FX2 run gets. Estimated impedance about 110 ohm differential against the 90 ohm target (see NOTES.md).
- B6/B7 connector contacts bridged to A6/A7 (the two bridges interleave on the connector's pads, so the N bridge needs two vias on B.Cu).
- U15 (USB power-switch/tap IC) moved to the B side (rot 180) so its D+/D- pins face the connector. D+/D- taps are short stubs of 5-6 mm, one via each; the N tap was re-routed round the P tap. C8 moved to the B side to clear the corridor.
- CC1/CC2 pull-downs (R52/R53) moved to the B side under the connector; CC1 needed a shoved B.Cu track of USB_P (length unchanged).
- Shield: three F.Cu links plus one B.Cu link to the bottom shield pads.

**Why**
- The USB corridor between J1 and the FX2 is only ~5 mm wide and carries the pair plus the CC, VBUS, shield and U15 taps, so the pair and taps had to be fitted by hand around each other.

**Result**
- USB_P, USB_N, CC1, CC2, VUSB, xVBUS, SHLD: all connected, no ratsnest in this area. `bt probe` clean.
- Stubs are longer than ideal (USB_P 20 mm total including stubs, USB_N 20 mm with 3 vias). Acceptable for a full-speed-capable tap, but noted for the review.
