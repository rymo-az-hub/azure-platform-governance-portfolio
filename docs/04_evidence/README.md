# Evidence

This directory stores validation records and execution evidence.

Evidence should make it possible to understand what was validated, when it was validated, and what result was obtained.

## Evidence Files

| File | Purpose |
|---|---|
| `01-what-if-result.md` | Records the deployment What-If result before making changes |
| `02-deployment-result.md` | Records the deployment result and key outputs |
| `03-policy-assignment-result.md` | Records Azure Policy assignment validation |
| `04-rbac-validation-result.md` | Records RBAC assignment validation |
| `05-diagnostic-settings-result.md` | Records Log Analytics and Diagnostic Settings validation |
| `06-validation-summary.md` | Summarizes the overall validation result |

## Evidence Policy

Evidence files must not include:

- Real tenant IDs
- Real subscription IDs
- Customer names
- Internal host names
- Real user names or UPNs
- Principal IDs from real environments
- Confidential IP address lists

When necessary, values should be masked or replaced with sample values.

## Usage

Evidence is not intended to be a raw dump of every command output.

It should be reviewed and summarized so that another engineer can understand:

- What was executed
- What was checked
- What result was obtained
- What is still unconfirmed
- Whether the result can be accepted

## Review Points

When reviewing evidence, check whether the following points are clear.

- The execution target is identifiable without exposing sensitive values
- The command or runbook used for validation is clear
- The result is specific enough to support the conclusion
- Unchecked or out-of-scope items are explicitly recorded
- The evidence can be connected back to the design documents and ADRs
