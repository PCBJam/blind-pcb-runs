# 003 – PCIe: switch fanout, AC-cap hops, socket breakouts, long pairs
Hand-generated (scripts gen_pcie.py, gen_sock.py, gen_long.py), checked with `bt apply --checked`.
- Every pair is on F.Cu over the In1 ground plane. Only the AC-coupled pair of each port dips to B.Cu for ~4 mm at the switch (through its 0402 caps) - that hop is what lets it cross the other data pair, which the pin orders otherwise make impossible on one layer.
- At each socket RX/TX pass through the M-key gap in both pad rows and U-turn onto the pads from the board-edge side; REFCLK enters between the rows from the gap between sockets.
- First try failed the probe: 45° jogs of a pair were drawn with equal corner y for both tracks (gap fell to 0.047 mm). Fixed with a proper mitred parallel offset.
- Intra-pair skew of data pairs was 0.85–2.9 mm (the U-turn); compensated with a bump on the short track between the socket rows: now < 0.01 mm on all data pairs. REFCLK pairs left at ≤ 0.31 mm (1.43 mm on port 4).
