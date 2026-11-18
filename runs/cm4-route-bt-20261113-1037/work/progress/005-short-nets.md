# 005 – Short nets by bt route
First attempt: all 129 remaining nets in one `bt route --nets` call with --seconds 20: ran >10 min with no visible output, killed (thrown away, nothing was written).
Second attempt in batches: 75 nets under 13 mm in 44 s (one failure, /QSPI_SD1), then the seven boot-cap/SW nets at 0.25 mm. All probe-clean.
Picture: board with pours, PCIe, and the short nets; green dashes = still open.
