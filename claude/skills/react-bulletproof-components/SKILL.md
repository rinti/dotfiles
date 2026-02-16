---
name: react-bulletproof-components
description: Build resilient React components that remain correct as requirements evolve. Use this skill when designing, reviewing, or refactoring React components that risk naming collisions, state drift, stale closures, strict mode issues, remount bugs, or unnecessary memoization/performance complexity.
---

# React Bulletproof Components

Use this skill to turn fragile component code into robust patterns that survive common evolution paths.

## Workflow

1. Identify likely failure modes from the request (state growth, async callbacks, nesting, remounts, perf).
2. Apply the matching "-proof" patterns from `references/bulletproof-react-components.md`.
3. Prefer semantic clarity first (correctness, maintainability), then optimize performance.
4. Explain tradeoffs briefly when choosing between competing patterns.
5. Keep implementation minimal: add only the hardening needed for realistic risk.

## Pattern Selection

Use this map to choose quickly:

- Naming collisions across instances or sibling subcomponents: `collision-proof`
- Complex UI flow with explicit statuses/transitions: `context-switch-proof`
- Props changing after mount causing state reset/drift: `dep-change-proof`
- Multiple updates in one event causing wrong totals: `stale-state-proof`
- Async handlers/timers using outdated state: `stale-closure-proof`
- Component structure changes breaking children indexing logic: `depth-change-proof`
- Effects running twice in development strict mode: `strict-mode-proof`
- Expensive setup rerunning after remount: `remount-proof`
- Heavy recomputation without measurable gain: `perf-proof`
- Over-reliance on manual memoization in compiler-based React: `compiler-proof`

## Delivery Standard

- Return code that is stable under repeated renders, remounts, and changing props.
- Avoid prop-to-state sync unless there is explicit ownership or reset semantics.
- Use `useMemo` and `useCallback` only when they protect expensive computation or stable identities needed by consumers.
- Keep effects idempotent and always include cleanup where relevant.

## References

- Detailed guidance and snippets: `references/bulletproof-react-components.md`
- For fast lookup:
  - `rg -n "stale-closure-proof|strict-mode-proof|compiler-proof" references/bulletproof-react-components.md`
  - `rg -n "anti-pattern|checklist|signals" references/bulletproof-react-components.md`
