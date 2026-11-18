# H4E2 – placement and routing notes

Board: 86 × 77.7 mm, 2 layers. All 62 loose parts were placed on B.Cu, the board was routed, and
ground zones were added on both layers. Outline, locked footprints, footprint definitions and nets are
unchanged (checked by script against the original file).

## Result

- `kicad-cli pcb drc` with the project's JLCPCB rules (`H4E2.kicad_dru`): **0 unconnected items, no
  clearance / copper / courtyard / silkscreen violations.**
- What DRC still reports was already in the file I was given, and I left it alone:
  - 10 × `lib_footprint_issues` (library link warnings);
  - 1 × `npth_inside_courtyard` (H1012 inside the display courtyard – already excluded in the project);
  - 3 schematic-parity warnings for the two logo footprints (`REF**`).
- Gerber and drill export run without errors (tested to a temp folder; nothing is left in `/work`).
- Copper: 0.2 mm minimum track, 0.2 mm minimum clearance, vias 0.6 / 0.3 mm (tented, as the board setup
  already specified). Nothing needs a JLCPCB extra-cost option.
- F.Cu is one continuous ground polygon. About 1850 mm of track is on B.Cu and 350 mm on F.Cu.

## Floor plan (and why)

| Block | Where | Reasoning |
|---|---|---|
| Power entry: U1003 and U1004 load switches, CT caps, EN pull-downs, input caps, JP1001/JP1002, TP1001/2/3/5 | left of the XIAO, top | Next to the XIAO 5V/GND/3V3 pins, so the unswitched +5V net is short. |
| LDO U2001, C2001/2/3, FB2001, C2006, TP2001, R2001 | below-left of the XIAO | Fed from 5V_AUX; sits where the 3V3A feed can drop straight to the ADC without crossing SPI. |
| ADC U2002, 4 × RC input filters, 4 decoupling caps | right of the key block, between the two key rows | Hall lines stay short (30–58 mm) and on B.Cu only; the SPI lines are the long ones instead, which is harmless at ≤ 2 MHz. |
| Level shifter U1001, R1001, C1003 | just below the XIAO | See "Channel under the XIAO" below. The series resistor is at the driver. |
| MCP23017 U3001, C3001, I2C / INT / RESET pull-ups | right of the XIAO | I2C and INT pads are on that side of the XIAO; encoders are below it. |
| Per-key caps (hall 100 nF, LED 100 nF) | at each sensor VCC pin / each LED VDD pad | Each cap is within 2 mm of the pin it serves, with a ground via next to it. |
| Encoder debounce caps | directly at the A/B/C pins of each encoder | |
| Bulk 10 µF on 5V_LED (C1006–C1009) | end of row-1 rail, middle of row-2 rail, encoder-LED rail, west spine | Schematic note says "end of the LED rails". C1007 is mid-rail, not at the end – see open points. |

## Routing decisions

**F.Cu is the ground plane; signals are on B.Cu.** The nets cannot all be routed on one layer, so F.Cu is
used only in these places:

- A band of six thin traces along the very top edge (y 61.9–64.1 mm): DS_BL, D_CS, DS_RES, EN_AUX, EN_LED
  and LED_DATA. These start on the right-hand XIAO pads and are needed on the left. At the board edge
  they do not split the plane under anything else. BL / CS / RES end directly on the display header's
  through-hole pins (one via each).
- Five short hops:
  - +3.3V under the 5V_LED / LED-data columns (2.5 mm);
  - KEYS_LED_DATA_IN under the SPI lines and the 3V3A feed (5.5 mm);
  - +3.3VA to the row-1 hall sensors under H1/H2 (4 mm) – a supply hops, not a signal;
  - E1_SW into its through-hole encoder pin (7 mm);
  - ENC_SW6 into its through-hole encoder pin (11 mm).

**Channel under the XIAO (B.Cu).** Seven traces run under the module between its edge pads and its
centre pads: the 4 ADC SPI lines, +3.3V, 5V_LED (0.6 mm) and LED_DATA. Reason: display and ADC signals are
interleaved on the XIAO's left pads. Taking SPI out under the module lets the display lines (DC, SCL,
SDA) run straight west on B.Cu with no vias. Clearance to the module's bottom pads is ≥ 0.4 mm.

