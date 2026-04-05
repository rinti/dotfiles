# Cost-Aware Delegation

**Principle:** Every delegation boundary has a budget. Account for delegation overhead itself, and hard-cap scope to prevent work from expanding to fill available resources.

## Why

Agent turns, CI minutes, and API dollars are finite. Without explicit budgets, work expands to fill the available resources.

## Pattern

- **Budget before delegating.** Count turns per phase. If total > budget, the scope is too large.
- **Front-load context to avoid rediscovery costs.** Every piece of analysis withheld is a turn wasted.
- **Hard-cap scope.** Max 2-3 files per phase. 1 function/type + tests per phase. Without caps, work expands.
- **Account for coordination overhead.** Choose the cheaper delegation mechanism unless coordination is genuinely needed.
- **Exit smart, not late.** Commit passing work early. Git operations reliably cost turns.

## Relationship to Other Principles

This is not about *what* to build ([[principles/foundational-thinking]]) or *how* to structure it ([[principles/boundary-discipline]]). It's about the economics of having someone else build it — treating attention as a finite currency.
