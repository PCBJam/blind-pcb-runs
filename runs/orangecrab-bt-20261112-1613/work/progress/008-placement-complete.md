# 008 – placement after the re-plan (before signal autoroute)
Top: USB-C / JST / charger + 3.3 V buck (left), FPGA, DDR3, button + RGB LED (right).
Bottom: 1.1 V buck under the JST, mux U9 and flash U6 left of / under the FPGA edge, FPGA decoupling under the BGA, 1.35 V buck + DDR ferrites/bulk at the right end, 2.5 V LDO below the FPGA. Nothing on the bottom under the DDR (silkscreen crab logo) except vias.
All BGA escapes for the top and bottom-left FPGA blocks are hand-placed stubs/vias; the rest is left to `bt route` in batches, re-ordered when nets fail.
