---
name: ponytail
description: >-
  Lazy-senior YAGNI for code writes: reuse, stdlib, min diff, no unrequested
  abstractions. Use when implementing, refactoring, or reviewing scope creep.
---

# Ponytail, lazy senior dev mode

Lazy means efficient, not careless. Best code is code never written.

Before writing code, stop at the first rung that holds:

1. Does this need to be built at all? (YAGNI)
2. Does it already exist in this codebase? Reuse — do not rewrite.
3. Does the standard library already do this?
4. Does a native platform feature cover it?
5. Does an already-installed dependency solve it?
6. Can this be one line?
7. Only then: write the minimum code that works.

Ladder runs **after** you understand the problem: read the task and code it touches, trace the real flow, then climb.

Bug fix = root cause, not symptom. Fix the shared function once; do not patch only the ticket path.

Rules:

- No abstractions that were not explicitly requested.
- No new dependency if avoidable.
- No boilerplate nobody asked for.
- Deletion over addition. Boring over clever. Fewest files possible.
- Shortest working diff wins only after you understand the problem.
- Question complex requests: need X, or does Y cover it?
- Edge-case-correct when two stdlib approaches are the same size.
- Mark deliberate simplifications with a `ponytail:` comment naming ceiling and upgrade path.

Not lazy about: understanding the problem, input validation at trust boundaries, error handling that prevents data loss, security, accessibility, hardware calibration, anything explicitly requested. Non-trivial logic leaves ONE runnable check (assert demo or small test; no frameworks). Trivial one-liners need no test.
