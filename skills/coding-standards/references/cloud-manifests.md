# Cloud manifests & IaC standards

**Job type:** `cloud` — Kubernetes/Helm, Terraform, CloudFormation, Bicep, similar declarative infra — not application business logic.

## Responsibilities

- Declare desired state; least privilege; no plaintext secrets; clear blast radius; verify with plan/lint before apply.

## Chosen / Rejected (for planner LLD)

| Pattern | Choose when | Reject when |
|---------|-------------|-------------|
| **Edit existing module/chart** | Change fits current structure | Drive-by rewrite of unrelated stacks |
| **New module / chart** | Reuse across envs or clear boundary | One-off copy for a single value tweak |
| **Copy-paste manifest** | Truly unique one-shot (rare) | Duplicating a module that already exists |
| **Wrapper script around apply** | Repo already automates apply | Hiding required plan/lint steps |

## Rules

1. **Least privilege** — IAM/RBAC roles grant only needed actions; no `*` unless justified and temporary.
2. **Secrets** — use secret managers / sealed secrets / CI vars; never commit plaintext credentials or private keys.
3. **Naming & labels** — match repo conventions (name prefixes, `app.kubernetes.io/*`, tags).
4. **Blast radius** — prefer scoped resources; call out destroy/replace risk in the plan.
5. **Drift-aware edits** — change the source of truth (module/chart values), not only live cluster state.
6. **Pin versions** — chart/provider/module versions pinned or follow repo policy.
7. **Environments** — don’t hardcode prod into shared defaults; use tfvars/overlays/values files.

## Verification (typical)

| Stack | Checks |
|-------|--------|
| Terraform | `fmt`, `validate`, `plan` |
| Helm | `helm lint`, template render for target values |
| K8s YAML | `kubectl apply --dry-run=client` or repo’s policy tool |
| CFN / Bicep | template validate / what-if |

Do not `apply` unless the Task Card / user explicitly asks.

## Anti-patterns

- Broad `cluster-admin` / account-wide admin for convenience
- Secrets in ConfigMaps or committed `.tfvars`
- Manual cluster edits with no manifest update
