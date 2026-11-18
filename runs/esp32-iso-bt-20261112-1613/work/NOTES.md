# ESP32-PoE-ISO Rev.O – layout notes

## Status: NOT ready to order

Placement is complete and I stand behind it. Routing is **not** complete:
KiCad 10 DRC on the saved board reports **48 unconnected items in 21 nets** and **33 errors**.
The board must not be ordered as it is. What is open is listed at the end, most important first.

Locked parts were not touched (`bt same`: nothing locked moved, no parts added or removed, pad nets unchanged).
No footprint was edited. The `.kicad_pro` has one added net class and the project has one added `.kicad_dru` (see "Rules").

## Floorplan and why

The designer's isolation barrier is drawn on User.Eco1 (two lines 3.56 mm apart). I treated the inner line as the limit for
all PoE-side copper and the outer line as the limit for all system-side copper. Everything else follows from that.

- **ESP32 module** at the top, antenna end at the board edge. It sits 1.5 mm below the edge (origin y = 107.3) because its nine
  thermal vias must clear the microSD signal pads on the back; any higher and they short. Side effect: ESP32 pads 14–17 and
  22–25 lie inside the 1.55 mm keep-out of mounting holes MH2/MH3 (8 DRC errors that cannot be removed without moving locked parts).
- **DC/DC module (DCDC1)** vertical at x = 104.9, straddling the barrier where the band is exactly as wide as the gap
  between its pins 2 and 4. Y-capacitor C23 across the left band, C20 (not fitted) across the top-right band.
- **PoE side** (inside the inner line, both sides used): L4 and both electrolytics on top; PD controller U2, buck U5, D5, R27
  on the back; R41 under the jack. U2 and U5 have a drilled thermal pad, so each blocks both sides – that drove most of the
  arrangement. Hot loop C27 → R28 → U5 → D5 → C27 is short; the switch node goes pin → via → inductor pad.
  R41 is reached through the 1 mm gap between jack pins 8 and 10 with a 0.25 mm Spare1 track and a 0.25 mm Earth track on In1.
  That Spare1 track runs up to 0.4 mm outside the drawn inner line for 4 mm; it still keeps > 3 mm to all system copper.
- **PHY (LAN8710A)** on the back between the header rows, pair pins facing the jack. First I had it in the strip left of the
  barrier; a 5 mm QFN cannot be escaped in 6.5 mm, so it moved (progress 003).
- **Buttons, LiPo charger, status LEDs** on the left strip next to the battery connector; **CH340X** on the back beside the
  USB connector; **3V3 buck** (U7, L2, C6, C22) between the header rows with the input cap directly on the VIN/GND pins;
  input diode D3 and FET2 right at the buck input.
- MDIO/RXD pull-up array RM2 sits beside the ESP32 pins, not at the PHY – the PHY side had no room and pull-ups work anywhere.

## Layer use

| Layer | Intended | What it became |
|---|---|---|
| F.Cu | parts, short signals, GND pour | as intended |
| In1 | solid GND (system) / Earth (PoE) | GND plane, **but cut by about 90 auto-routed track segments** added in the last pass |
| In2 | +3.3 V plane north of y = 137.5, GND south of it (reference for the Ethernet pairs on B.Cu), PoE trunks | plane **plus ~170 signal segments**; the +3.3 V plane is sliced by long diagonals |
| B.Cu | parts, Ethernet pairs, signals, GND pour | as intended |

Stack-up in the file: 0.127 mm prepreg outer–inner, 1.2 mm core. Outer-layer traces reference the adjacent inner layer.

## Routing approach

- **Ethernet pairs** (0.127/0.127, class Zdiff=100R) scripted by hand: B.Cu from the PHY through the 49.9R pads, under the USB
  connector between its shell legs, down the left strip into the jack "finger". TD stays on B.Cu. RD changes to F.Cu with
  two vias beside the finger, because the bottom-mounted PHY mirrors the pin order. Pairs open to 0.5–1.0 mm pitch for
  about 5 mm at the termination/TVS pads. Centre-tap supply (RCT) is a 0.3–0.4 mm In2 track along the same path.
