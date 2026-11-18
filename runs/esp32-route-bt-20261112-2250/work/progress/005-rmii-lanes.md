# 005 – RMII bus as fixed lanes, plane vias, start of bulk routing

- RMII: second autoroute attempt (vias forbidden north of the PHY) still boxed in 4 of 9 nets, so the whole bus was
  drawn by hand. The 50 MHz clock and the TX group run on F (over the solid In1 ground) through the 4-track gap at
  the module's lower-right corner, straight down the right side and into four lanes east of the PHY. The clock
  makes one short B hop at the ESP32 pad (it needs a via there anyway for U8) so it becomes the westmost lane and
  can pass north of the PHY to pin 5 without crossing anything. RXD0/RXD1/CRS_DV use the lower-left corner gap and
  the strip west of UEXT. MDC/MDIO (≤2.5 MHz) are left to the router.
- `bt plane` added a stub+via to the planes for GND (36 vias) and +3.3V (14 vias) – 3 s each.
- Bulk `bt route --nets "*" --passes 3` started for everything else (F/B only, inner layers stay planes).
- Picture: state before the bulk run.
