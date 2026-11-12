# LLD patterns (choose smallest fit)

Use in `dev-planner` **Chosen / Rejected** tables. Prefer patterns already in the repo.

**Mental map:** Principles tell how to design; patterns give reusable structures for recurring problems. Never pick a pattern that violates KISS / YAGNI for this task.

## When to use which catalog

| Job type | Principles + ladder | Pattern catalog for Chosen/Rejected |
|----------|---------------------|--------------------------------------|
| `app` | Always | GoF (when OOP service code) + **Common service patterns**; also `api-services.md` / `background-services.md` |
| `ai-eng` | Always | Domain table in `ai-engineering.md`; add GoF/common **only** when writing service/agent application code |
| `script` | Always | Domain table in `scripting.md` — do **not** force GoF |
| `cloud` | Always | Domain table in `cloud-manifests.md` — do **not** force GoF |
| `mixed` | Always | Primary job’s catalog; note secondary pack in Defaults |

Every plan still needs Chosen **and** Rejected rows — pick the next-heavier alternative from the **same** catalog.

---

## Default ladder (Ponytail-aligned)

1. Function / method in existing type
2. Small pure helper in same package
3. Existing service / use-case class
4. New service + interface (only if multiple impls or test seam needed)
5. New package/module layer
6. Shared kernel / platform abstraction — last resort

---

## Design principles (apply first)

Record relevant principles in Chosen (why this shape) or Rejected (why not over-engineer).

### SOLID

| Principle | Meaning | Plan cue |
|-----------|---------|----------|
| **SRP** | One reason to change; focused responsibility | Split only when a type already mixes concerns |
| **OCP** | Open for extension, closed for modification | Prefer new strategy/handler over editing a switch forest |
| **LSP** | Subtypes usable where base is expected | Reject inheritance that breaks caller assumptions |
| **ISP** | Small focused interfaces; no fat contracts | Split ports clients don't fully need |
| **DIP** | High-level depends on abstractions | Inject ports at boundaries; don't new up infra deep inside |

### Other principles

| Principle | Meaning | Plan cue |
|-----------|---------|----------|
| **KISS** | Simplest correct solution | Default; reject cleverness |
| **YAGNI** | No feature/abstraction until required | Reject speculative factories, buses, layers |
| **DRY** | One authoritative representation of a rule | Extract only after real duplication (not premature) |
| **SoC** | Distinct parts, distinct concerns | Transport ≠ application ≠ persistence |
| **Composition over inheritance** | Assemble collaborators; avoid deep hierarchies | Prefer deps over base-class trees |
| **Law of Demeter** | Talk to immediate collaborators | Reject `a.b.c.d()` chains; pass what you need |
| **Encapsulation** | Hide internals; expose needed ops | Keep domain state private; map at edges |
| **Program to an interface** | Depend on contracts | Ports at trust/IO boundaries |
| **Dependency Injection** | Dependencies provided from outside | Constructor/param inject; no hidden singletons for testability |
| **POLA** | Behavior matches reasonable expectation | Names, errors, defaults unsurprising |
| **Fail Fast** | Invalid state detected early | Validate at boundaries; reject silent coerce |
| **Convention over Configuration** | Sensible defaults over knobs | Match repo conventions before new config |

```
DESIGN PRINCIPLES
├── SOLID (SRP · OCP · LSP · ISP · DIP)
├── KISS · YAGNI · DRY · SoC
├── Composition over Inheritance · Law of Demeter · Encapsulation
├── Program to an Interface · Dependency Injection
└── POLA · Fail Fast · Convention over Configuration
```

---

## GoF catalog (name → one-liner)

Use names below in Chosen/Rejected. Prefer **Common service patterns** table when both apply.

### Creational

| Pattern | Intent |
|---------|--------|
| **Singleton** | One instance + global access point |
| **Factory Method** | Subclasses decide which concrete type to create |
| **Abstract Factory** | Families of related objects without concrete classes |
| **Builder** | Step-by-step construction separate from representation |
| **Prototype** | New objects by cloning an existing instance |

### Structural

| Pattern | Intent |
|---------|--------|
| **Adapter** | Make incompatible interfaces work together |
| **Bridge** | Decouple abstraction from implementation |
| **Composite** | Uniform treatment of leaf and tree groups |
| **Decorator** | Add behavior without changing the class |
| **Facade** | Simple face over a complex subsystem |
| **Flyweight** | Share intrinsic state to cut memory |
| **Proxy** | Surrogate controlling access to another object |

### Behavioral

