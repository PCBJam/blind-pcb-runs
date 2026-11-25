# 001 – starting point
Board as received: 254 footprints placed, no tracks, vias or zones. 4 copper layers, one net class with 0.127 mm everything, no edge clearance.

What I did before routing anything:
- Read the netlist: CM4 → ASM1184 PCIe switch (U12) → four M.2 M-key sockets (J2–J5); 12 V in through TVS + TPS2420 hot-swap; seven small bucks (5 V, 1.2 V, 3.3 VA, 4× 3.3 V M.2); RP2040 fan/LED controller with its own LDO; RJ45, USB-C, SD.
- Replaced the placeholder stackup (3 × 0.48 mm) by a real 1.6 mm 4-layer build: 35 µm outer copper, 0.1 mm 3313 prepreg, 1.265 mm core. With my own 2-D field solver, 0.15 mm / 0.15 mm gap gives ≈88 Ω differential over the 0.1 mm prepreg (PCIe 85 Ω, USB 90 Ω) and 0.127/0.2 gives ≈100 Ω (Ethernet).
- Net classes: PCIe, USB, ETH (pairs), Power (0.4 mm), Default 0.2/0.15. Board minimums: via 0.45/0.2, edge clearance 0.3 mm.
- Layer plan: F.Cu parts + signals + power pours, In1 solid GND, In2 GND (plus small power islands only where no pair runs on B.Cu), B.Cu the long PCIe runs + GND.
