# 007 – Final state
After the control bus: signal strip between the 12 V and 5 V buses (M.2 enable, fan 4, NTC lines, with B.Cu hops under the buses), RP2040 fan-out by hand,
M.2 reset bus on B.Cu along the top edge, LED supply around the perimeter, remaining stubs by `bt route` one net at a time.
Then ground: GND zones set to solid for SMD / thermal for through-hole, 173 pad vias (`bt plane`), 51 vias at the M.2 GND pins, 22 return vias at PCIe layer changes, 269 stitching vias.
Several feedback traces had to be moved because the autorouter had fenced ground pads in.
KiCad DRC: no clearance/short/unconnected copper errors; left: 1 link between the two halves of the USB-C (J7) shield pads, plus warnings that were already in the unrouted board.
Pictures: all layers, and one per copper layer.
