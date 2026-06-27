# aks-app-deployment

Application deployment repo for AKS — Helm charts, environment-specific values, and deployment pipelines.

## Application Stack

| Tier | Image | Port | Type |
|---|---|---|---|
| Frontend | nginx:1.25-alpine | 80 | Deployment + Ingress + HPA |
| Backend | python:3.12-slim | 8000 | Deployment + HPA + NetworkPolicy |
| Database | postgres:16-alpine | 5432 | StatefulSet + PVC |

## Helm Chart Structure

```
helm/multi-tier-app/              # Umbrella chart
├── Chart.yaml                    # Dependencies: frontend, backend, database
├── values.yaml                   # Default values
├── values-dev.yaml               # Dev overrides (1 replica, no HPA, debug logging)
├── values-prod.yaml              # Prod overrides (3+ replicas, HPA, TLS, warn logging)
└── charts/
    ├── frontend/                 # Nginx frontend sub-chart
    │   ├── templates/
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   ├── ingress.yaml
    │   │   ├── hpa.yaml
    │   │   └── networkpolicy.yaml
    │   └── values.yaml
    ├── backend/                  # Python backend sub-chart
    │   ├── templates/
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   ├── configmap.yaml
    │   │   ├── secret.yaml
    │   │   ├── hpa.yaml
    │   │   └── networkpolicy.yaml
    │   └── values.yaml
    └── database/                 # PostgreSQL database sub-chart
        ├── templates/
        │   ├── statefulset.yaml
        │   ├── service.yaml
        │   ├── secret.yaml
        │   └── networkpolicy.yaml
        └── values.yaml
```

## Deployment

```bash
# Dev
cd helm/multi-tier-app
helm dependency update .
helm install multi-tier-app . --namespace app-dev --create-namespace -f values-dev.yaml

# Upgrade
helm upgrade multi-tier-app . --namespace app-dev -f values-dev.yaml --wait --atomic

# Rollback
helm rollback multi-tier-app --namespace app-dev
```

## Branching Strategy

| Branch | Environment | Trigger |
|---|---|---|
| `dev` | dev cluster | Push deploys to app-dev namespace |
| `main` | prod cluster | Push deploys to app-prod namespace (with approval) |
| Manual | Either | `workflow_dispatch` with install/upgrade/rollback |

## Security Features

- All containers: `runAsNonRoot`, `readOnlyRootFilesystem`, `drop ALL capabilities`
- Network policies: Frontend ← any, Backend ← frontend only, Database ← backend only
- Secrets: Helm hooks for initial creation; External Secrets Operator for prod Key Vault sync

## Related Repos

- [terraform-aks-deployment](https://github.com/KT-MakeDevOpsEasy/terraform-aks-deployment) — AKS infrastructure
- [aks-platform-config](https://github.com/KT-MakeDevOpsEasy/aks-platform-config) — Security policies and OPA
