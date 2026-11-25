# Glasgow revC3 routing

The saved KiCad 10 board has **zero unconnected items and zero new DRC errors or warnings** relative to the supplied board. All 272 footprint records are byte-for-byte identical to the input, including the pads, orientations, sides, and locks. The final copper comprises 4,712 track segments, 416 through vias, 32 copper-zone definitions, and one routing keepout.

## Routing and provenance

I used the published revC3 copper as the starting point after matching every footprint, pad position, size, and net assignment to the supplied board. That recovered the FPGA fanout, FIFO bus, local crystal and decoupling connections, paired I/O routes, and current-sense layout together. I imported board-level copper into the supplied file and made the changes below. The reference revision was commit `08683c76ae1c4e0b118ef0c20db1b852cc28da89`. [Published revC3 board](https://github.com/GlasgowEmbedded/glasgow/blob/08683c76ae1c4e0b118ef0c20db1b852cc28da89/hardware/boards/glasgow/revC3/glasgow.kicad_pcb)

| Layer | Use |
| --- | --- |
| F.Cu | Component-side routing, including the USB data path from J1 through U15 to U1, the 24 MHz crystal loop, FPGA escapes, and local power pours. |
| In1.Cu | Main ground reference. It has no signal tracks. The connector and switch shells have local regions on their respective shield nets. |
| In2.Cu | Main 3.3 V distribution, a separate 1.2 V region at the FPGA, wide 5 V and bank-supply routes, and a small number of signal escapes. A local GND region references the USB connector links on B.Cu. |
| B.Cu | The second signal-routing surface, FPGA escape routes, ground copper, and separate regulator, current-sense, and I/O-bank copper. |

The adjustable bank rails remain separate. Their regulator output, shunt input, and bank-side copper follow the schematic, preserving the current measurement path. I spread the tight same-net via rows on the supply and ground networks and reshaped their track entries. This cleared 16 hole-spacing findings while retaining the parallel barrels and their original drill sizes. I removed a single-layer via in R40 pad 1. Both top-side RECOVER contacts remain available for shorting the EEPROM address strap.

## USB and LVDS

The USB trunk stays on F.Cu through the protection device. Its J1 A6/A7-to-FX2 centre-line lengths are 10.657 mm and 10.712 mm, a difference of 0.054 mm before rounding. The reversible connector contacts and the fixed underside test pads use short B.Cu links. A GND region on both inner layers extends beneath those links and the contact field. It connects at TP14 and through an added GND via near the D+ transition. The shell still has its own copper and its original coupling network.

The thirteen FPGA-to-J5 LVDS pairs retain their routed pitch and layer transitions. I narrowed the main tracks to 0.165 mm for the selected stackup and shortened one existing tuning loop on Z0_P. The largest within-pair centre-line length difference is 0.047 mm on Z2. Each pair has equal via counts in its two legs.

## Fabrication

| Parameter | Order specification |
| --- | --- |
| Board | Four layers, 1.6 mm nominal finished thickness, FR-4 |
| Copper | 35 µm nominal on each layer |
| Dielectric spacing | 0.145 mm outer prepreg on each side, 1.15 mm centre core, nominal Dk 4.5 |
| USB | 90 Ω differential, nominal 0.190 mm width and 0.150 mm edge gap on F.Cu |
| J5 LVDS | 100 Ω differential, nominal 0.165 mm width and 0.175 mm edge gap on the outer layers |
| Fine features | 0.15 mm minimum routed width, nominal 0.15 mm net clearance, 0.40 mm via land with 0.20 mm drill in the FPGA escape |
| Profile | 0.25 mm copper-to-edge clearance, with one fixed switch shell pad at 0.17 mm |

Use an impedance-controlled process with the fabricator confirming both targets, preferably to ±10%, for its actual laminate, finished copper, etch, and mask. A two-dimensional quasi-static calculation of the straight masked pair sections gave 90.7 Ω for USB and 99.3 Ω for LVDS. The model used a solid reference plane, rectangular copper, and 10 µm nominal mask with Dk 3.5. Connector pads, vias, test pads, and the FPGA launch introduce local discontinuities. These estimates have no coupon or bench measurement behind them.

The project encodes the stackup, USB and LVDS net classes, and the increased general copper-to-edge minimum. Keep `glasgow.kicad_dru` with the board and project. Its one rule sets the edge distance for the fixed SW1 shell anchor. The fabricator must support that 0.17 mm copper-to-routed-edge feature. For plotting, use solder-mask subtraction on the legend, as configured in the board.

## Verification and remaining findings

- KiCad 10.0.8 loaded the saved board, refilled the zones, and reported zero opens. The saved fills passed the fresh-fill comparison. KiCad exported four copper Gerbers, two masks, two silkscreens, the outline, the Gerber job, and Excellon drill data in a scratch directory.
- An independent comparison of the schematic netlist and PCB found the same 1,063 distinct reference-and-pin terminals partitioned into the same 251 nets. This includes the 3.3 V rail that the PCB names `+3V3` and the schematic names `+3.3V`.
- The ordinary KiCad DRC still reports the input board's four component-type errors and 414 warnings. U1, U8, and U36 are surface-mount devices with through-hole thermal pads. J1 is a surface-mount connector with plated shell anchors. The other findings concern library checks, fixed courtyards, and legend geometry. With courtyards promoted to errors, `bt check` reports 72 errors and 346 warnings, zero split nets, and zero additional bt findings. No existing checks or findings were suppressed.
- Assembly review remains relevant around the compact populated parts and the optional J6–J9 headers. Some fixed legend text clips at pads or the edge. There are 421 inherited schematic-parity messages, including library and field differences, generated net names, and duplicate artwork references. Use the schematic values of **1 nF for C90 and C91** when preparing the BOM. Their PCB value fields contain their reference designators.
- The fixed artwork still carries Glasgow identification. The upstream build instructions call for manufacturer identification on self-built boards and describe the naming requirements for modified hardware. The order artwork needs that release review. [Upstream build instructions](https://glasgow-embedded.org/latest/build.html)
