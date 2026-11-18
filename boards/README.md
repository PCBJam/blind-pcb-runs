# Boards

The original, human-routed projects the runs start from. Each folder stays under its own license; nothing here is
relicensed. KiCad 5 and 6 projects were upgraded to KiCad 10 before the runs (`kicad-cli pcb upgrade` / pcbnew
load and save); the files here are those upgraded copies.

| Folder | Board | Upstream | License | Notes |
|---|---|---|---|---|
| `macropad-top` | RP2040 macropad, 2 layers | the author's own board, first published here | CERN-OHL-P-2.0 (`LICENSE-CERN-OHL-P-2.0.txt`) | Made in an earlier AI-assisted design session (a Luna or DeepSeek model), then routed by hand by a hobbyist. |
| `h4e2` | H4E2 hall-effect keypad, 2 layers | [tg44/HALE-H8E10](https://github.com/tg44/HALE-H8E10) `hardware/H4E2`, commit 84195b2 | CERN-OHL-P-2.0 (`LICENSE-HARDWARE.md`) | Hand-routed by a hobbyist. Analog hall-sensor lines next to SK6812 LEDs. |
| `mega` | Arduino Mega 2560 with USB-C, 2 layers | [sabogalc/KiCad-Arduino-Boards](https://github.com/sabogalc/KiCad-Arduino-Boards) | WTFPL (`LICENSE.txt`) | Community KiCad recreation of Arduino's Rev3 reference design. Shows clearance errors under KiCad 10 rules. |
| `esp32-poe-iso` | Olimex ESP32-PoE-ISO Rev.O, 4 layers | [OLIMEX/ESP32-POE-ISO](https://github.com/OLIMEX/ESP32-POE-ISO) `HARDWARE/ESP32-PoE-ISO-Rev.O`, commit c19307e | CERN-OHL 1.2 (`Licensee.pdf`) | Isolated 802.3af PoE; the isolation barrier is drawn on a User.Eco layer. |
| `orangecrab` | OrangeCrab r0.2.1, 6 layers | [gregdavill/OrangeCrab](https://github.com/gregdavill/OrangeCrab) `hardware`, commit c511d56 | CERN-OHL 1.2 and MIT (`LICENCE-*`) | ECP5 in a 0.5 mm BGA with DDR3L. KiCad 5 project, migrated; the KiCad 5 schematics are kept as `.sch`. |
| `glasgow-revc3` | Glasgow Interface Explorer revC3, 4 layers | [GlasgowEmbedded/glasgow](https://github.com/GlasgowEmbedded/glasgow) `hardware/boards/glasgow/revC3`, commit 70cb38c | 0BSD (`LICENSE-0BSD.txt`) | iCE40 in a 0.8 mm BGA-121, FX2 USB 2.0 high-speed, 16 level shifters, LVDS. |
| `cm4-nvme-nas` | CM4 NVMe NAS, 4 layers | [will127534/CM4-Nvme-NAS](https://github.com/will127534/CM4-Nvme-NAS), commit 28f4e09 | MIT (`LICENSE`) | Raspberry Pi CM4 carrier with an ASM1184e PCIe switch and four M.2 NVMe slots. KiCad 6, upgraded. |
| `m2-pcie-adapter` | Antmicro M.2 to PCIe x4 adapter, 4 layers | [antmicro/m2-pcie-adapter](https://github.com/antmicro/m2-pcie-adapter), commit 11844f1 | Apache-2.0 (`LICENSE`) | Passive: an M.2 key-M edge to a PCIe x4 socket. KiCad 9, upgraded. |
| `redboard-p4-wifi` | SparkFun IoT RedBoard ESP32-P4 WiFi/BLE, 4 layers | [sparkfun/SparkFun_IoT_RedBoard-ESP32-P4](https://github.com/sparkfun/SparkFun_IoT_RedBoard-ESP32-P4) `Hardware`, commit e892e6d | Open source per SparkFun's README; the repo has no LICENSE.md at this commit. SparkFun's other boards ship their hardware under CC BY-SA 4.0. | ESP32-P4 (104-pin QFN, 0.35 mm), ESP32-C5 module, MIPI CSI/DSI, USB 2.0 HS. The MIPI and USB net classes were removed before the runs. The board outline sits inside footprint H1. |

The commit is the one the board was fetched at, where it was recorded; the Mega was copied from a local snapshot
whose commit wasn't recorded.
