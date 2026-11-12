# Branches, commits, pull requests

## Branch names

```
<type>/<ticket?-slug>
```

| Type | Use |
|------|-----|
| `feature/` | New capability |
| `fix/` | Bug fix |
| `chore/` | Tooling, deps, non-prod behavior |
| `refactor/` | No intended behavior change |
| `hotfix/` | Prod emergency |
| `release/` | Release prep |

**Slug:** lowercase `kebab-case`, ≤50 chars, no spaces.  
Examples: `feature/ORD-42-order-cancel`, `fix/null-token-refresh`.

Protected branches (`main`/`master`/`develop`): no direct commits.

---

## Commit messages (Conventional Commits)

```
<type>(optional-scope): <imperative summary ≤72 chars>

[optional body — why, not how]

[optional footer: Fixes #123 / BREAKING CHANGE: …]
```

| Type | Meaning |
|------|---------|
| `feat` | User-facing feature |
| `fix` | Bug fix |
| `refactor` | Behavior-preserving restructure |
| `perf` | Performance |
| `test` | Tests only |
| `docs` | Docs only |
| `chore` | Build/tooling |
| `ci` | CI config |

**Rules:** imperative (“add”, not “added”); one logical change per commit when practical; never commit secrets.

Examples:
```
feat(orders): add cancel endpoint
fix(auth): handle expired refresh token
```

---

## Pull requests

**Title:** same as Conventional Commit subject (optionally with ticket).

**Body (minimum):**
```markdown
## Summary
- What / why (1–3 bullets)

## Changes
- Key files / areas

## Test plan
- [ ] Unit / integration steps
- [ ] Manual check

## Risk / rollback
- Risk level + how to revert
```

Link ticket. Prefer small PRs. Draft until green CI if team requires.
