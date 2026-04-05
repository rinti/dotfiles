# Boundary Discipline

**Principle:** Place validation, type narrowing, and error handling at system boundaries. Trust internal code unconditionally. Business logic lives in pure functions; the shell is thin and mechanical.

## Why

Validation scattered throughout a codebase is noisy, redundant, and gives a false sense of safety. Concentrating it at boundaries means each piece of data is validated exactly once — at the point it enters the system — and flows freely after that. Similarly, logic tangled with framework wiring can't be tested without the framework and can't be reused across contexts.

## The Pattern

- **At boundaries** (CLI args, config, external APIs, protocol layers): validate, return `error`, handle defensively.
- **Inside the system**: typed data, error propagation, no re-validation. Trust the types.

## Applications

### Validation and Error Handling

- All commands return `(T, error)` — errors handled at the command boundary, not inside business logic.
- No `panic()` in production code — propagate with `return err`.
- Validate config at parse time (boundary), not inside business logic.

### Code Organization

Business logic lives in pure functions with no framework dependencies (`(Input) => (Output, error)`). The shell — CLI routing, event handling, framework wiring — is thin and mechanical.

## The Tests

Before adding a validation check, ask: **"Is this data crossing a system boundary right now?"** If not, the validation is redundant — trust the types.

Before putting logic in a hook, event listener, or framework integration point, ask: **"Can this be a pure function that the shell just calls?"** If yes, extract it.

See also [[principles/foundational-thinking]]
