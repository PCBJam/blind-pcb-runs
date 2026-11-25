# 004 passives around the bucks, charger and microSD

**What:** Feedback dividers, 10 pF feed-forward caps, EN pulls and the VSYS/VBATT bulk caps, placed by `bt near --each` next to the pins they serve. Charger programming resistors and status-LED resistors on the back. microSD pulls and the VDD ferrite on the back.

**Why:** Feedback networks are sensitive to noise and must stay next to the FB pins. The charger's programming resistors must sit at their pins. The microSD parts stay next to its pins.

**Result:** All placed. C7 and C12 would not fit on the front and went to the back under their buck pins with a via each. R29 landed 4.8 mm from its USB pin, which is acceptable for a series resistor.
