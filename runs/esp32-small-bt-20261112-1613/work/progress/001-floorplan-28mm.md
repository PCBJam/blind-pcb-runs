# 001 – first floorplan, 28 mm wide (abandoned)

Big parts only: RJ45 at the left end facing out, PoE primary strip (electrolytics, SIP-7 DC/DC) below it,
UEXT + USB + microSD + buttons in the middle, ESP32 module at the right end with the antenna on the board
edge, the two 1x10 headers flanking the module at 25.4 mm row spacing.

Why it was dropped: with the jack taking 17.2 mm of a 28 mm width, the primary (cable-side) area that is
left - a 10 mm strip plus the bottom side under the front of the jack - came to about 350 mm2 against
~310 mm2 of raw part area for the PoE front end (hot-swap, buck, inductor, SMC diode, TVS, two 2512
bleeders). That is ~85 % fill, not placeable without eating into the 3 mm isolation gap.
Board grows to 30 mm wide in the next step (+7 % area) instead of getting longer.
