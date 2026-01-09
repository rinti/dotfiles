---
allowed-tools: AskUserQuestion, Read, Glob, Grep, Write, Edit, Bash
argument-hint: [plan-file]
description: Look through the current diff to see if we should add more tests
---

Analyze the current git diff to identify if any new tests should be written.

## Instructions

1. Run `git diff` to see all staged and unstaged changes
2. For each changed file, analyze:
   - What functionality was added or modified
   - Whether the change introduces regression risk
   - Whether the change involves critical business logic

3. Only recommend tests that:
   - Prevent regressions for important functionality
   - Cover critical paths or edge cases
   - Test complex logic that could break silently

4. Do NOT recommend tests for:
   - Simple getters/setters
   - Trivial changes
   - Code that's already well-tested
   - Tests just to increase coverage numbers

## Output

Start in plan mode. Present your findings as:
- Summary of changes analyzed
- List of recommended tests with reasoning (if any)
- For each recommendation, explain WHY it prevents a regression or protects important functionality

If no tests are needed, say so clearly.
