# 006 – finished board, all layers
- GND: solid plane on In1, plane on In2 (minus three islands), pours on F.Cu and B.Cu. 164 pad vias (`bt plane`), 300 stitching vias on a 4 mm grid (`bt stitch`), extra return vias next to the PCIe layer changes.
- Seven GND pads were fenced in by other copper. Fixed one by one: an inside via, a thin link squeezed between two tracks, and for the three M.2 bucks the feedback sense trace was re-routed so the divider's ground pad gets a top-layer link to the output-cap ground (no via possible there: PCIe pairs run underneath).
- First KiCad DRC: 8 errors – 4× hole clearance inside the USB-C footprints (my own 0.2 mm rule; set to 0.15) and 4× starved thermals where a pour reached a through-hole GND pin with one spoke (small pour keep-outs added; the pins are on both inner planes).
- Intra-pair skew tuned with `bt tune`: all 15 PCIe pairs ≤0.17 mm, USB 0, Ethernet 0.
Final: KiCad DRC 0 errors / 0 warnings new against the board as received, 0 unconnected. 2708 segments, 756 vias, 20 copper zones + 5 pour keep-outs.