| Pattern | Intent |
|---------|--------|
| **Chain of Responsibility** | Pass request along handlers until one handles it |
| **Command** | Request as object (queue, undo, log, param) |
| **Interpreter** | Grammar + interpreter for a language |
| **Iterator** | Traverse without exposing internals |
| **Mediator** | Centralize communication; cut mesh coupling |
| **Memento** | Capture/restore state without exposing internals |
| **Observer** | Notify dependents on state change |
| **State** | Behavior changes with internal state |
| **Strategy** | Interchangeable algorithms selected at runtime |
| **Template Method** | Algorithm skeleton; subclasses fill steps |
| **Visitor** | New ops on structures without changing classes |

```
DESIGN PATTERNS
├── CREATIONAL — Singleton · Factory Method · Abstract Factory · Builder · Prototype
├── STRUCTURAL — Adapter · Bridge · Composite · Decorator · Facade · Flyweight · Proxy
└── BEHAVIORAL — CoR · Command · Interpreter · Iterator · Mediator · Memento
                  · Observer · State · Strategy · Template Method · Visitor
```

### GoF choose / reject (OOP stacks)

| Pattern | Choose when | Reject when |
|---------|-------------|-------------|
| **Singleton** | True process-wide resource (rare) | Hidden global mutable state; prefer DI |
| **Factory Method / Abstract Factory** | ≥2 real product families or creation varies by type | One concrete type forever |
| **Builder** | Many optional fields / invariant construction | 2–3 required ctor args |
| **Prototype** | Cheap clone beats re-init | Mutable shared clones surprise callers |
| **Adapter** | External/legacy shape ≠ your port | Internal rename-only wrapper |
| **Bridge** | Abstraction and impl both vary independently | One impl forever |
| **Composite** | Real tree of same-shaped nodes | Flat list |
| **Decorator** | Orthogonal layered behavior | One-off if/else |
| **Facade** | Stabilize messy subsystem for consumers | Extra hop, no clarity |
| **Flyweight** | Huge counts of near-identical objects | Normal entity count |
| **Proxy** | Access control, lazy, remote, caching seam | Pass-through with no policy |
| **Strategy** | ≥2 real interchangeable algorithms | Speculative “future” variants |
| **Observer / events** | Multiple independent reactions to one change | Two direct calls suffice |
| **Command** | Queue, undo, audit, or defer execution | Sync void method enough |
| **State** | Behavior matrix by explicit states | Boolean flags with few branches |
| **Template Method** | Shared algorithm, few custom steps | Composition/strategy clearer |
| **Mediator** | Many-to-many object chatter | Simple pairwise calls |
| **Chain of Responsibility** | Ordered handlers, first match wins | Fixed single handler |
| **Visitor / Interpreter / Memento** | Real grammar, external ops, or undo snapshots | CRUD / ordinary services |

---

## Common service patterns

| Pattern | When to choose | When to reject |
|---------|----------------|----------------|
| **Direct call** | Single caller, simple flow | — prefer this first |
| **Service / use-case** | App logic reused by API + worker or multiple endpoints | One-liner glue |
| **Repository / store port** | Persistence details must be swappable or tested behind seam | Trivial static SQL in a script |
| **DTO / view model** | Wire shape ≠ domain shape | Identical fields with no mapping need |
| **Middleware / filter** | Cross-cutting auth, logging, metrics | Business rules |
| **Strategy / policy** | ≥2 real interchangeable algorithms | Speculative “future” variants |
| **Facade** | Stabilize a messy subsystem for one consumer | Extra hop with no clarity gain |
| **Adapter** | External API / legacy protocol | Internal-only code |
| **Outbox / inbox** | Reliable side effects with DB transaction | In-process only, loss ok |
| **Saga / process manager** | Multi-step distributed workflow with compensation | Single DB transaction enough |
| **CQRS (light)** | Read model clearly diverges from write | CRUD with same model |
| **Event bus (in-proc)** | Decouple multiple in-process reactions | Two direct calls would do |
| **Result / Either type** | Expected domain failures | Transport-only apps that already map HTTP errors |

## Layer sketch (both API & workers)

```
Transport (HTTP / queue / cron)
  → Application (use-cases / handlers)
    → Domain (optional if complexity warrants)
      → Infrastructure (DB, brokers, HTTP clients)
```

Skip empty layers. Don’t create Domain if it’s only anemic DTOs.

## Language notes

- **.NET:** MediatR-style handlers only if repo already uses them; otherwise plain services.
- **Go:** interfaces defined in consumer package when practical.
- **Java:** Spring services/repos; avoid abstract factory forests.
- **Node:** route → service → repo; avoid god `utils.ts`.

## Planner checklist

1. Climb the **default ladder** first (adapt to scripts/IaC: smallest file/module change).
2. Name **principles** that justify the shape (esp. SRP, DIP, KISS, YAGNI).
3. Name **patterns** from the catalog for this **Job type** only when they earn their keep.
4. Every Chosen row needs a Rejected sibling for the next-heavier alternative.
5. Do not invent Abstract Factory / Event bus rejects for Helm charts or one-file scripts.
