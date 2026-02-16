# Bulletproof React Components Reference

Adapted from "Build Bulletproof React Components" by Shubham Tiwari:
https://shud.in/thoughts/build-bulletproof-react-components

Use these patterns selectively. Do not apply all of them blindly.

## 1) Collision-proof

**Goal:** Prevent state/context collisions when components are reused or nested.

**Signals**
- Reusable component families (`Tabs`, `Accordion`, `Menu`) with multiple instances.
- Subcomponents need shared parent state.

**Use**
- Compound component pattern with local context per parent instance.
- Explicit namespaced exports (`Tabs.Root`, `Tabs.List`, `Tabs.Trigger`, `Tabs.Panel`).

**Avoid**
- Global mutable state keyed by component name.
- Implicit singleton assumptions.

## 2) Context-switch-proof

**Goal:** Make state transitions explicit when complexity grows.

**Signals**
- Several related booleans (`loading`, `error`, `success`, `disabled`).
- Branchy event handlers with many `if` chains.

**Use**
- Replace scattered booleans with `useReducer`.
- Encode finite statuses and allowed actions.

**Checklist**
- Every UI state has one canonical source.
- Invalid transitions are impossible by reducer design.

## 3) Dep-change-proof

**Goal:** Stay correct when incoming props change after mount.

**Signals**
- Local state initialized from props (`useState(props.value)`).
- Parent updates selected item/user while child keeps stale value.

**Use**
- Derive values from props during render when possible.
- If local editable draft is required, reset by stable identity (`item.id`) rather than every prop change.

**Avoid**
- Blind `useEffect(() => setState(prop), [prop])` loops.

## 4) Stale-state-proof

**Goal:** Avoid incorrect results from batched updates.

**Signals**
- Multiple state writes in one handler that depend on previous value.
- Counters, list mutations, optimistic updates.

**Use**
- Functional updates: `setCount((c) => c + 1)`.
- For coupled fields, prefer reducer actions.

**Avoid**
- Reusing closed-over state value for sequential updates.

## 5) Stale-closure-proof

**Goal:** Ensure async callbacks see current values.

**Signals**
- `setTimeout`, intervals, event listeners, async retries, websocket handlers.
- Callback reads state long after render that created it.

**Use**
- Store latest mutable value in a ref (`latest.current = value` in effect or render-safe pattern).
- Read from ref inside delayed callback.
- Use stable callback wrappers where needed.

**Avoid**
- Assuming closure values stay current across time.

## 6) Depth-change-proof

**Goal:** Survive tree structure changes without brittle child indexing.

**Signals**
- Logic based on `children[0]`, sibling order, or deep traversal assumptions.
- Feature requests that insert wrappers/fragments break behavior.

**Use**
- Composition APIs with explicit slots/props.
- Context or explicit registration instead of positional assumptions.

**Avoid**
- Hidden coupling to DOM/component depth.

## 7) Strict-mode-proof

**Goal:** Remain correct under React Strict Mode development behavior.

**Signals**
- Effects with non-idempotent side effects.
- Duplicate subscriptions, duplicate network calls, leaked listeners.

**Use**
- Idempotent effects plus cleanup.
- Abort/cancel in-flight async work where possible.
- Guard side effects that should run once per lifecycle.

**Checklist**
- Mount/unmount/remount in development does not duplicate external effects.

## 8) Remount-proof

**Goal:** Avoid expensive reinitialization and accidental resets.

**Signals**
- Heavy setup work in render path.
- Components frequently toggled in/out of tree.

**Use**
- Lazy initialization (`useState(() => init())`) for expensive initial values.
- `useRef` for objects that must persist during component lifetime without triggering rerenders.
- Lift state up when values must survive child remounts.

**Avoid**
- Recomputing heavy defaults on every mount unnecessarily.

## 9) Perf-proof

**Goal:** Optimize only where measurement or complexity justifies it.

**Signals**
- Expensive derivation runs repeatedly.
- Child rerenders caused by unstable object/array/function identities.

**Use**
- Add `useMemo` around expensive pure calculations with stable dependencies.
- Add `useCallback` when referential stability is required by memoized children or dependency contracts.
- Prefer simpler code first; optimize after identifying hot paths.

**Avoid**
- Blanket memoization everywhere.

## 10) Compiler-proof

**Goal:** Keep code future-proof with React Compiler assumptions.

**Signals**
- Team relies on compiler-level optimizations.
- Existing code has defensive manual memoization everywhere.

**Use**
- Write clear pure render logic; let compiler handle routine memoization opportunities.
- Keep manual memoization only when semantically required (stable identity contracts, expensive derivations, interoperability constraints).

**Avoid**
- Treating `useMemo` as guaranteed optimization in all future compilation modes.

## Practical Review Pass

When reviewing a component, run this order:

1. Correctness first: `dep-change`, `stale-state`, `stale-closure`.
2. Structural resilience: `collision`, `depth-change`, `context-switch`.
3. Runtime safety: `strict-mode`, `remount`.
4. Performance: `perf`, then `compiler`.

If only one issue exists, fix only that class of issue.
