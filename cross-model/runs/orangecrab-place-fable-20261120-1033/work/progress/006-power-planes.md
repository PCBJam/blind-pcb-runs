# 006 – planes, power stubs, bucks, USB

What
- In1 and In3: GND over the whole board. In4: islands for 1V1 (FPGA core, fed from the buck west of
  the FPGA), 3V3 (north / west / south-west), 1V35 (right end + south edge + a strip under the
  FPGA's east rows), RAM_VDD (north half of the RAM, extended to its ferrite and bulk caps) and
  RAM_VDDQ (south half, same). The islands were reshaped once after `bt plane` reported which cap
  pads "miss the pour".
- `bt plane` added a stub and a 0.3/0.15 via per GND / power pad outside the BGAs (GND: 93 of 100
  pads, 51 vias, neighbours share).
- Buck loops (Cin-VIN/GND, SW-L, L-Cout, FB dividers) routed on B.Cu with 0.3-0.5 mm tracks.
- VBATT 0.3 mm on F.Cu, VBUS and VSYS 0.4 mm (VSYS runs on In4 along the top edge to the right end).
- USB: the FPGA-side pair goes from the via row north of the FPGA on In2 to the 20R resistors in
  the corridor north of the JTAG header (`bt pair`); the connector side needs four vias in front
  of J3 because the USB-C pad order interleaves D+ and D-.

Failed / changed
- LED D2, its resistors and the CC resistors first sat exactly where the USB lines must leave
  J3; moved (D2 east of the charger, CC resistors and the SD supply filter to the bottom, south of
  the socket).
- A batch of 121 "pad to nearest copper of its net" route requests never finished (stopped after
  9 minutes); `bt plane` did that job in seconds.
- First whole-board `bt route --nets "*"` at 0.12 mm: most nets "boxed in" at the 0.09 mm BGA
  stubs, and the run hit the 10-minute background limit in pass 1; rerun at 0.1 mm with necks.
