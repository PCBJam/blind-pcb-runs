# 004 – rest of the P4 escape, USB pairs, plane vias
- `scripts/esc_n2.py`: CSI D0/D1 from the series resistors up the J5/J6 corridor on F.Cu; CSI CLK needs the same kind of crossing as DSI D0 and hops on B.Cu to the west side of J5.
  USB HS pair (0.15/0.2, ~90 Ω over the 0.1 mm prepreg) on F.Cu from U1 to the ESD array D2, then a short B.Cu run past test points TP3/TP4 to J11; the two A/B pads of each line are joined by a U on either end of the pad row.
  USB serial/JTAG pair (full speed only) goes down to B.Cu at U1 and runs to TP1/TP2/D1/J2 – it would otherwise have to cross the HS pair.
- `scripts/esc_wse.py`: west/south/east sides. Every second signal pin gets a via *inside* the pad ring (between pad row and thermal pad), the others a via just outside;
  supply pins run straight to their capacitor; 1.1V pins have in-ring vias into the 1.1V island on In2; crystal 3 mm from pins 99/100; 3x3 vias in the thermal pad.
- `bt plane` then gave 124/128 GND pads and 38/43 3.3V pads a via into In1/In2. A few of its vias landed in lanes I wanted (C22/C24 under the SDIO bus) and were moved by hand.
- Buck converter loop (C6–U5–L1–C7) routed with 0.5–0.6 mm tracks, power rails with 0.4–0.6 mm, SDIO bus to the C5 on F.Cu only (18.6–23.3 mm, no vias).
Failed/redone on the way: first SDIO run left D2/D3 unrouted (shortest-first order closed the lane; C22 pad and two plane vias in the way) → moved C22/C24, rerouted outermost-first.
