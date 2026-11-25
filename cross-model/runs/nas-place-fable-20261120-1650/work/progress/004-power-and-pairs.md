# 004 – power stages, planes, Ethernet, USB
Scripted copper (`scripts/power.py`, `u12.py`, `rp.py`, `eth.py`, `usb.py`), every file probed before it was applied:
- One buck template used seven times (six mirrored on the back, the 5 V one on top): input cap straddling the SW trace right at VIN/GND, bootstrap link under the IC, ground strip with vias on the cap side, output caps flanking the inductor.
- Zones: In1 solid GND; In2 GND with islands for +12V (a strip under the buck inputs plus a branch to the two core bucks), +1V2 (under U12 and to its buck), +5V (buck to CM4 pins and fan M4) and +3.3VSTB (RP2040); back-side pours for each M.2 3.3 V rail running from the buck to the west pin group and along the top edge to the east pin group, so they do not pass under the back-layer PCIe lanes.
- U12: every supply pin has a stub and via just inside the pin ring; decaps sit radially under the ring; pin 1/32 escape outward because the corners were too tight (three probe rounds to get this clean).
- Ethernet pairs through the flow-through TVS arrays; USB pairs with the two D- pads joined behind the receptacle pads.
- First 5 V fan feed from the router tapped the feedback resistor and ran beside the PCIe reference clock on the back; thrown away and re-routed from the plane vias along y=99.6, with the feedback sense taken separately from the output cap.
