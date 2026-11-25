# 009 – Final state

Pictures: `009-final.png` (all layers) and one per copper layer (`009-final-F.Cu.png`, `-In2.Cu`, `-In3.Cu`, `-In4.Cu`, `-B.Cu`).

- 436 vias, ~2800 track segments, 14 zones.
- KiCad DRC vs. the original board: 0 new errors, 17 warnings (dangling stubs of unfinished nets), 29 unconnected items in 23 signal nets plus two capacitor pads.
- Last steps: letting P2.5V and ECP5_VREF use In3 connected both in seconds after every attempt on the three signal layers had failed; the same trick got four more signal nets (USB D+ connector side, SD0_CD, LED_B, ADC_SENSE_HI). The remaining nets are boxed in at their first or last pad and need rip-up of neighbours.
- Not done: DDR length tuning, widening tracks outside the BGAs, ground stitching, the 23 open nets. See NOTES.md.
