# Azure Governance / Policy Baseline

This directory contains the main design documents for the Azure Governance Baseline.

This is the primary scope of the repository. It explains how to introduce a practical minimum baseline for Azure platform control before Azure usage expands further.

## Positioning

The purpose of this section is not to reproduce a full Enterprise Scale Landing Zone.

The initial target is a lightweight Subscription-level baseline that can be validated with low cost and extended later.

## Documents

| Document | Purpose |
|---|---|
| `requirements.md` | Defines the assumed customer, current issues, requirements, constraints, and acceptance criteria |
| `governance_design.md` | Explains the overall governance design and control areas |
| `policy_baseline.md` | Defines the initial Azure Policy baseline and Audit-first approach |
| `rbac_design.md` | Defines the RBAC model, scope design, and role assignment policy |
| `tagging_standard.md` | Defines required tags and tag operation policy |
| `monitoring_logging_design.md` | Defines Log Analytics and Diagnostic Settings design principles |
| `cost_management_notes.md` | Defines initial cost management and low-cost validation considerations |
| `exception_operation.md` | Defines how exceptions should be recorded and reviewed |
| `validation_plan.md` | Defines how the baseline should be validated and recorded as evidence |

## Recommended Reading Order

1. `requirements.md`
2. `governance_design.md`
3. `policy_baseline.md`
4. `rbac_design.md`
5. `tagging_standard.md`
6. `monitoring_logging_design.md`
7. `cost_management_notes.md`
8. `exception_operation.md`
9. `validation_plan.md`

## Design Policy

The baseline follows these principles.

- Start with a small and practical scope
- Prefer Audit before Deny
- Assign permissions by group and scope
- Apply tags at creation time
- Record validation results as evidence
- Keep exception handling explicit
- Avoid committing environment-specific identifiers

## Review Points

When reviewing this section, check whether the following points are clear.

- The baseline is practical for a mid-sized organization
- Governance controls are not over-engineered
- Policy, RBAC, Tag, Log, Cost, Exception, and Evidence are connected
- Operational acceptance is considered, not only resource deployment
