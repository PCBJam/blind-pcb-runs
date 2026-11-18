# ESP32-PoE-ISO Rev.O – routing notes

Board: 28 × 98 mm, 4 layers (F / 0.127 prepreg / In1 / 1.2 core / In2 / 0.127 prepreg / B), all footprints left
exactly where they were (`bt same` against the original confirms this – see the end of this file).

**Status: not finished – see "Known compromises / not good". Power, PoE, Ethernet/RMII, USB pair and SD card are routed and DRC shows 0 errors, but 43 links in 25 nets are still open, among them the UART lines.**

## What the circuit is, and what that means for the layout

* ESP32-WROOM-32E (antenna hangs over the top board edge), LAN8710A PHY on the bottom side (RMII, 50 MHz clock
  out of GPIO17), RJ45 with magnetics, CH340X USB-UART (full-speed USB), LiPo charger, 3.3 V buck (U7/L2).
* **Isolated PoE front end**: jack rectifier → `Spare1` (+48 V) / `Spare2` (−) → TPS2378 PD (U2) → `Earth` (switched
  return) → TX4138 buck (U5, L4, D5) → `/5V_DCDC` → F0505S isolated DC/DC (DCDC1) → `+5VP` on the logic side.
  Everything named Spare1/Spare2/Earth/5V_DCDC/ILIM/D5-K and the small U2/U5 nets is on the cable side of the
  barrier; C23 (3 kV), C20 and DCDC1 are the only parts that bridge it.

## Layer use

| Layer | Logic side | PoE side |
|---|---|---|
| F.Cu | components, RMII clock + TX + RX, USB pair, TD pair (south half), GND pour | L4, sense resistor, 5V_DCDC pour, Earth pour |
| In1.Cu | **solid GND plane, no tracks** | **solid Earth plane** |
| In2.Cu | +3.3 V plane (north block + two side fingers); GND under PHY / USB / Ethernet corridor | Spare1 (+48 V) under the buck, Earth under the DC/DC input |
| B.Cu | PHY, RD pair, TD pair (north half), centre-tap rail, slow GPIO, GND pour | U2, U5, D5, Earth pour |

Reasons:

* The prepreg is only 0.127 mm, so each outer layer is tightly coupled to the plane next to it. The net classes
  already assume this (0.127 mm / 0.127 mm for 100 Ω, 0.157 mm for 90 Ω), so both inner layers had to stay planes
  under anything fast.
* In1 is one unbroken GND sheet on the logic side. Everything fast that could be put on F was put on F
  (RMII clock, TXD0/1, TX_EN, RXD0/1, CRS_DV, USB).
* In2 is +3.3 V where the ESP32 module, SD card, UEXT and the pull-ups are, because the module has no local bulk
  capacitor on the board and wants a low-inductance feed from C22/L2. Under the PHY, the Ethernet pairs and the
  USB area In2 is GND instead, because the PHY sits on B and its pairs start on B.
* No signal is routed on In1. In2 was meant to stay track-free as well; in the end it carries a few router-made hops (listed under "not good").

## Isolation barrier

* Added `ESP32-PoE-ISO_Rev_O.kicad_dru`: any PoE-side net to any logic net ≥ **1.4 mm**. 1.4 mm is simply the
  tightest gap the fixed placement allows (LAN_CON1 pin 4 to R27 pad 1 is 1.44 mm pad to pad). Added net class
  `PoE_Signal` (0.2 mm clearance, 0.25 mm track) for the small PoE-side nets so the rule covers them too
  (they were in Default before). The project file's other settings are untouched.
* Zone outlines are drawn 1.9–3.4 mm apart across the barrier on all four layers; tracks keep ≥ 1.9 mm except at
  the jack pins.
* R27 sits under the jack, south of the logic pins. Spare1 and Earth reach it on the inner planes round the east
  side of the jack, so no PoE copper runs between the Ethernet pins.
* The shield (`/ETH_Shield`) keeps the original 0.508 mm class clearance. Both shell tabs and pins 7/8 are joined;
  the west tab is linked by a 0.3 mm track along the bottom edge under the jack body.

