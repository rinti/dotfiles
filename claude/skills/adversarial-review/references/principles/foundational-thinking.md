# Foundational Thinking

**Structural decisions** (data models, phase ordering, infrastructure) optimize for option value. **Code-level decisions** (helpers, abstractions, patterns) optimize for simplicity.

"Over-engineering" means making premature decisions that **close doors** — unnecessary abstractions, speculative features, indirection layers. Choosing the right foundational data structure **opens doors** — it preserves option value.

## Data Structures First

Get the data structures right before writing logic. The right structure makes downstream code obvious; the wrong one fights you at every turn.

- Define core types early and let them drive the architecture
- Trace every access pattern through a proposed structure
- Choose structures that match the dominant access pattern

At the code level, simplicity preserves options:
- **DRY at the structural level** (types, data models) — but three similar lines of code is better than a premature abstraction
- **Explicit over clever** — cleverness obscures intent = closing doors
- **No placeholder source files** — create files only when there's real code

**Concurrency corollary:** Before sharing state between actors, ask: "What happens if another actor modifies this concurrently?" If the answer isn't "nothing", isolate.

## Scaffold First

If something benefits all future work, do it first. Ask: "does every subsequent phase benefit from this existing?" If yes, it's scaffold — Phase 1, not the end.

Ask: "does this decision reduce my future options, or preserve them?"

See also [[principles/redesign-from-first-principles]], [[principles/prove-it-works]]
