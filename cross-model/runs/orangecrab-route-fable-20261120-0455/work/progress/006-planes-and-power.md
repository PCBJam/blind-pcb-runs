# 006 – Planes, pours and the supply section

- In1 and In3: solid GND planes (whole board).
- In4: split power plane.
  - P3.3V is the base fill.
  - P1.1V: FPGA core box plus a corridor down the west side of the FPGA to the 1.1 V buck (L1/C15/C17).
  - P1.35V: a "C" around the FPGA core (north strip from the 1.35 V buck, east side, south side), a strip along the bottom edge to FB2/FB3 and a strip along the top edge to the VREF divider / button pull-up on the far right.
  - RAM_VDD: under the north (address) half of U4, down U4's centre channel and a feed strip between the two BGAs; RAM_VDDQ: under the south (data) half of U4.
- In2: small P1.35V pour under the FPGA core only (no signals there) so that the 1.35 V balls/caps that sit inside the 1.1 V box on In4 still see a plane.
- F.Cu: GND pour, plus small solid pours at each buck output (L1/L2/L3 + output caps). B.Cu: GND pour and a VSYS pour under the microSD socket that joins the charger output to the three buck inputs.
- `bt plane` dropped a via per power pad into its plane (about 80 vias incl. GND), `bt islands --fix` and `bt route --net X --all` joined what was left.

Result: every supply net is one piece except three leftovers found at this point (C52.1 on P1.1V, C26.2/C64.2 ground pads) – see the final notes for their status.
