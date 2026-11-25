# 011 — rails merged onto the working board (VIOA, VIOB, +1V2, +5V, VIO_AUX/VUSB partial)

Each rail was routed on its own copy of the board and then merged with `bt apply --checked`; every
merge probed clear. Results: VIOA 30/30 (77 mm), VIOB 31/31 (88 mm), +1V2 11/11, +5V all links (about 60 mm,
two vias on the long run). VIO_AUX: its E4-G4 link is in, the cap C33 and the J5.44 link are still open.
VUSB: 2 of 4 pads joined; the U15 pins are boxed in between the USB tracks and the GND via on U15.2.
