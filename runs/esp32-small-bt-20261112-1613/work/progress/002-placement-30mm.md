# 002 – full placement at 30 x 74.7 mm

All 147 footprints placed except five silkscreen-only logo/sign footprints (placed later, after routing,
where silk space is left).

* Left 23 mm: PoE primary. Top: RJ45, bleeder R27, TVS D10, C27/C26, DC/DC. Bottom: buck (U5, D5, L4),
  hot-swap U2 right under the PoE pins of the jack, bleeder R41, output TVS D11.
* Isolation: 3 mm copper-free band between primary and secondary on all four layers, bridged only by
  DCDC1, the Y-cap C23 and (unpopulated) C20; the 2x4 mm milled slot sits between DC/DC pins 2 and 4.
* Middle: USB (top edge) with CH340 underneath, buttons over the microSD (bottom side, card out of the
  top edge), UEXT with the Ethernet front end under it.
* Right: ESP32 module, antenna flush with the board end, LAN8710A PHY under the module tail, power path /
  buck / charger and the small-signal parts on the bottom under the module.

Picture: bt render (red = top copper, blue = bottom). 002-...-top.png is the top side with silk.
DRC on the placement alone: no pad clearance / short / hole errors left.
