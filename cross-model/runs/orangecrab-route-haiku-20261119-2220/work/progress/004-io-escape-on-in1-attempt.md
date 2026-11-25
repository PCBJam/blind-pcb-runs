# 004 - FPGA I/O escape moved to In1 microvias (attempt, partly failed)

**Why.** After the DDR3 was routed, the FPGA's north, east, south and west fan exits (F.Cu rows, spaced 0.25 mm) formed
combs that no later net could cross. The rest of the I/O (SD, JTAG, QSPI, LEDs, ADC mux, USB D+/-, headers) then
failed: 'no path', 'boxed in'. Changing the router's order (hardest first, escapes first, moving board copper,
rip-up of the DDR3 routes first) did not help. Changing the fan's second row to B.Cu or to a single row did not help
either (76 pins left, because the B.Cu decoupling pads under the FPGA take the dog-bone sites).

**What I tried.** Unroute the I/O nets (all signal nets except DDR3, power and GND), give each I/O ball a blind
microvia F.Cu->In1.Cu at an interstitial site with a 0.089 mm stub (`bga_sites.py --only-sig`, 59 balls solved), and
route the I/O nets on In1, F, In2, B.

**Result.** First run: 25 of 74 nets routed in pass 1, then the pass-2 shove retries made no progress and I stopped it.
Picture: `004-io-escape-on-in1-attempt.png` (In1 green, F red, B blue).

**Why it is only partly working.**
- `bt` sees every microvia as a through hole. With the 126 ground microvias in the file, the router treated In2, In3,
  In4 and B as blocked at each microvia site: 2 of 17 routed. Removing them from the routing copy and using
  --avoid boxes (F.Cu, In1.Cu) helped, but the boxes around neighbouring interstitial sites (0.5 mm apart) close every
  orthogonal gap, so a track can't leave an inner microvia on In1.
- The 'MST batch' attempt (one request per edge from the microvia point on In1) is also blocked for the same reason:
  'the start is boxed in' for most nets.
- Conclusion: at 0.5 mm pitch, microvias on every interstitial site close the In1 layer; only the outer ring of
  microvias has a way out. The field needs fewer microvias (bridged ground balls) or a different escape.
