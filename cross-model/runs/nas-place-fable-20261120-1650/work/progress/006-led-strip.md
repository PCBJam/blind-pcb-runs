# 006 – hand fixes after the auto-router (pictures: 006-led-strip.png, 006-fixes-switch.png)
- LED column redone by hand: straight R–LED links, one LED supply bus along the edge, CM4 LED nets as three top-layer lanes next to the Ethernet pairs, the rest brought in on the back to a via between LED rows.
- +12P pour repaired: eFuse status nets and the LED 12 V feed now leave on the back.
- Boxed-in pins solved with a via *inside* the pin ring (RP2040 pins 5, 8, 28, 36, 37; switch pins 30/31) or by moving parts: flash U17 moved 0.5 mm up so SD0/SCLK/SD3 fit under it, R33/R78 moved to open a lane for PERST#, pull-up R65 moved to the back.
- Ground: vias between the pad rows of both CM4 connectors, 9 under U12, islands joined (`bt islands --fix`), 202 stitching vias, return vias beside the PCIe layer changes.
- Nets beside PCIe pairs re-routed with keep-out boxes; a small script (`scripts/pair_neighbours.py`) lists what still runs within 0.45 mm of a pair.
- Failed attempts kept in mind: `bt tune` without `--apply` only printed its result (I believed the pairs were tuned for two hours); `bt silk --fix` pushed four references over the board edge and moved text of locked parts (restored from the original).
