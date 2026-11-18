# 005 – secondary power distribution and PHY supplies

* 3.3 V: first tried `bt route --all` over B/In2/F. It produced bottom-layer "rails" that boxed in the
  ADC divider row and left the net in 16 pieces, so that result was thrown away. Now hand-drawn: one via
  per consumer and a 0.5 mm tree on In2 that stays clear of the Ethernet pairs' reference area.
* 3.3VLAN (switched PHY supply): bottom-layer from FET3 to the RMII pull-ups and C9, short In2 hop
  under the PHY to VDDIO/C14/RM1 and the VDDA ferrite.
* VDDA: one branch north of the RD pair to PHY pin 1, one south of the TD pair to pin 27; the jack-side
  centre-tap caps hang on the south branch.
* Local power (5VP, 5V, VBAT, buck SW/FB) was auto-routed with bt on the bottom layer; the buck was
  re-arranged first so SW leaves between the input capacitor pads and VIN/GND sit on the cap.
* PHY top-side fan-out (VDDCR, straps, RBIAS, nRST) by hand: the autorouter boxed pin 7 in twice.
DRC: 0 errors; about 60 signal nets still open.
