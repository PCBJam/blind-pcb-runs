# 006 – bulk signal routing with bt (several attempts)

What was tried, in order:
1. `bt route --batch` over ~60 signal nets on F/B (In2 only for RMII TX, clock, long power taps): about two
   thirds routed. The first attempt left the PHY's right-hand pins boxed in by my own hand-routed strap
   tracks and a 3.3VLAN via, and the autorouter filled the pocket inside the module's WROVER/WROOM pad
   ring with other nets. **Thrown away.**
2. Re-placed RM1/RM2/T1 east of the module pad column, hand-routed the PHY right side as a bus
   (straps, RX, MDIO), hand-routed the module's NC pad pairs along the edge of the pocket, then ran the
   bulk pass again.
3. Pass 2 (In2 allowed everywhere), pass 3 (`--rip`, In1 allowed), pass 5 (0.127 mm tracks), and a
   `--shove` pass. Shove was the most effective (16 failing nets -> 7) but it also removed part of my
   hand-drawn 3.3 V tree on In2 (repaired afterwards) and moved a via into the spot one of my manual
   links needed.
4. Hand fixes: CH340 escape (R43 turned, new vias under the IC), GPIO15/GPIO2 pad twins, GPIO0 via,
   VDDA north/south link, stitching vias found by a small script.

Result: KiCad DRC 0 errors (including the 3 mm / 1 mm isolation rules), but **15 signal connections and
9 GND pads are still open** – see 007 and NOTES.md. The picture is the board at that point.
