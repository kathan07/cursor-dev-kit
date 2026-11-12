# Background service standards

Applies when **Job type** is `app` (or mixed) for **workers, consumers, cron/schedulers, hosted services** — not HTTP request handlers (except admin/health). Language columns are illustrative; match the repo’s stack.

## Responsibilities

- Pull/receive work; process **idempotently**; retry with backoff; dead-letter poison messages; shut down gracefully; expose health/metrics.

## Layout (typical)

| Layer | .NET | Go | Java | Node |
|-------|------|----|------|------|
| Host | `BackgroundService` / Worker | `cmd/worker` + loop | Spring `@Scheduled` / listener | bull/agenda/custom consumer |
| Handler | `IConsumer<T>` / handlers | handler funcs | `@KafkaListener` / JMS | processor functions |
| App | same use-cases as API when shared | shared packages | shared modules | shared services |

Prefer **shared application services** with API when domain is the same; keep transport adapters thin.

## Processing contract

1. **Receive** → deserialize → validate shape  
2. **Idempotency key** (message id / business key) — store processed mark or upsert  
3. **Process** inside clear transaction boundaries  
4. **Ack / commit offset** only after success (or intentional defer)  
5. **On failure:** retryable vs permanent; DLQ after N attempts  

## Reliability

| Concern | Standard |
|---------|----------|
| Retry | Exponential backoff + jitter; cap attempts |
| Poison | DLQ / parking lot with reason; alert |
| Ordering | Don’t assume global order unless partition key guarantees it |
| At-least-once | Default; design handlers idempotent |
| Exactly-once | Only with proven outbox/inbox or broker support — don’t fake it |
| Shutdown | Respect cancellation; finish or safely nack in-flight work |
| Visibility | Heartbeats / lease extension for long jobs |

## Outbox / inbox

Use when DB write + message publish must not diverge. Reject dual-write “best effort” for money/inventory/state machines.

## What not to do

- Call long CPU work on the API thread pool “because it’s easier”  
- Use HTTP timeouts as worker semantics  
- Process without idempotency on at-least-once brokers  
- Infinite retry without DLQ  
- Catch-and-ignore errors to keep lag green  

## Observability

Log `messageId`, `attempt`, `handler`, duration. Metrics: lag, success/fail, DLQ rate. Trace each handler span.

## Testing

- Handler unit tests with duplicate delivery  
- Failure path → retry/DLQ behavior  
- Graceful shutdown smoke if feasible
