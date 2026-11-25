# 008 — LED data chain and +5V_LED (trial, then applied)

Six LED data nets routed by bt route (escapes-first): all six connect. Row 1 DOUT to DIN links (14.2 mm each) and the row-2 DIN links (14.2 mm each) run on B.Cu through the gaps between the LEDs and decaps. The D401 DOUT to D701 DIN link (21.7 mm) goes down the east side of SW401/SW701 on B.Cu. LED_DIN (U106 output to D201 DIN, 30.2 mm, one via) goes round the flash on F.Cu.

Picture 008-led-chain-trial.png (scratch copy, same as applied).

Then the +5V_LED rail: 15 links, all routed, 0 to 2 vias each, 145 mm in total. This is a daisy-chain of point-to-point links, not a bus: row 1 and row 2 LEDs are joined through the channel. Several links are 15-27 mm (see 010). I did not pour +5V_LED; see NOTES.md.
