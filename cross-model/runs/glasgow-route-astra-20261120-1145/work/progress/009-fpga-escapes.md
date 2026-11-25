# FPGA escape review

A fine-grid pass joined 36 more connections before its first detailed DRC checkpoint. KiCad reported 62 opens and no new clearance errors. Reachability checks showed that several FX2 and FPGA pads could reach small patches of front copper, but every possible through-via site in those patches was blocked. I tested 0.40/0.20 mm vias at the remaining dense escapes, including component lands, and started changing individual obstructing tracks and vias instead of repeatedly searching the same closed spaces. These via-in-pad locations affect the fabrication process.
