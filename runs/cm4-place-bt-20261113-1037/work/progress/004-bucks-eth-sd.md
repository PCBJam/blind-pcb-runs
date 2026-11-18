# 004 – buck converters, Ethernet, USB, SD, trunks
- Nine TPS563202 blocks drawn from one template (gen_buck.py): input cap straddling VIN/GND pins with SW leaving between its pads, boot cap under the IC, output through vias into an In2 island, feedback taken from the island through its own via.
- First template failed the probe: SW (0.6 mm) ran 0.05 mm from the VIN/GND links, the output track clipped the output-cap ground pad. Narrowed SW at the pins, moved the output track.
- The two switch bucks collided (vias) with the PCIe pairs running above them on F.Cu; moved U2 east/down and U15 south of the upstream lanes. Their 12 V comes as a bottom-layer track so In2 stays ground under the PCIe hops.
- Found late that the project has `courtyards_overlap` set to "ignore": my "clean DRC" after placement did not check overlaps. A scratch-copy DRC with the rule on (scripts/cy.sh) showed 19 overlaps (input caps of every buck, a few decaps, strap resistors); all fixed, and the check is now part of every round.
- Ethernet: four pairs straight through the two ESD arrays (flow-through) to the CM4, no vias, no crossings. USB2: choke at the connector, pair on top down to the CM4.
- SD: `bt bus` could not do it on one layer (2 of 6 failed) - the pin orders really do not allow it. Hand-routed between the two pad columns of the CM4 connector; DAT3 takes a short bottom hop, DAT2 goes round the socket.
- Multi-drop nets (M2PWR_EN, PCIe_RST_M2, LED_V+) got hand-planned bottom-layer trunks after the autorouter spent >3 min on them and failed.
