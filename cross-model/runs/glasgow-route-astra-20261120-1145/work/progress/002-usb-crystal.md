# USB and oscillator

Routed the USB-C A6/A7 data path past the ESD device U15 to the FX2 on front copper. The alternate contacts and rear test lands join close to the receptacle. The first probe found clearance conflicts around the bypass capacitor and USB pads. Moving the negative-side bend between U15's pad rows and delaying the positive-side neck cleared them. Both 24 MHz crystal nets are on the front, with no vias. The picture shows the accepted geometry before adding planes.
