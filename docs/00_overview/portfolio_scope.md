# Portfolio Scope

## 1. Purpose

This repository defines a lightweight Azure platform governance baseline for a mid-sized organization.

The purpose is to organize Azure governance, operational standardization, Infrastructure as Code, runbooks, ADRs, and evidence as one coherent platform design example.

This repository does not aim to demonstrate isolated resource deployment. It focuses on how Azure platform operations can be controlled, standardized, validated, and handed over for operation.

## 2. Intended Readers

- Cloud platform engineers
- Azure infrastructure engineers
- Cloud operations engineers
- Technical consultants involved in Microsoft cloud environments
- Reviewers who want to understand the design intent, not only the implementation

## 3. Assumed Scenario

A mid-sized organization is expanding Azure usage and needs a minimum governance baseline before workloads increase.

The organization requires:

- Clear resource ownership
- Basic policy controls
- RBAC design
- Tagging standards
- Diagnostic log collection
- Cost visibility
- Exception handling
- Repeatable deployment and validation procedures

## 4. Main Scope

The main scope is Azure Governance / Policy Baseline.

Included areas:

- Subscription-level governance baseline
- Resource group structure
- Azure Policy assignments
- RBAC model
- Tagging standard
- Diagnostic Settings and Log Analytics
- Cost management notes
- Exception operation
- Validation plan and evidence

## 5. Secondary Scope

The secondary scope is AVD operations standardization.

This section shows how operational tasks can be standardized through pre-checks, scripts, runbooks, and result records.

AVD content is treated as an applied CloudOps example. It is not the primary design scope of this repository.

## 6. Out of Scope

The following areas are out of scope for the initial version:

- Full enterprise-scale Azure Landing Zone implementation
- Production-grade hub-spoke network implementation
- ExpressRoute / VPN design
- Full Microsoft Sentinel implementation
- Complex identity lifecycle design
- Application workload architecture
- Full CI/CD release management
- Organization-specific operational rules

## 7. Design Assumptions

- Azure CLI is used as the primary operation method
- Bicep is used for Infrastructure as Code
- Deployment is designed for low-cost validation
- Resources should be removable after validation
- Governance is introduced gradually
- Audit-based controls may be used before deny-based enforcement
- Operational evidence should be recorded separately from implementation code

## 8. Public and Private Boundary

This repository must not include:

- Customer names
- Employer names
- Internal project names
- Real tenant IDs
- Real subscription IDs
- Real user principal names
- Real IP address lists
- Internal operational procedures that cannot be disclosed
- Interview notes or private explanations

Private notes must be managed outside this public repository.

## 9. Deliverables

- Overview documents
- Azure Governance / Policy Baseline design documents
- AVD operations standardization documents
- Bicep templates
- Azure CLI runbooks
- PowerShell operation scripts
- ADRs
- Evidence templates and validation records

## 10. Review Focus

This repository should be reviewed from the following perspectives:

- Whether the design intent is clear
- Whether governance controls are practical
- Whether operations can be repeated safely
- Whether exceptions and responsibilities are considered
- Whether IaC and runbooks are aligned
- Whether validation results can be traced
