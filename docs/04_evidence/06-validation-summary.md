# Validation Summary

## Purpose

This file summarizes the validation result for the Azure Governance Baseline.

## Validation Information

| Item | Value |
|---|---|
| Date | YYYY-MM-DD |
| Operator | TBD |
| Commit | TBD |
| Parameter | infra/parameters/dev.bicepparam |

## Summary

| Area | Result | Evidence |
|---|---|---|
| What-If | Not checked | 01-what-if-result.md |
| Deployment | Not checked | 02-deployment-result.md |
| Policy Assignment | Not checked | 03-policy-assignment-result.md |
| RBAC | Not checked | 04-rbac-validation-result.md |
| Diagnostic Settings | Not checked | 05-diagnostic-settings-result.md |
| Teardown | Not checked | TBD |

## Acceptance Criteria

| Check | Result | Notes |
|---|---|---|
| Resource groups are created as expected | Not checked |  |
| Required tags are applied | Not checked |  |
| Log Analytics Workspace is created | Not checked |  |
| Policy assignments are created as expected | Not checked |  |
| RBAC assignments are controlled | Not checked | Disabled by default in the initial version |
| Resources can be removed after validation | Not checked |  |
| No sensitive values are recorded | Not checked |  |

## Known Constraints

| Area | Constraint |
|---|---|
| Management Group | Out of scope for the initial version |
| Alerting | Detailed alert design is out of scope |
| Sentinel | Out of scope for the initial version |
| PIM | Detailed design is out of scope |
| Production operation | Initial version assumes a validation environment |

## Decision

| Item | Value |
|---|---|
| Baseline accepted | Not decided |
| Required fixes | TBD |
| Next action | TBD |
