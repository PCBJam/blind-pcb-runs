# 007 – the power layer came back in pieces
After the staged routing every net was connected by tracks, but the real KiCad DRC (zones refilled) reported 1.1V in 4 pieces and 3.3V in 6:
the router had used In2 not for "short hops" but for ~340 mm of signal track, a lot of it inside the 1.1V island under the P4 and around its pad ring.
The picture is In2 around U1 at that point: the island's west strip, its south edge and the neck to the buck converter are cut off by signal tracks.
What I did:
- tried to take all signal tracks off In2 near U1 and re-route them on F/B only: 4 of 20 nets came back, so that was undone;
- instead removed the three worst cuts (VDD_SD across the island, SD_PWR across the neck, SCK down the east edge), re-routed those (SD_PWR is now a 98 mm detour),
  and joined the remaining plane pieces with explicit 1.1V / 3.3V tracks, 3.3V links being kept off the island area (`--avoid` on In2);
- every link changed the fill, so this took several refill/DRC rounds (one link for 3.3V would cut 1.1V and the other way round).
