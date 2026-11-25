# Controller escapes

The global signal pass left several RP2040 pins surrounded by existing routes. I placed short individual via escapes at those pins, removed three obstructing low-speed nets, and rerouted them. This pass connected the temperature, reset, and several fan-control links. Some vias still led into enclosed areas on the back. The subsequent pass addresses those locally.
