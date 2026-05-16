# AVD Operation Scripts

This directory contains PowerShell scripts for AVD operational standardization examples.

The scripts are intended to demonstrate operational safety patterns such as pre-check, dry run, skip reason, and result output.

## Planned Scripts

```text
Remove-AvdSessionHostResources.ps1
Set-AvdPersonalDesktopAssignment.ps1
Export-AvdHostPoolInventory.ps1
Start-AzVmFromCsv.ps1
```

## Script Design Policy

- Use sample input files only
- Do not commit real tenant IDs, subscription IDs, host pool names, user names, or customer-specific values
- Prefer dry-run mode before actual execution
- Output result files for evidence
- Record skipped targets with clear reasons
- Do not treat scripts as a replacement for approval or change management
