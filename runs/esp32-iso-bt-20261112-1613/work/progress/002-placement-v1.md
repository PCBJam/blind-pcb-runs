# 002 – first complete placement
What: all 122 free parts placed with a script (`pcbnew`), checked with my own overlap / through-hole-pad checker and `bt render --pads`.
Why this floorplan:
- ESP32 module at the top, antenna at the board edge, shifted 1.5 mm down so its thermal vias miss the microSD pads on the back.
- DC/DC module straddles the barrier where the Eco1 band is exactly as wide as its pin 2–pin 4 gap (x=104.9).
- PoE side (PD controller U2, buck U5, D5, L4, both electrolytics) packed inside the inner Eco1 line. This took many paper iterations:
  U2/U5 have a drilled thermal pad, so they block both sides; L4 went to the top so no hole sits under it.
- PHY on the left strip next to the jack's signal "finger"; USB-UART chip on the back under the USB connector; buck 3V3 and charger between the header rows.
Result: no pad/body overlaps reported by my checker except deliberate same-net touches. Not routed yet; expect moves once routing starts.
