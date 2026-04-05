---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

## Core Rules

- Test behavior through public interfaces.
- One behavior per cycle: RED -> GREEN -> REFACTOR.
- Avoid implementation-detail assertions (private methods, internal call order).
- Mock only true boundaries (network, clock, filesystem, external services).

See [tests.md](tests.md), [mocking.md](mocking.md), and [interface-design.md](interface-design.md).

## Language-Aware Setup

Pick commands from the user's stack:

- JavaScript: `npm test -- <test-name>` or `pnpm test -- <test-name>`
- Python: `pytest -q -k "<test_name>"`
- Kotlin/JVM: `./gradlew test --tests "*<TestName>*"`

If the repo uses a different runner, detect and use that.

## Workflow

### 1) Plan

- Confirm target public interface.
- List high-value behaviors with the user.
- Start with one tracer-bullet behavior.

### 2) RED

- Add one failing test for one behavior.
- Run the smallest relevant test scope.

### 3) GREEN

- Implement the minimum code to pass.
- Run focused tests, then nearby suite if needed.

### 4) REFACTOR

- Improve naming/structure with tests green.
- Re-run tests after each small refactor.

## Anti-Pattern to Avoid

Do not batch phases ("write all tests, then all code"). Stay vertical:

`test1 -> code1 -> test2 -> code2 -> ...`

## Per-Cycle Checklist

```
[ ] Behavior-focused test
[ ] Public API only
[ ] Fails before implementation
[ ] Minimal passing code
[ ] No speculative features
```
