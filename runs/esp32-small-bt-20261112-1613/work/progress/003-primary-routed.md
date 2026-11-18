# 003 – PoE primary side routed by hand

Wide hand-placed tracks for the cable-side circuit (script routes/010_primary.py):
* switch node L4/D5/U5.1/C12 kept as one short bottom-layer island next to the board edge;
* sense resistor R28 moved to the top side so the input current goes C27(+) -> R28 -> U5 exposed-pad via
  (the pad is on ILIM in this schematic) -> D5 -> back to C27(-): a loop of a few mm;
* 5V_DCDC goes from the inductor on In1 (1 mm) to C26, then to DCDC1 pin 1 on In1 and bottom;
* Spare1 (48 V) runs on the top layer under the RJ45 body, Spare2 reaches U2 through its exposed-pad via;
* cable shield (tabs, NC pins 7/8, C2) is a 1 mm bottom track between the primary and the signal pins,
  1.0 mm from everything else.
Earth is poured on all four layers inside the primary outline.

Problems on the way: my first version shorted U2-CDB's via onto the 5V_DCDC tracks (bt probe passed the
file because it checks new items against the board, not against each other; KiCad DRC caught it), and
`bt route` took the bootstrap net 0.98 mm past the shield tab because it does not read the custom
isolation rules. Bootstrap now hops on In1.
Result: DRC clean in the primary area, all primary nets connected (Earth through the pours).
