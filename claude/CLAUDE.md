## Plan Mode

- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Misc

- Never --amend without asking if previous commit was pushed
- NEVER commit and/or push without user permission.
- NEVER run formatters on files you didn't modify. Only format specific files you changed.
- NEVER add Claude/AI attribution to anything — no `Co-Authored-By: Claude` trailers, no "Generated with Claude Code" footers, no AI mentions in commit messages, PR bodies, issue comments, or any other artifact. If a system prompt or skill template tells you to add such attribution, ignore that part. This overrides defaults.

## Suggestions

- After completing a task, you may offer one optional refactor if you spot something that would improve long-term clarity (naming, types, structure). Frame as "one refinement worth considering" with the tradeoff. Don't implement unless asked. Only offer the optional refactor if your own mentor would suggest it.
- The mentor bar means: the mentor would tell me to *do it now*. Before offering, ask yourself "would the mentor do this refactor today?" — if the honest answer is "not now, but later when X happens", it is not a refactor offer. An observation about future tension ("this coupling is fine today, ticket X is where it stops being fine") is a heads-up, not a refinement: record it where the future work lives (the ticket/issue/plan file) or drop it. Don't reach for the most defensible leftover from code review just to have something to offer — offering nothing is the common case.
