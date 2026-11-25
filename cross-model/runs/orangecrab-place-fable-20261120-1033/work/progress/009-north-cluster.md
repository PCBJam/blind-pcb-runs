# 009 – north side of the FPGA: LEDs on In4, ADC fan, several thrown-away attempts

**Problem.** The ADC/mux, SD and analog-header balls sit on the north edge of the FPGA, their
parts are west and south-west. About 20 nets have to turn round the north-west corner of the
ball field, where the 1V1 buck's vias already stand, and eight in-field vias (rows 3/4) are
fenced in by their neighbours.

**Attempts that failed (all undone):**

1. One net at a time with `bt route` (In2+F+B): the first nets take the diagonal lanes under
   the FPGA, later ones fail or detour (ADC_CTRL1 33 mm for 15 mm, ADC_CTRL0 7 vias).
2. `bt route --nets ... --passes 3` over 22 nets: pass 1 failed 12 of them ("start is boxed
   in"), passes 2/3 made SD0_CMD 43 mm and SD0_DAT2 8 vias. Stopped, board restored.
3. Forcing the SD nets round the north (avoid box on the corner): only 1 of 6 found a way
   (VSYS and USB copper in the north strip).
4. LED resistors: no through-via site exists next to R22/R24 (VSYS track on In4, header IO on
   the bottom, DDR address lines on top), so the autorouter could never end LED_R/LED_B.

**What I did by hand:**

* Swapped two in-field vias (SD0_DAT1 and IO_A0) so that LED_R is not fenced in any more, and
  removed one redundant GND mesh link for it.
* Laid 5 lanes through the GND via lattice under the FPGA (3 between two via columns going
  south, then west between two via rows): IO_A0, SD0_DAT1, IO_A3, ADC_MUX0, ADC_MUX1.
* LEDs: In4 (inside the 3V3 plane, which is also the LEDs' supply) from the in-field vias to
  three vias north-east of the ball field, then top layer through the gap between the
  oscillator's pad rows (two 0.09 tracks) and along the north edge. A redundant 3V3 link
  between the oscillator pads and one stitching via were removed for it.
* The five outer-row ADC nets get a small fan into four vias that fit between the LED lanes
  on In4 (found with a `bt probe --vias` grid: 5 of 77 sites were free).
* SD: the single-net router did all 7 once the cluster was open (10-25 mm, 1-2 vias a link).

**Result.** LEDs, SD connected. The remaining IO_A/ADC nets are given to the batch router with
In4 allowed inside the 3V3 plane (see next entry).
