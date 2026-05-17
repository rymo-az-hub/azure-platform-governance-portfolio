# AVD Operations Standardization

This directory contains operational standardization examples for Azure Virtual Desktop.

The AVD content is a secondary theme. It shows how CloudOps practices can be applied to real operational tasks such as inventory, pre-check, dry run, execution, result output, troubleshooting, and customer communication.

## Positioning

This section is not intended to present AVD architecture as the main scope of the repository.

It is an applied example of the Azure Governance Baseline. The goal is to show how operational tasks can be made safer, more repeatable, and easier to review.

## Documents

| Document | Purpose |
|---|---|
| `avd_ops_design.md` | Defines the overall design policy for AVD operations standardization |
| `inventory_and_precheck.md` | Defines inventory and pre-check points before operation |
| `sessionhost_lifecycle.md` | Defines SessionHost deletion, cleanup, and lifecycle operation points |
| `personal_desktop_assignment.md` | Defines AssignedUser assignment checks and execution policy |
| `troubleshooting_flow.md` | Defines AVD connection troubleshooting flow |
| `operation_checklist.md` | Provides a general checklist for AVD operations |
| `customer_response_template.md` | Provides customer-facing response templates |

## Related Scripts

Public script skeletons are stored under `scripts/avd/`.

| Script | Purpose |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | Exports HostPool and SessionHost inventory |
| `Remove-AvdSessionHostResources.ps1` | Performs DryRun-first SessionHost removal workflow |
| `Set-AvdPersonalDesktopAssignment.ps1` | Performs DryRun-first Personal Desktop assignment workflow |
| `Start-AzVmFromCsv.ps1` | Starts VMs from CSV with pre-check and result output |

## Design Policy

The AVD operational standardization follows these principles.

- Clarify operation targets by CSV or parameters
- Run pre-checks before changes
- Use DryRun before execution
- Record skip reasons
- Output results for evidence
- Do not include customer-specific values
- Do not treat scripts as a replacement for approval or change management

## Review Points

When reviewing this section, check whether the following points are clear.

- Operation targets and prerequisites are explicit
- User impact is considered before execution
- DryRun and execution modes are separated
- Result output can be used as evidence
- Customer responses separate confirmed facts from assumptions
