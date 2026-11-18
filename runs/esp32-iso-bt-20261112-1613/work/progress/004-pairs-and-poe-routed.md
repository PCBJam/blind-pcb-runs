# 004 – Ethernet pairs, USB pair and the PoE converter routed
- Ethernet TD/RD pairs hand-scripted on B.Cu (0.127/0.127) from the PHY through the 49.9R/TVS pads, under the USB connector between
  its shell legs, down the left strip into the jack "finger". TD stays on B.Cu to the pins; RD swaps to F.Cu with two vias next to the
  finger, because pin order at the jack needs RD+ on the other side (mirror problem of a bottom-mounted PHY).
- Centre-tap supply (RCT) as a 0.4 mm In2 track along the same way. USB D+/D- 2 vias to the CH340X on the back.
- PoE: every connection given to `bt route` one by one with my own way-points and widths (0.5–0.6 power, 0.2 signal).
  First try used `--batch` with an `avoid` key: all 12 failed with "target is outside the search window" – the CLI form works.
- Mistakes caught: a Spare1 track to R41 cut through the isolation band (my custom 3 mm DRC rule flagged it; rerouted along the inner
  line); bt put one via 0.225 mm from the board edge; C20's 5V pad had no legal via site and got a thin F.Cu perimeter track instead.
Result: DRC clean except the known ESP32-pad / mounting-hole keep-out items. GND/Earth/3V3 still to be poured.
