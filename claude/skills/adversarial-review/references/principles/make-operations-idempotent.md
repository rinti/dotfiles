# Make Operations Idempotent

**Principle:** Design operations so they converge to the correct state regardless of how many times they run or where they start from.

## Why

CLI commands, lifecycle operations, and scheduling loops run in environments where crashes, restarts, and retries are normal. If an operation leaves partial state that causes a different outcome on re-execution, every restart becomes a debugging session.

## The Pattern

- **Convergent startup:** Scan existing state, clean stale artifacts, adopt live sessions — converging regardless of what the previous run left behind.
- **Content-based cleanup:** Use content equivalence, not ancestry, to determine safety.
- **Self-healing locks:** PID-based stale lock detection ensures orphaned locks from crashed processes are automatically recovered.

## The Test

Before shipping a state-mutating operation, ask:
1. What happens if this runs twice in a row?
2. What happens if the previous run crashed at every possible point?
3. Does re-execution converge to the same end state?

If any answer is "it depends on what state was left behind," the operation needs a reconciliation step.

See also [[principles/fix-root-causes]], [[principles/encode-lessons-in-structure]]
