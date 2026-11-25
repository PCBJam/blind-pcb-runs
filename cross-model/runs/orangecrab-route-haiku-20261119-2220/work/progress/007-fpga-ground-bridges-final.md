# 007 - FPGA ground: bridged groups instead of one microvia per ball

**Problem.** 126 ground microvias (one per ground ball, each with an F.Cu stub) filled almost every interstitial site of the
FPGA field, so no I/O track could leave an inner microvia on In1 (see 004).

**Change.** `gnd_bridges.py` replaces the per-ball stubs with F.Cu bridges between orthogonally adjacent ground balls
(0.089 mm, clear of every other F.Cu copper and pad by the board clearance). A spanning forest of the 127 ground balls gives
111 bridges and 16 groups; each group gets one blind microvia F.Cu->In1.Cu with one stub. `bt probe` cleared all 127 new
items; the old 126 stubs and microvias were removed with `bt rm --uuid` and a text edit.

**Result.** 16 ground microvias instead of 126; In1 is open in the FPGA field again. Routing afterwards: 7 I/O nets routed
in pass 1, 36 failed (the west edge: the 51R resistors on B.Cu and the JTAG/SPI copper box in the /IO/A2, A3 and
JTAG pads). Three new copper errors came from those routes and were removed: a SPI_CONFIG_SS track on In1 through two
ground microvias (short), an ECP5_VREF track on In1 touching a ground microvia (clearance), and a VSYS track on F.Cu in
the solder-mask opening of mounting hole H2. After removal: no shorts, clearance or mask errors.

**Picture:** `007-fpga-ground-bridges-final.png` (FPGA field: F.Cu bridges in red, microvia sites where the F stubs end).
