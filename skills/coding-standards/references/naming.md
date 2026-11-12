# Naming — files & symbols

## Cross-cutting

| Kind | Convention |
|------|------------|
| Tickets in names | `JIRA-123` or omit; never spaces |
| Tests | Mirror sut name + `Test`/`_test`/`spec` per language |
| Avoid | Cryptic abbrevs (`mgr`, `svc` ok only if repo already uses them), Hungarian notation |

---

## .NET (C#)

| Symbol | Case | Example |
|--------|------|---------|
| Types, methods, properties, events | PascalCase | `OrderService`, `GetById` |
| Interfaces | `I` + PascalCase | `IOrderRepository` |
| Locals, params | camelCase | `orderId` |
| Private fields | `_camelCase` | `_clock` |
| Constants / static readonly | PascalCase | `DefaultTimeout` |
| Async methods | suffix `Async` | `SaveAsync` |
| Files | One public type per file; filename = type | `OrderService.cs` |
| Namespaces | Match folder path | `Company.Sales.Api` |
| Test projects | `*.Tests` | `Sales.Api.Tests` |

---

## Go

| Symbol | Case | Example |
|--------|------|---------|
| Exported | MixedCaps | `OrderService` |
| Unexported | mixedCaps | `parseOrder` |
| Packages | short, lowercase, no underscore | `orders` |
| Interfaces | often `-er` | `Reader`, `OrderStore` |
| Files | short, lowercase, `_` ok | `order_handler.go` |
| Tests | `*_test.go`, `TestXxx` | `order_test.go` |
| Avoid | `Stuttering` (`orders.Order`), `Get`/`Set` noise on trivial fields |

---

## Java

| Symbol | Case | Example |
|--------|------|---------|
| Classes / interfaces / enums | PascalCase | `OrderService` |
| Methods / fields / locals | camelCase | `findById` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Packages | lowercase, reverse-DNS | `com.company.sales` |
| Files | Public top-level type = filename | `OrderService.java` |
| Spring stereotypes | role suffix | `OrderController`, `OrderRepository` |
| Tests | `*Test` / `*IT` | `OrderServiceTest` |

---

## Node (JavaScript / TypeScript)

| Symbol | Case | Example |
|--------|------|---------|
| Variables / functions | camelCase | `getOrder` |
| Classes / React components / types | PascalCase | `OrderService`, `OrderDto` |
| Constants / env keys | UPPER_SNAKE | `MAX_RETRIES` |
| Files / folders | `kebab-case` | `order-service.ts` |
| Tests | `*.test.ts` / `*.spec.ts` | `order-service.test.ts` |
| Prefer | Named exports for libraries; default export only if team already does |

TS: `interface`/`type` PascalCase; no `I` prefix unless codebase already uses it.

---

## Python (thin)

| Symbol | Case | Example |
|--------|------|---------|
| Modules / packages / files | `snake_case` | `order_service.py` |
| Functions / vars | `snake_case` | `get_order` |
| Classes | PascalCase | `OrderService` |
| Constants | `UPPER_SNAKE` | `MAX_RETRIES` |
| Tests | `test_*.py` or `*_test.py` | `test_order_service.py` |

---

## Shell (thin)

| Symbol | Case | Example |
|--------|------|---------|
| Scripts | `kebab-case` or `snake_case` | `sync-orders.sh` |
| Functions | `snake_case` | `sync_orders` |
| Env vars | `UPPER_SNAKE` | `API_BASE_URL` |
| Prefer | `.sh` extension; executable bit when invoked directly | |
