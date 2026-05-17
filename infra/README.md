# Infrastructure as Code

This directory contains Bicep templates for the Azure Governance Baseline.

The initial implementation focuses on a lightweight, low-cost validation environment. It is intended to demonstrate structure, scope separation, parameterization, and validation flow rather than a full production landing zone.

## Structure

```text
infra/
├─ main.bicep
├─ modules/
│  ├─ monitoring/
│  ├─ network/
│  ├─ policy/
│  ├─ rbac/
│  ├─ resource-groups/
│  └─ tagging/
└─ parameters/
   ├─ dev.bicepparam
   └─ lowcost-demo.bicepparam
```

## Scope

The initial Bicep entry point uses Subscription scope.

Main deployment targets:

- Resource groups
- Log Analytics Workspace
- Minimal network resources
- Custom policy definitions
- Policy assignments
- Optional RBAC assignment
- Common tags

## Parameters

| File | Purpose |
|---|---|
| `parameters/dev.bicepparam` | Standard development validation parameters |
| `parameters/lowcost-demo.bicepparam` | Lower-cost demo parameters |

Parameter files must not contain real tenant IDs, subscription IDs, user names, principal IDs, customer names, or internal environment identifiers.

## Build

Run Bicep build from the repository root.

```powershell
az bicep build --file .\infra\main.bicep
```

Generated JSON files are ignored by `.gitignore`.

## Deployment Flow

Use the Azure CLI runbooks under `scripts/cli/`.

Recommended flow:

```text
Set context
  ↓
What-If
  ↓
Deploy
  ↓
Validate
  ↓
Record evidence
  ↓
Teardown when no longer needed
```

## Design Notes

- Bicep is used as the primary IaC language
- Azure CLI is used for deployment and validation
- PowerShell 7 is used as the local runbook execution environment
- Policy assignments start with Audit-first behavior
- RBAC assignment is disabled by default unless a principal is provided
- Deployment should be removable after validation

## Review Points

When reviewing this directory, check whether the following points are clear.

- The deployment scope is explicit
- Modules are separated by responsibility
- Parameter files are safe for public repository usage
- The implementation matches the design documents
- The deployment can be validated and removed safely