## Routing approach, in order

1. **Ethernet pairs** (hand-computed, 0.127/0.133 mm). They leave the PHY between the 49.9 Ω terminators (each
   line tees into its resistor pad), run SW side by side, squeeze through the neck between the USB shell and the
   DC/DC output pins, then go down the left corridor to TVS1 and the jack. RD is on B the whole way (no layer
   change); TD changes once (B→F) because TVS1 is on F. The order at TVS1/TVS3/jack was worked out so nothing
   crosses: RD makes a small U round TVS3. The analog 3.3 V for the centre taps (`RCT`) runs between/next to the
   pairs on B and hops to F at the jack.
2. **USB** D+/D−/VBUS on F, south of the DC/DC pins, up through the gaps between its pins, round the south and
   east of the CH340 and in between its pad rows. Chosen so +5VP, VBUS and the pair never need to cross on a layer.
3. **PoE converter** by hand: switch node is just the D5 pad, two vias to L4 and short stubs to U5/C12; Earth
   returns go straight into the D5 anode pad and to In1; Spare1 is the In2 plane; 5V_DCDC is a pour on F.
4. **PHY fan-out and RMII** by hand as fixed lanes. Clock + TX use the 4-track gap at the lower-right corner of
   the module, RX the lower-left one. The clock makes one short hop on B at the ESP32 pad (it needs a via there
   for U8 anyway) so that it is the westmost lane and can reach PHY pin 5 without crossing the TX group.
5. GND / +3.3 V stubs and vias to the planes (`bt plane`), then the remaining GPIO/power nets with the `bt` router
   on F/B, then GND/Earth pours on both outer layers and stitching.

## Known compromises / not good

**The board is not completely routed.** I ran out of time; `bt ratsnest` at the end says: *25 nets not fully connected, 438.453 mm of ratsnest*.
Do not order it as it is. What is open, per net (pieces = connected groups, coordinates of the missing links):

| Net | pieces | missing mm | missing links |
|---|---|---|---|
| `/GPI34/BUT1` | 3 | 14.818 | 104.659,106.599–108.859,114.899; 109.659,117.699–113.559,121.599 |
| `+5V` | 2 | 27.971 | 91.44,123.22–91.186,95.25 |
| `GND` | 4 | 10.743 | 105.91,135.606–106.172,132.334; 116.713,104.521–112.751,104.079; 112.751,104.079–109.44,105.13 |
| `Net-(U3-VBAT)` | 2 | 36.365 | 95.501,136.566–95.123,100.203 |
| `/PG` | 2 | 7.676 | 99.55,134.5–97.917,127 |
| `Net-(U4-LED2/NINTSEL)` | 2 | 32.558 | 91.567,168.656–102.96,138.156 |
| `Net-(Q3-E)` | 3 | 30.529 | 110,142.65–111.008,135.3; 111.008,135.3–112.903,112.268 |
| `/GPIO3/U0RXD` | 8 | 18.352 | 112.6,145.908–103.124,145.029; 100.224,144.629–93.3,139.14 |
| `/GPIO4/U1TXD` | 3 | 29.012 | 106,115.958–112.64,106.421; 100.1,128.458–91.44,143.54 |
| `/GPIO16/I2C-SCL` | 3 | 36.512 | 108.14,126.458–112.64,105.151; 112.64,105.151–98.04,103.158 |
| `/GPIO13/I2C-SDA` | 3 | 16.834 | 95.64,110.231–99.44,108.421; 105.04,120.908–114.64,129.108 |
| `/GPIO15/HS2_CMD` | 2 | 4.324 | 108.6,108.691–112.64,110.231 |
| `/GPIO2/HS2_DATA0` | 2 | 0.2 | 112.692,109.154–112.64,108.961 |
| `/GPIO14/HS2_CLK` | 3 | 17.796 | 109.22,127.458–116.84,143.54 |
| `/GPIO5/SPI_CS` | 2 | 16.378 | 109.62,118.708–112.64,102.611 |
| `/GPI36/U1RXD` | 2 | 11.651 | 105.74,122.22–116.84,125.76 |
| `/GPIO33` | 2 | 37.3 | 97.74,101.341–116.84,133.38 |
| `unconnected-(U6-NC-Pad17)` | 2 | 6.034 | 95.64,111.501–100.98,108.691 |
| `unconnected-(U6-NC-Pad18)` | 2 | 7.768 | 95.64,112.771–102.25,108.691 |
| `unconnected-(U6-NC-Pad19)` | 2 | 9.525 | 95.64,114.041–103.52,108.691 |
| `unconnected-(U6-NC-Pad21)` | 2 | 7.742 | 106.06,108.691–112.64,112.771 |
| `unconnected-(U6-NC-Pad22)` | 2 | 6.008 | 107.33,108.691–112.64,111.501 |
| `/GPIO0` | 4 | 19.659 | 112.64,107.691–105.64,114.691; 98.04,126.191–91.44,133.38 |
| `/GPIO1/U0TXD` | 3 | 7.545 | 94.778,145.478–95.377,148.717; 94.778,138.553–91.44,135.92 |
| `+3.3VLAN` | 3 | 25.154 | 112.209,136.367–110.617,136.525; 105.13,127.2–115.351,105.979 |

