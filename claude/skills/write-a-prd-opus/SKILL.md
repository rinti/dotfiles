---
name: write-a-prd-opus
description: Opus-tuned PRD authoring skill. Front-loads requirements gathering, batches clarifying questions, uses parallel subagent exploration, and saves the PRD under the project root .issues folder. Use when user wants to write a PRD with Opus 4.7 or mentions "write a prd opus".
---

Opus-tuned variant of `write-a-prd`. Same output (a PRD in `.issues/`), but shaped for Opus 4.7: front-load the full brief in turn 1, batch follow-ups per design dimension, delegate codebase exploration to parallel subagents, and use adaptive thinking explicitly at module decomposition.

Skip any step that is genuinely unnecessary — but do not skip steps to reduce turns. Batch instead.

## 1. Demand an upfront brief (single turn)

Before asking anything else, request — in one message — all of the following from the user:

1. **Problem** — long, detailed description of the pain, from the user's perspective
2. **Candidate solutions** — any ideas they've already considered, including rejected ones and why
3. **Constraints** — stack, deadlines, perf/security/compliance budgets, team size
4. **Acceptance criteria** — what "done" looks like
5. **Relevant file locations** — paths, modules, prior PRDs/PRs, or "greenfield"
6. **Stakeholders & actors** — who uses it, who approves it

If any are missing after their reply, request the missing items together in one follow-up, not progressively.

## 2. Parallel codebase verification

Verify their assertions and map the current state. When the questions fan across multiple files/areas, spawn Explore subagents in parallel (single message, multiple tool calls). When it's a single known path, read directly. Do not ask the user what the code already says.

Report a short "current state" summary before interviewing further.

## 3. Batched interview (decision-tree traversal)

Think carefully and step-by-step before responding; design-tree traversal is harder than it looks.

- Enumerate the top-level design dimensions up front so the user sees the tree.
- For each dimension, ask **all tightly-coupled sub-questions in one turn** with your recommended answer + one-line rationale per question.
- Only split across turns when earlier answers genuinely gate later ones.
- Resolve dimensions in dependency order.

## 4. Module decomposition (invoke deeper thinking)

Think carefully and step-by-step before responding; this step sets the testability of the whole feature.

Sketch the major modules to build/modify. Actively look for **deep modules** — ones that encapsulate significant functionality behind a simple, stable, testable interface. Prefer a few deep modules over many shallow ones.

Present in a single message:

- Module list with one-line responsibility each
- Interface sketch per module (inputs, outputs, invariants)
- Which modules are new vs. modified
- Your recommendation for which modules deserve tests, with reasoning

Confirm with the user; iterate if needed.

## 5. Write the PRD

Once the problem, solution, and module design are all agreed, write the PRD to disk. Save locally only — do not use GitHub issues, the GitHub API, or `gh` for the PRD.

**Output location:** project root, directory `.issues/`. Create `.issues` if it does not exist.

**Filename:** `{short-kebab-title}.md` derived from the PRD title (lowercase, ASCII, hyphens). If the file exists, append `-{YYYYMMDD}` or `-2`, `-3`, etc., until unique.

**File structure:** single `#` heading (the PRD title), blank line, then the sections below in order using `##` headings exactly.

<prd-template>

## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A LONG, numbered list of user stories in the format:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

Cover all aspects of the feature extensively.

## Implementation Decisions

A list of implementation decisions made. Include:

- Modules built/modified
- Interfaces of modified modules
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets — they date quickly.

## Testing Decisions

- What makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (similar tests already in the codebase)

## Out of Scope

What is explicitly out of scope for this PRD.

## Further Notes

Anything else relevant.

</prd-template>
