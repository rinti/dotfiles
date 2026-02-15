---
name: plan-review
description: "Review implementation plan using Codex CLI. Use when in plan mode to get feedback on your current plan before proceeding."
---

# Plan Review Skill

Reviews the current implementation plan using OpenAI Codex CLI.

## Usage

Read the plan file and pipe it to Codex for review:

```bash
cat .claude-plan.md | codex exec "Review this implementation plan. Check for:
- Missing edge cases or error handling
- Potential bugs or issues
- Unclear or ambiguous steps
- Better approaches or optimizations
- Security concerns
- Missing tests or validation steps

Be concise and actionable in your feedback."
```

If `.claude-plan.md` doesn't exist, check for alternative locations like `PLAN.md`.

Requires Codex CLI to be installed.
