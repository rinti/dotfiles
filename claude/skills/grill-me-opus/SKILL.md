---
name: grill-me-opus
description: Opus-tuned interview skill. Stress-tests a plan/design by batching questions per decision branch until shared understanding is reached. Use when user wants to grill a plan with Opus 4.7 or mentions "grill me opus".
---

Opus-tuned variant of `grill-me`. Goal is the same: walk the decision tree, resolve every branch, reach shared understanding. Differences are shaped by Opus 4.7's strengths (adaptive thinking, longer reasoning per turn, judicious tool/subagent use) and its cost model (every user turn adds reasoning overhead).

## Turn 1: demand an upfront brief

Do not start grilling until the user has given you, in a single message:

1. **Intent** — what problem the plan solves and for whom
2. **Constraints** — non-negotiables (stack, deadlines, perf budgets, compliance)
3. **Acceptance criteria** — how they'll know it's done
4. **Relevant file locations** — paths, modules, prior PRs, or "greenfield"
5. **Known unknowns** — branches they already suspect are unresolved

If any are missing, request all missing items in one message, not progressively.

## Turn 2+: batched branch interrogation

Think carefully and step-by-step before responding; decision-tree traversal is harder than it looks.

- Identify the top-level decision branches from the brief. Enumerate them up front so the user sees the shape of the tree.
- For each branch, ask **all tightly-coupled sub-questions in one turn**, not one at a time. A "branch turn" looks like: branch name → 2–5 coupled questions → your recommended answer for each with a one-line rationale → the tradeoff you're least sure about.
- Only split a branch across turns if answers to earlier questions genuinely gate the later ones. Prefer batching.
- Resolve branches in dependency order (foundations before leaves).

## Codebase-answerable questions: delegate, don't ask

If a question can be answered by reading the repo, **do not ask the user** — spawn parallel Explore subagents when the questions fan across multiple files/areas, or read directly when it's a single known path. Report findings inline and fold them into the recommendation for that branch.

## Recommendations

Every question gets your recommended answer with a one-line rationale. The user pushes back or confirms; don't hedge with "it depends" unless you name the specific condition.

## Stop gate

This skill is planning-only. After every branch is resolved, produce:

- **Decision summary** — one line per resolved branch, in dependency order
- **Unresolved** — branches the user explicitly deferred (if any)
- **"Implement now?"** — wait for explicit confirmation before any edits

Do not proceed to implementation until the user says so.