- **USB pair** 0.157 mm, two vias to the CH340X. **PoE power** 0.4–0.6 mm, each connection placed with way-points.
- **RMII**: RX group and MDIO hand-scripted (B.Cu up the left side, one via each at the module); TX group and the 50 MHz
  clock auto-routed, not length- or reference-checked.
- Everything else: `bt route` net by net. This is where the board went wrong (progress 005): the router is sequential and has
  no global plan, so the last nets were boxed in.
- Zones poured with `pcbnew`; stitching vias from a small generator of mine (59 placed, 4 removed again for the shield track). The antenna area has a copper keep-out.

## Rules I added

- Net class `PoE_Signal` (0.15 mm clearance) for the small PoE-side nets, so every PoE net is in a PoE class.
- `ESP32-PoE-ISO_Rev_O.kicad_dru`: 3.0 mm clearance between PoE classes and everything else (ETH_Shield excluded – the jack
  itself puts shield pins 1 mm from signal pins). It caught two real mistakes during the work. Final DRC: no violation of it.

## Not finished / not good

Functional gaps (open links):
1. **/GPIO1/U0TXD** – module pin not connected to header, FET4 or R50. No UART TX to the USB bridge.
2. **/ESP_EN** – reset button, auto-reset diode D9, power-good resistor R44 and EXT1.4 are not joined to the module.
3. **Net-(U3-VBAT)** – battery connector is not connected to the charger/FET2; R7 open.
4. **Net-(Q2-E), Net-(Q3-E), Net-(U1-CTS#)** – auto-program circuit incomplete.
5. **/GPIO14/HS2_CLK → R40** – microSD clock open. SD DAT2 and CD/DAT3 pull-ups open.
6. **GND**: C22.2 (3V3 buck output cap), C13.2, C16.2, R26.2 (PHY bias resistor) have no connection to ground; about ten
   small GND pour islands are isolated. C29.1/C21.1 (not fitted) and the duplicate ESP32 pad 15 likewise.
7. **Net-(U4-LED2/NINTSEL)** to R14 (link LED), **Net-(U4-NRST)** to C21 (not fitted), four **TVS1** stubs, C30.2 (+3.3V, not fitted),
   one +3.3V pour island, duplicate ESP32 pads GPIO13 / NC22, a 0.03 mm dangling GPIO16 stub on In1.

DRC errors still present:
- 29 × mounting-hole keep-out: 8 are the ESP32 pads above; the rest are auto-routed vias/tracks near MH2/MH3
  (+3.3VLAN, NC-pad 17/21 vias, GPIO17 clock, GPI39 on In1).
- 2 × fiducial clearance and 2 × solder-mask bridge: one D4-K via 0.9 mm from FID7/FID8.

Quality concerns even where connected:
- In1 is no longer a clean ground plane, and In2 is no clean +3.3 V plane (see table). Return paths were not reviewed.
- Auto-routed tracks are 0.15 mm, including +3.3VLAN branches; several run long diagonals and use more vias than needed.
- The module's +3.3 V pin relies on one via into the sliced In2 plane; the buck output reaches the plane through vias
  placed by `bt escape`, not checked for current.
- Silkscreen was not touched: 199 silk-over-pad warnings, reference texts overlap.
- No impedance calculation was done; pair geometry is the net-class value only.
- Pair skew was not measured (RD- runs alone for about 4 mm at the jack, by pin-out).

What I would do next: rip all auto-routed nets, reserve In1 strictly for ground, route the 20 open nets first by hand
(they are all pin-escape problems around U1, U4, Q2/Q3 and the module corners), then the rest.

## Files

- `progress/` – numbered pictures and notes, including the discarded attempts.
- `scripts/` – placement table (`pl.py`), zone and stitching scripts, the hand-routing scripts.
- `BT-REVIEW.md` – review of the `bt` tools.