**Analog (hall → ADC).**
- All four hall outputs are on B.Cu from sensor to ADC, with no vias.
- H1/H2 enter under the SOIC from its north end and reach pins 2/4 from the inside; H5/H6 come up the
  outside. The ADC pin order is the opposite of the key order, and this was the only way to avoid
  crossing analog lines. The 3V3A feed runs under the body between the hall lines and the SPI pins.
- Each RC cell (R, C in line between the two pin rows) is at the ADC pins; every cap has its own ground via.
- The ferrite and 10 µF sit at the LDO. ADC decoupling is at pins 15/16; AGND/DGND each have a via
  beside the pin.

**Power.**
- 5V_AUX: U1003 → around the west side of the display header → display pin 2 → on to the LDO. This is
  long (about 70 mm to the LDO, 0.5 mm wide, roughly 70 mΩ) but needs no vias and cuts nothing; the load
  is tens of mA.
- 5V_LED for the keys: 0.8 mm rail around the same corner, down the west edge, then one trunk per key
  row (a comb). Fed from the west so it never crosses the hall lines.
- 5V_LED for the encoder LEDs and U1001: through the channel (0.6 mm).
- Track widths: +5V 0.5, 5V_LED 0.8 / 0.6, 5V_AUX 0.5, 3V3A 0.5 / 0.3, +3.3V 0.3 (a few mA only).

**LED chain.** D31 → D36 → D22 → D21 → D26 → D25 as in the schematic. Only KEYS_LED_DATA_IN changes layer.

**Ground.**
- GND zones on both layers, 0.25 mm clearance, thermal reliefs on pads.
- 212 ground vias: one at essentially every SMD ground pad (two at the XIAO GND pin), one in each
  isolated B.Cu pour island so it stays as a grounded guard between traces, and a ~3.5 mm stitching grid.
- No vias under the XIAO, inside courtyards or under silkscreen text.

**Silkscreen.** The design shows part *values* on B.Silkscreen with references hidden. I repositioned the
value text of every placed part so it clears pads, vias, other silk and the locked "LED" / "Hall" labels.

## Project file changes

- New net class `Power` (0.5 mm nominal width) for +5V, +5V_AUX, +5V_LED, +3.3V, +3.3VA and the LDO
  output. Clearance is unchanged at 0.2 mm.
- Board minimum clearance and minimum track width raised from 0.1 to 0.127 mm, so DRC checks against
  what JLCPCB's standard 2-layer process can make. The board itself uses 0.2 / 0.2.

## Not finished / not ideal

- **Traces under the XIAO module.** This assumes the module underside has exposed copper only where the
  footprint has pads. If your module revision has other exposed test points on the bottom, check them
  against the seven channel traces (x 68.3–72.0 mm) before ordering.
- **Three value labels are hidden** because there was no clean spot: R1001 (220), R2003 and R2004 (1k,
  in the ADC filter array; their neighbours R2002/R2005 are labelled). The long part-number labels
  (TPS22810DBV, MCP23017…) are legible but lie across traces. Label positions were placed by script and
  not hand-tuned.
- **C1007** (10 µF, row-2 LED rail) is in the middle of that rail, about 13 mm from each row-2 LED, not
  at its end. The end position would have covered the locked "LED" silkscreen label at D26001.
- **5V rails over the F.Cu band.** In the top-left corner the 5V_LED and 5V_AUX rails on B.Cu run above
  the F.Cu band for about 20 mm, so there they sit over signal traces, not ground. These are DC rails
  and static/slow signals, so I accepted it.
- **Hall lines under the ADC and near LED data.** H1/H2 run under the ADC body within about 1.5 mm of
  the SPI pins (with the 3V3A trace between them). H1/H2 also run parallel to one LED-data link for
  about 12 mm at 1.3 mm spacing, with ground pour between. Both are filtered by the 1 k / 100 nF RC,
  but the unfiltered ADC channels (CH1/3/5/7) see whatever couples.
- **Long LED data runs.** LED_DATA (3.3 V, XIAO → U1001) is 62 mm, E_LED_DATA_IN (R1001 → first LED)
  42 mm, and KEYS_LED_DATA_IN (encoder LEDs → key LEDs) 59 mm. Fine for 800 kHz SK6812 data with
  220 Ω at the source; not simulated. The ADC SPI lines are about 63 mm.
- No teardrops were added.
- The pre-existing DRC items listed under "Result" were not touched.
- Nothing was verified electrically beyond DRC and connectivity. Current and voltage-drop figures above
  are hand estimates.
- The placement/routing scripts are not included in `/work`; the board file is the deliverable.