**What works and what does not, in plain words (my reading of the open list):**

* Routed and checked: power entry and both 5 V paths, the 3.3 V buck including feedback, battery charger, the
  whole isolated PoE chain, Ethernet pairs + centre-tap rail, the complete RMII bus (clock, TXD0/1, TX_EN,
  RXD0/1, CRS_DV, MDC, MDIO), PHY straps/bias/reset, PHY power switch, USB D+/D−/VBUS, SD card, ESP_EN/reset
  button, BUT1 pull-up, ACT LED.
* **Not working as it stands:** the USB-UART data path (CH340 TXD → D6 → U0RXD has an open link, U0TXD → FET4 /
  R50 level shifter and EXT1 pin 6 have open links), DTR auto-reset (`Net-(Q3-E)`), the LNK LED, battery and
  +5 V measurement dividers, `/PG` (power-good to the EN network – EN is still pulled up by R32), and several
  header / UEXT pins (GPIO0, 4, 5, 13, 14, 16, 33, GPI34, GPI36). Each needs one or two short manual links.

How to read this list:

* The six `unconnected-(U6-NC-PadNN)` nets and the second pads of GPIO13/GPIO15/GPIO2 are the duplicate pads of the
  universal WROOM/WROVER footprint. With the WROOM-32E fitted only one pad of each pair touches the module, so
  these gaps are DRC items, not functional faults. I left them rather than spend vias on them.
* `GND` open items: C14 pad 2 (VDDIO decoupling of the PHY – it sits between two strap tracks and I found no room
  for a via; **this one should be fixed**, e.g. by moving the RXER strap), U8 pin 3 / C29 pad 1 (both parts are
  "NA", not fitted).
* `+3.3VLAN` open items: R25 pad 2 (nRST pull-up; the LAN8710A has an internal pull-up, but the resistor is
  currently useless) and the branch to the unfitted U8/C29.
* Everything else in the table is a real open signal: header/UEXT GPIOs, the battery- and +5 V-sense dividers at
  the top of the board (long thin sense lines), the LNK LED cathode drive from the PHY, the DTR auto-reset line
  (`Net-(Q3-E)`), parts of U0RXD/U0TXD. These need to be finished by hand; most are blocked by earlier
  auto-routed GPIO tracks around the gate between the two mounting holes (y ≈ 110–118) and east of the PHY.
* Dangling track ends / vias reported by DRC as warnings belong to these unfinished nets.

Other things I know are not good:

* **Auto-routed GPIO nets are untidy** (many vias, long detours, a few short hops on In2). The hand-routed nets
  (Ethernet pairs, USB, RMII, PoE converter, PHY fan-out) are intact – checked by re-applying their item files
  (0 segments missing) – but the bulk of the slow GPIO wiring is router output and deserves a clean-up pass.
