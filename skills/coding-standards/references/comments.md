# Production commenting standard

**Universal semantics** across languages (.NET · Java · Go · Node/TypeScript · Python · Shell). Only public-API doc syntax differs.

## Purpose

Comments carry knowledge **code, names, types, and structure cannot**.

| Code explains | Comments explain |
|---------------|------------------|
| WHAT / HOW | WHY, constraints, contracts, non-obvious decisions |

Do **not** comment to narrate obvious code or pad “documentation coverage.” Prefer renaming/refactoring when a comment only exists because the code is confusing.

**Core:** A comment preserves knowledge that would otherwise leave with the original author.

---

## Categories (use these)

| Tag / kind | Use for |
|------------|---------|
| **API / CONTRACT** | Public inputs, outputs, errors, guarantees, usage limits |
| **WHY** | Non-obvious implementation or design decision |
| **BUSINESS** | Domain/compliance rules not obvious from code |
| **ARCHITECTURE** | Boundaries / deps future devs might “simplify” away |
| **PERFORMANCE** | Non-obvious algorithmic or resource trade-offs |
| **CONCURRENCY** | Locking, thread-safety, async interleaving assumptions |
| **SECURITY** | Constraints that must not be removed accidentally |
| **WARNING** | Dangerous / destructive / non-idempotent ops |
| **INVARIANT** | Condition that must always remain true |
| **TEMPORARY** | Debt, workarounds, planned change (`TODO` / `FIXME` / `HACK`) |
| **IDEMPOTENCY** | Whether retry is safe (distributed / provider calls) |

---

## Public API docs (native format)

Document **exported/public** APIs. Skip noise on obvious private helpers.

### Java — Javadoc

```java
/**
 * Creates a payment for the given order.
 *
 * @param orderId order to charge
 * @param amount amount to charge
 * @return the created payment
 * @throws PaymentException if the provider rejects the request
 */
public Payment createPayment(String orderId, Money amount) { ... }
```

### .NET — XML docs

```csharp
/// <summary>Creates a payment for the given order.</summary>
/// <param name="orderId">Order to charge.</param>
/// <param name="amount">Amount to charge.</param>
/// <returns>The created payment.</returns>
/// <exception cref="PaymentException">Provider rejected the request.</exception>
public Payment CreatePayment(string orderId, Money amount) { ... }
```

### Go — Go doc

Start with the exported identifier:

```go
// CreatePayment creates a payment for the given order.
// It returns an error if the payment provider rejects the request.
func CreatePayment(orderID string, amount Money) (Payment, error) { ... }
```

### Node / TypeScript — JSDoc / TSDoc

```ts
/**
 * Creates a payment for the given order.
 * @param orderId Order to charge.
 * @param amount Amount to charge.
 * @throws {PaymentError} when the provider rejects the request.
 */
async function createPayment(orderId: string, amount: Money): Promise<Payment> { ... }
```

Prefer precise types over long comments that restate shapes.

### Python — docstrings

```python
def create_payment(order_id: str, amount: Money) -> Payment:
    """Create a payment for the given order.

    Raises:
        PaymentError: if the provider rejects the request.
    """
    ...
```

### Shell — header + WHY

```bash
#!/usr/bin/env bash
# Sync orders to the warehouse API. Idempotent upsert by order id.
# WARNING: --force skips the dry-run safety check.
```

---

## Implementation comments (same across languages)

Use `//` (or block comments) for WHY / BUSINESS / ARCHITECTURE / PERFORMANCE / CONCURRENCY / SECURITY / WARNING / INVARIANT / idempotency. Examples below are language-agnostic; adapt naming only.

### WHY (most important)

```text
// BAD — restates code
// Check if order is paid
if (order.isPaid()) { ... }

// GOOD — reason that isn't in the code
// Paid orders cannot be modified because the payment provider
// does not support reversing this transaction.
if (order.isPaid()) { throw ... }
```

### BUSINESS

```text
// Transactions above ₹50,000 require PAN verification
// according to the current compliance policy.
// Prefer: Source: Refund Policy v3.2 / REFUND-1421
```

### ARCHITECTURE

```text
// Do not call the repository from the controller.
// Authorization and audit logging are enforced at this service boundary.
```

