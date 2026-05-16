# Infrastructure as Code

This directory contains Bicep templates for the Azure governance baseline.

## Scope

The initial implementation focuses on a low-cost validation environment.

Planned areas:

- Resource groups
- Monitoring baseline
- Azure Policy assignments
- RBAC assignments
- Tagging support
- Minimal network baseline

## Structure

```text
infra/
├─ main.bicep
├─ parameters/
└─ modules/
```

## Design Notes

- Bicep is used as the primary IaC language
- Azure CLI is used for deployment and validation
- Parameters must not contain real tenant IDs, subscription IDs, user names, or customer-specific values
- Deployment should be removable after validation
