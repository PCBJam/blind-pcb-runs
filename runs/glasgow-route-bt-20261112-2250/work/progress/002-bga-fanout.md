# 002 – BGA power/ground + north-side fanout (hand-placed)
- Via 0.45/0.2 is the only size that fits between 0.8 mm balls (0.166 mm to balls); used only inside the BGA.
- Power/GND balls get a dog-bone via that lands in/next to the matching bottom-side 0402 decoupling cap pad.
- North side: rows 1–2 leave on F.Cu (lower-row J5 LVDS pairs); rows 3–4 drop to B.Cu (upper-row J5 pairs).
  The y=92.7 via row is left open at x=82.5 and x=84.1 so row-4 nets and VIO_AUX can leave on B.Cu.
- Two of the four extra centre GND vias were dropped to give VIO_AUX (ball G4) a B.Cu lane to C33.
- `bt probe`: all 128 items clear.
