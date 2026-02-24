---
name: what-to-test
description: Use when writing tests, improving coverage, or deciding what to test in this CLI
version: 1.0.0
---

# What to Test

## Philosophy

Test user-facing behavior. If a user would notice it's broken, it needs a test.

## What Makes a Good Test

- Tests behavior users depend on
- Validates real workflows, not implementation details
- Catches regressions before users do

Do NOT write tests just to increase coverage numbers. Use coverage as a guide to find untested user-facing behavior.
