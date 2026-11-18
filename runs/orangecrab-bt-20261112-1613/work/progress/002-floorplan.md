# 002 – floorplan
FPGA (U3) at 162.25,103 rot -90 so the DDR bank (rows A-D, cols 13-18) faces right, SD/USB/ADC balls face the top-left, QSPI/SPI faces bottom-left, JTAG faces the header.
DDR3 (U4) at 174.4,103 rot 180: address rows next to the FPGA address balls, data rows next to the data balls.
Charger U5 + 3.3 V buck U7 top-left under the JST (close to VBUS/VBAT/3V3 pin), flash U6 on the bottom under the QSPI balls, ADC mux U9 on the bottom left of the FPGA, button + RGB LED at the right end (the silk "btn0" text and the copper OSHW logo fit between the switch pads).
Oscillator first went on the bottom in the FPGA-DDR gap; later moved to the top above the gap because the gap is needed for escape vias.
