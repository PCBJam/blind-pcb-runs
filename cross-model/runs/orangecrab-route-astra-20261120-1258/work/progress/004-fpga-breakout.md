# FPGA signal escapes

I added 98 short ECP5 escapes, concentrating on interior signal and supply balls. Each candidate had to clear the decouplers on the reverse. Three via sites are close to or inside their originating land, which calls for filled and capped vias. KiCad found no clearance violations or shorts in the added geometry. The new dangling-via findings were expected at this stage because many vias still had only their top-layer stub.

The first search for a coupled LDQS trunk from these exits could not find a complete path. I kept the legal escapes and left that connection for the next routing pass.
