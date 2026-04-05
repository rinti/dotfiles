# Never Block on the Human

**Principle:** The human supervises asynchronously. Agents must stay unblocked — make reasonable decisions, proceed, and let the human course-correct after the fact. Code is cheap; waiting is expensive.

## Why

Every time an agent pauses to ask for permission, the entire pipeline stalls. Since code changes are reversible and reviewable, the cost of a wrong decision is almost always lower than the cost of blocking.

## Pattern

- **Proceed, then present.** Do the work, show the result. Don't ask "should I do X?" — do X, explain why, and let the human redirect if needed.
- **Reserve questions for genuine ambiguity.** Ask only when you truly cannot infer intent from context.
- **Supervision is async.** Design workflows for review-after-the-fact, not approval-before-the-fact.
- **Code is cheap, attention is scarce.** A wrong implementation costs minutes to fix. A blocked agent costs the human's attention to unblock.

## Boundaries

- **Irreversible actions** (force-push, delete production data, send external messages) still require confirmation.
- **Reversible actions** (write code, edit notes, split tasks) should proceed without blocking.
- **Product direction** comes from the human; *execution* should not block on the human.

See also [[principles/encode-lessons-in-structure]], [[principles/cost-aware-delegation]]