### PERFORMANCE

```text
// Build an index once so lookups remain O(1).
// Scanning the list per order would make this O(n²).
```

Not: `// Use HashMap` — say the trade-off.

### CONCURRENCY

```text
// mu protects both cache and expiration metadata.
// Callers must hold the lock before modifying either.

// Node: JS is single-threaded, but serialize across async boundaries
// when interleaved requests can race on shared mutable state.
```

### SECURITY

```text
// Never log the token / credentials.
// Keep SQL parameterized — never interpolate user input.
// Do not remove this tenant authorization check.
```

### WARNING

Only for real operational, security, data, or reliability risk:

```text
// WARNING: This operation is not idempotent.
// Retrying after a timeout can create a duplicate payment.
```

### INVARIANT

```text
// Invariant: every pending order has exactly one payment attempt.
```

### Idempotency / retry

```text
// Idempotent for the same idempotency key — safe to retry after network failure.
// Do not auto-retry: provider may have accepted despite timeout.
```

---

## Temporary work tags

| Tag | Meaning |
|-----|---------|
| `TODO` | Planned future work |
| `FIXME` | Known defect |
| `HACK` | Temporary workaround |
| `DEPRECATED` | Stop using; point to replacement |

**Actionable only** — include ticket/owner when possible:

```text
// TODO(PROJ-1421): Replace polling with provider webhooks after migration.
// FIXME(PROJ-1832): Retry policy retries non-transient 4xx.
// HACK(PROJ-1921): Empty cursor from provider; remove after API v2.
```

```ts
/** @deprecated Use createPaymentV2. Removed after v2 migration. */
```

No bare `// TODO: fix this`.

---

## Do not comment

- Translating code into English (`// create user`, `// increment counter`, `// return result`)
- Justifying bad design (`// giant method but it works`) — refactor instead
- Commented-out dead code — delete it
- Novel abbreviations; stale comments left after behavior change (treat as bugs)

---

## Quality rules

1. **WHY not WHAT** — if the next line says it, delete the comment.
2. **Colocate** — comment sits next to the code it explains (not 50 lines above).
3. **Update or remove** when behavior changes — stale comment worse than none.
4. **Cite external rules** — ticket / policy / spec when useful.
5. **Never excuse poor design** — comments preserve necessary knowledge only.

---

## Decision tree

```
COMMENT NEEDED?
       │
Can code/name/type clearly express it?
   YES → no comment
   NO  → pick category:
         API contract → native API docs
         Business rule → BUSINESS (+ ticket/policy)
         Architecture constraint → ARCHITECTURE
         Performance trade-off → PERFORMANCE
         Concurrency assumption → CONCURRENCY
         Security constraint → SECURITY
         Dangerous behavior → WARNING
         Always-true condition → INVARIANT
         Retry safety → IDEMPOTENCY
         Temporary → TODO / FIXME / HACK
```

---

## Cross-language syntax

| Purpose | Java | .NET | Go | Node/TS | Python | Shell |
|---------|------|------|-----|---------|--------|-------|
| Public API | Javadoc | XML `///` | Go doc | JSDoc/TSDoc | docstring | header comment |
| WHY / BUSINESS / … | `//` | `//` | `//` | `//` | `#` | `#` |
| Warning | `// WARNING:` | same | same | same | `# WARNING:` | same |
| Debt | `TODO/FIXME/HACK(ticket)` | same | same | same | same | same |

---

## Final checklist (executors / reviewers)

1. Prefer good code over comments.
2. Don't describe obvious code.
3. Explain WHY when reason isn't obvious.
4. Document public API contracts (native format).
5. Document non-obvious business rules.
6. Document architectural constraints others might break.
7. Document security, concurrency, performance, reliability assumptions when non-obvious.
8. `WARNING` only for genuine danger.
9. `TODO`/`FIXME`/`HACK` only when actionable (+ ticket).
10. Reference tickets/specs when useful.
11. Keep comments next to the code.
12. Treat stale comments as bugs.
13. Same semantic conventions across languages; only doc syntax differs.
14. Never comment for coverage metrics.
15. If comment exists because code is confusing → improve the code first.
