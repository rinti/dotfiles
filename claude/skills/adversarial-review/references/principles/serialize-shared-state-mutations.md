# Serialize Shared-State Mutations

**Principle:** When concurrent actors share mutable state, enforce serialization structurally — lockfiles, sequential phases, exclusive ownership. Instructions and conventions are insufficient for concurrency safety.

## Why

Concurrent writes to shared state produce race conditions that are intermittent, hard to reproduce, and expensive to debug. Telling agents or goroutines to "take turns" does not work.

## Pattern

Before allowing any parallel execution:

1. **Identify shared mutable state.** Files both read and write, branches both push to, APIs both define and consume.
2. **If shared state exists, serialize access.** Lockfiles, sequential phases, or exclusive ownership.
3. **If serialization is impractical, eliminate the sharing.** Give each actor its own copy (worktrees, separate files, isolated state directories).

See also [[principles/make-operations-idempotent]], [[principles/encode-lessons-in-structure]]
