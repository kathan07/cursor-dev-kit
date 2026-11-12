# API service standards

Applies when **Job type** is `app` (or mixed with API shape): HTTP/gRPC **request/response** services. Language columns below are illustrative (.NET / Go / Java / Node); match the repo’s stack.

## Responsibilities

- Expose stable contracts; authenticate/authorize; validate input; map to use-cases; map errors to transport codes; emit metrics/traces.

## Layout (typical)

| Layer | .NET | Go | Java | Node |
|-------|------|----|------|------|
| Transport | Controllers / Minimal APIs / gRPC | `net/http` or chi/gin/echo handlers | Spring `@RestController` / JAX-RS | Express/Fastify/Nest controllers |
| App | Services / handlers | service funcs | `@Service` | services |
| Data | DbContext / repos | store packages | Spring Data / repos | db modules |

## HTTP conventions

| Topic | Standard |
|-------|----------|
| Methods | GET read, POST create/actions, PUT replace, PATCH partial, DELETE remove |
| Status | 200/201/204 success; 400 validation; 401/403 authz; 404 missing; 409 conflict; 429 throttle; 5xx unexpected |
| Body | JSON (unless contracted otherwise); explicit content-types |
| Idempotency | PUT/DELETE safe to retry; POST with `Idempotency-Key` when required |
| Versioning | URL `/v1` or header — match existing service |
| Pagination | cursor or offset — be consistent; always bound page size |

## Contract rules

- **DTOs at the edge** — don’t leak ORM entities / internal models.
- **Validation** at transport (annotations, schema, bind + validate) before business logic.
- **AuthN/AuthZ** before side effects; least privilege.
- **Correlation:** propagate `traceparent` / request id through logs and downstream calls.
- **Timeouts** on outbound HTTP; never unbounded waits.
- **Health:** `/health` (liveness) + readiness (deps) when platform expects it.

## Errors

Return a stable error shape (problem+json or repo standard). Log server-side with stack/context; client gets safe message + code.

## Testing

- Unit: use-cases with fakes  
- Integration: one happy + one validation failure per endpoint family  
- Contract tests if consumers depend on schema

## Anti-patterns

- Business rules in controllers  
- Catch-all `500` for validation  
- Sync over async blocking the event loop / thread pool  
- Chatty N+1 DB in list endpoints
