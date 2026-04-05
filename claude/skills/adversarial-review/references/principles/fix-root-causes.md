# Fix Root Causes

**Principle:** When debugging, never paper over symptoms. Trace every problem to its root cause and fix it there.

## Why

Symptom fixes accumulate: each workaround makes the system harder to reason about, and the real bug remains. Root-cause fixes are slower upfront but reduce total debugging time across the project's lifetime.

## Pattern

- **Reproduce first.** If you can't reproduce it, you can't verify your fix.
- **Ask "why" until you hit bedrock.** The test fails → the mock is wrong → the interface changed → the type doesn't match the runtime shape. Fix the type, not the mock.
- **Resist the urge to add guards.** Adding a nil check to silence a crash is a symptom fix. Why is it nil? Fix that.
- **Check for the pattern, not just the instance.** If one file has a bug, grep for the same pattern. Fix all instances, or make it structurally impossible.
- **When stuck, instrument — don't guess.** Add logging, read the actual error.

## Own Every File You Touch

Never label an issue "pre-existing" to justify skipping it. If you touch a file, you own its quality.

See also [[principles/prove-it-works]], [[principles/encode-lessons-in-structure]]
