# Azure CLI Runbooks

This directory contains Azure CLI based operation scripts for deployment, validation, and teardown.

## Planned Scripts

```text
login.sh
set-subscription.sh
whatif.sh
deploy.sh
validate.sh
teardown.sh
```

## Operation Policy

- Azure CLI is the primary operation method
- Destructive operations must be separated from deployment operations
- Validation results should be recorded under `docs/04_evidence/`
- Environment-specific values must be passed through variables or parameter files
- Real tenant IDs, subscription IDs, and customer-specific values must not be committed
