# 006 – autoroute of the remaining signals (discarded)
Power trunks (VIN, VRAW, 3.3V_P, 5V) went in with `bt route` on B.Cu; around the LM66200 the router had used 0.122 mm necks for the main supply path, replaced by hand.
Then `bt route --nets` for the GPIO/I2C/reset groups: 14 of 28 nets, with 45–66 mm wandering routes under the processor (SD_DET 65 mm/3 vias, IO6 66 mm, CAM_IO 5 vias) and half-written copper from nets that then "gave up", which blocked the six ADC lines completely (0/6).
Cause is my own escape pattern on the right side (alternating ring/outside vias trap the ring nets) plus the flash Q/WP tracks on B.Cu cutting off the north-east. Decision: rip all of this batch and restructure (next entry). Picture: B.Cu round U1 before the rip.
