# 001 – rules and inner planes

- Read the schematic/netlist: ESP32-WROOM + LAN8710A PHY (RMII), CH340 USB-UART, LiPo charger, 3.3 V buck,
  and an **isolated PoE front end** (TPS2378 PD + TX4138 buck + F0505S isolated DC/DC). Nets Spare1/Spare2/Earth/
  5V_DCDC/ILIM/D5-K (+ small feedback nets) are on the cable side of the barrier.
- Added net class `PoE_Signal` for the small PoE-side nets and a `.kicad_dru` rule: PoE side to logic side ≥ 1.4 mm
  (tightest gap the fixed placement allows: LAN_CON1 pin 4 ↔ R27 pad 1 = 1.44 mm).
- Zones: In1 = GND (logic) + Earth (PoE). In2 = +3.3 V (top block and two side fingers), GND (PHY/USB/Ethernet
  corridor), Earth (PoE). Zone outlines drawn ≥ 1.9 mm apart across the barrier.
- Picture: In1+In2 fills overlaid.
