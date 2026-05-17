# Azure Platform Governance Portfolio

This repository provides a practical design and implementation example for a lightweight Azure platform governance baseline.

The main theme is **Azure Governance / Policy Baseline** for a mid-sized organization using Azure. The secondary theme is **AVD operations standardization**, positioned as an applied CloudOps example based on common operational scenarios.

## Purpose

This repository is intended to show how Azure platform operations can be standardized through design documents, Infrastructure as Code, runbooks, ADRs, and evidence.

The focus is not only on creating Azure resources. It also explains why specific controls are required, how they should be operated, and how operation results should be recorded.

## Target Scenario

The assumed scenario is a mid-sized organization that has started using Azure and wants to introduce minimum platform governance before Azure usage expands further.

The initial scope is intentionally lightweight. It focuses on a single Subscription-level baseline rather than a full Enterprise Scale Landing Zone.

## Main Theme: Azure Governance / Policy Baseline

The main design area covers the following topics.

| Area | Document |
|---|---|
| Requirements | `docs/01_main_azure_governance_baseline/requirements.md` |
| Governance design | `docs/01_main_azure_governance_baseline/governance_design.md` |
| Policy baseline | `docs/01_main_azure_governance_baseline/policy_baseline.md` |
| RBAC design | `docs/01_main_azure_governance_baseline/rbac_design.md` |
| Tagging standard | `docs/01_main_azure_governance_baseline/tagging_standard.md` |
| Monitoring and logging | `docs/01_main_azure_governance_baseline/monitoring_logging_design.md` |
| Cost notes | `docs/01_main_azure_governance_baseline/cost_management_notes.md` |
| Exception operation | `docs/01_main_azure_governance_baseline/exception_operation.md` |
| Validation plan | `docs/01_main_azure_governance_baseline/validation_plan.md` |

## Secondary Theme: AVD Operations Standardization

The AVD section provides examples of operational standardization.

This section is not the main scope of the repository. It is positioned as an applied CloudOps example that connects governance, operation design, automation, evidence, and customer-facing communication.

| Area | Document |
|---|---|
| AVD operations design | `docs/02_sub_avd_operations_standardization/avd_ops_design.md` |
| Inventory and pre-check | `docs/02_sub_avd_operations_standardization/inventory_and_precheck.md` |
| SessionHost lifecycle | `docs/02_sub_avd_operations_standardization/sessionhost_lifecycle.md` |
| Personal Desktop assignment | `docs/02_sub_avd_operations_standardization/personal_desktop_assignment.md` |
| Troubleshooting flow | `docs/02_sub_avd_operations_standardization/troubleshooting_flow.md` |
| Operation checklist | `docs/02_sub_avd_operations_standardization/operation_checklist.md` |
| Customer response template | `docs/02_sub_avd_operations_standardization/customer_response_template.md` |

## Implementation

Infrastructure as Code is written in Bicep.

Azure operations are executed mainly through Azure CLI. Windows + PowerShell 7 is used as the local execution environment for runbooks and helper scripts.

| Area | Path |
|---|---|
| Bicep entry point | `infra/main.bicep` |
| Bicep parameters | `infra/parameters/` |
| Bicep modules | `infra/modules/` |
| Azure CLI runbooks | `scripts/cli/` |
| AVD operation scripts | `scripts/avd/` |
| Local quality check | `scripts/local/Test-RepositoryQuality.ps1` |

## Repository Structure

```text
.
├─ docs/
│  ├─ 00_overview/
│  ├─ 01_main_azure_governance_baseline/
│  ├─ 02_sub_avd_operations_standardization/
│  ├─ 03_adr/
│  └─ 04_evidence/
├─ infra/
│  ├─ main.bicep
│  ├─ modules/
│  └─ parameters/
├─ scripts/
│  ├─ cli/
│  ├─ avd/
│  └─ local/
├─ .vscode/
├─ .gitignore
└─ .gitattributes
```

## Reading Guide

Recommended reading order:

1. `docs/00_overview/architecture_overview.md`
2. `docs/00_overview/design_principles.md`
3. `docs/01_main_azure_governance_baseline/requirements.md`
4. `docs/01_main_azure_governance_baseline/governance_design.md`
5. `docs/01_main_azure_governance_baseline/policy_baseline.md`
6. `infra/main.bicep`
7. `scripts/cli/README.md`
8. `docs/04_evidence/06-validation-summary.md`
9. `docs/03_adr/adr-001-landing-zone-lite-scope.md`
10. `docs/02_sub_avd_operations_standardization/avd_ops_design.md`

## Validation Flow

The basic validation flow is as follows.

```text
Review requirements and design
  ↓
Run Bicep build
  ↓
Run What-If
  ↓
Deploy baseline
  ↓
Validate Policy / RBAC / Tag / Log settings
  ↓
Record Evidence
  ↓
Teardown validation resources when no longer needed
```

## Local Quality Check

Run the local repository quality check before using the repository as a reviewable artifact.

```powershell
.\scripts\local\Test-RepositoryQuality.ps1
```

The script checks:

- Git working tree status
- Required file existence
- Bicep build
- PowerShell syntax for runbooks and helper scripts
- Generated file cleanup

Expected result:

```text
Repository quality check completed successfully.
```

## Evidence

Evidence templates are stored under `docs/04_evidence/`.

They are used to record:

- What-If result
- Deployment result
- Policy assignment result
- RBAC validation result
- Diagnostic Settings result
- Validation summary

Environment-specific identifiers such as tenant IDs, subscription IDs, principal IDs, UPNs, and customer-specific values should be masked before publishing evidence.

## Design Decisions

Architecture Decision Records are stored under `docs/03_adr/`.

Current ADRs cover:

- Landing Zone Lite scope
- Governance / Policy Baseline as the main theme
- RBAC model
- Monitoring and Diagnostic Settings
- AVD operations standardization

## Current Status

The initial portfolio structure is available.

Included:

- Overview documents
- Azure Governance Baseline design documents
- Initial Bicep skeleton
- Azure CLI runbooks
- Evidence templates
- ADRs
- AVD operation standardization documents
- AVD script samples and public script skeletons
- Local repository quality check

Next improvements will focus on script refinement, validation evidence, and README-level navigation cleanup.