* In2 carries some router-made signal/power hops: /GPI35: 41.691 mm (F.Cu 1.483, B.Cu 2.707, In2.Cu 37.5), 1 vias; /GPI39: 54.871 mm (F.Cu 11.765, B.Cu 4.092, In2.Cu 39.014), 5 vias; /GPIO1{slash}U0TXD: 76.134 mm (F.Cu 0.81, B.Cu 57.326, In2.Cu 17.998), 3 vias; /GPIO12{slash}PHY_PWR: 49.725 mm (F.Cu 28.698, B.Cu 2.702, In2.Cu 18.325), 2 vias; /GPIO13{slash}I2C-SDA: 43.233 mm (F.Cu 30.52, B.Cu 6.573, In2.Cu 6.14), 4 vias; /GPIO15{slash}HS2_CMD: 75.722 mm (F.Cu 25.616, B.Cu 33.336, In2.Cu 16.771), 5 vias; /GPIO16{slash}I2C-SCL: 26.528 mm (F.Cu 3.327, B.Cu 13.391, In2.Cu 9.81), 4 vias; /GPIO2{slash}HS2_DATA0: 85.7 mm (F.Cu 32.531, B.Cu 41.182, In2.Cu 11.987), 7 vias; /GPIO23{slash}MDC(RMII): 51.987 mm (F.Cu 24.622, B.Cu 10.021, In2.Cu 17.344), 4 vias; /GPIO32: 46.178 mm (F.Cu 10.45, In2.Cu 35.728), 1 vias; /GPIO5{slash}SPI_CS: 44.386 mm (F.Cu 2.736, B.Cu 30.861, In2.Cu 10.788), 3 vias; +3.3V: 29.504 mm (F.Cu 7.991, B.Cu 16.909, In2.Cu 4.604), 16 vias; +3.3VLAN: 44.15 mm (F.Cu 4.17, B.Cu 21.382, In2.Cu 18.598), 3 vias; +5V: 70.187 mm (F.Cu 40.302, B.Cu 16.121, In2.Cu 13.764), 6 vias; unconnected-(U6-NC-Pad20): 22.736 mm (F.Cu 12.859, In2.Cu 9.877), 2 vias.
  Each was accepted only if the +3.3 V and GND plane group counts stayed the same after a refill, so the planes
  are still in one piece, but In2 is no longer a pure plane layer. In1 has no tracks.
* +3.3VLAN reaches the PHY's VDDIO pin (and C14) through a thin route, not a pour. The current is a few mA.
* The 3.3 V regulator feedback divider senses the +3.3 V plane through a via and a 4.5 mm In2 jumper next to the
  PHY, not directly at C22. DC-accurate, but not textbook.
* The RMII clock has two vias at the ESP32 end (5 mm on B) and one at the PHY; TX/RX have one via each. Tracks are
  0.15 mm (about 60 Ω over the 0.127 mm prepreg); no length matching was done (35–45 mm, not needed at 50 MHz).
* TD and RD are not length-matched pair to pair; inside each pair the skew is a few mm at the jack end where
  the lines split to reach their pins (TVS1 / jack pin order forces this).
* The isolation rule is 1.4 mm because the placement (R27 under the jack) allows no more. Zone-to-zone gaps are
  ≥ 1.9 mm. No slot was milled; creepage is surface FR-4 only. The original design values for this barrier are
  not known to me.
* No stitching-via pass and no teardrops were done; GND return vias next to the TD layer change are missing.
* PoE section thermal design (U5 exposed pad is net /ILIM, U2 pad is Spare2) relies on the pours only.
* Silkscreen was not touched or checked. One via (U0TXD at U6 pin 35) sits on the end of the module pad because
  the copper layer-number marks next to it left no other place.


## Verification

* `bt drc --baseline` (KiCad 10 DRC, zones refilled): DRC (new since baseline): 0 errors, 44 warnings; nets with more unconnected items 1; parity 0   [all: 191 violations, 43 unconnected, 26 parity]. The warnings are the dangling ends of the
  unfinished nets; the 147 library warnings and 26 parity items were there before I started.
* `bt same` against the original board: ok: nothing locked moved, no parts added or removed, pad nets unchanged
* The project file only gained the `PoE_Signal` class and eight net assignments; a `.kicad_dru` was added.

