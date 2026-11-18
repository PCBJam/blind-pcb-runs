# 009 – Remaining FPGA sides, core rail, bulk of the signals
- East/south BGA escapes scripted: QA/QB fans to the 33R arrays on F.Cu, bank-A DIR lines as a B.Cu "staircase" of columns, bank-B DIR lines
  on B.Cu from a via staircase south of the BGA. Four static lines that cannot be made planar (DA0, DB0, DB1, AUX R39/R43) use In2 hops.
- +1V2: 0.4 mm B.Cu trunk from the regulator to C14; under the FPGA the four VCC balls/caps are joined on B.Cu plus 0.1 mm In2 necks threaded
  between via columns; R32 gets it through a via in its pad. Found and fixed: my B.Cu bus lanes had fenced in the PLL0 filter (C76/R31) –
  lanes moved south of R31, GNDPLL0/+1V2 hop underneath on In2.
- `bt route --nets` (single pass, 6 s per net) then did 28 of the 38 remaining signal nets. A 2-pass run on +1V2 earlier had pushed other
  tracks around under the BGA and laid +1V2 on F.Cu between balls; I restored the board from my copy and did that part by hand.
- Still open after this step: SCL/SDA, ALERT, ENVA/ENVB, VDAC A/B, U4/U5 LEDs, R10 net, power/GND stitching, outer pours.
