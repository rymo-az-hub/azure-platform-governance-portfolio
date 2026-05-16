# Azure Platform Governance Portfolio

This repository provides a practical design and implementation example for a lightweight Azure platform governance baseline.

The main theme is **Azure Governance / Policy Baseline** for a mid-sized organization using Azure. The secondary theme is **AVD operations standardization**, positioned as an applied CloudOps example based on common operational scenarios.

## Purpose

This repository is intended to show how Azure platform operations can be standardized through design documents, Infrastructure as Code, runbooks, ADRs, and evidence.

The focus is not only on creating Azure resources, but on explaining why specific controls are required and how they should be operated.

## Main Theme

### Azure Governance / Policy Baseline

The main design area covers:

- Management Group / Subscription / Resource Group structure
- Azure Policy baseline
- RBAC design
- Tagging standard
- Diagnostic Settings and Log Analytics
- Cost management considerations
- Exception handling
- Validation and evidence

## Secondary Theme

### AVD Operations Standardization

The AVD section provides examples of operational standardization, including:

- Host pool inventory and pre-check
- Session host lifecycle operation
- Personal Desktop assignment
- Troubleshooting flow
- Operation checklist
- Customer response template

The AVD content is positioned as an applied example of CloudOps standardization, not as the primary scope of the repository.

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
├─ scripts/
│  ├─ cli/
│  └─ avd/
├─ .gitignore
└─ .gitattributes
```

## Reading Guide

1. Start with `docs/00_overview/portfolio_scope.md`
2. Read the main design in `docs/01_main_azure_governance_baseline/README.md`
3. Check the IaC structure in `infra/README.md`
4. Check operational procedures in `scripts/cli/README.md`
5. Review AVD operational examples in `docs/02_sub_avd_operations_standardization/README.md`
6. Review design decisions in `docs/03_adr/README.md`
7. Review validation records in `docs/04_evidence/README.md`

## Current Status

Initial repository structure is being prepared. Detailed design documents, Bicep templates, runbooks, and evidence will be added progressively.
