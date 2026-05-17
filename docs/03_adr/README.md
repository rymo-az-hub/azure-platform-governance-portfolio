# Architecture Decision Records

This directory stores Architecture Decision Records for the repository.

ADRs explain why a specific design decision was selected. They connect requirements, constraints, alternatives, and consequences.

## ADR List

| ADR | Decision |
|---|---|
| `adr-001-landing-zone-lite-scope.md` | Use a lightweight Subscription-level Landing Zone scope for the initial version |
| `adr-002-governance-policy-baseline.md` | Use Azure Governance / Policy Baseline as the main theme |
| `adr-003-rbac-model.md` | Use minimum privilege and scope separation for RBAC |
| `adr-004-monitoring-and-diagnostic-settings.md` | Use Log Analytics Workspace and Diagnostic Settings as the initial logging baseline |
| `adr-005-avd-operations-standardization.md` | Position AVD operations standardization as a secondary applied CloudOps example |

## ADR Format

Each ADR should include:

- Status
- Context
- Decision
- Alternatives considered
- Consequences

## Review Points

When reviewing ADRs, check whether the following points are clear.

- Why the selected approach was chosen
- What alternatives were considered
- What trade-offs were accepted
- What is intentionally out of scope
- How the decision connects to operation and validation

## Policy

ADRs should remain short enough to be read during a design review.

Detailed procedures should be placed in design documents or runbooks, not inside ADRs.
