# Guard the Context Window

**Principle:** The context window is finite and non-renewable within a session. Every token that enters should earn its place.

## Why

Context overflow degrades reasoning quality, causes compression artifacts, and halts progress.

## Pattern

- **Isolate large payloads.** Route verbose tool outputs to subagents. The main context gets summaries, not raw data.
- **Don't read what you won't use.** Read selectively based on relevance, not exhaustively.
- **Keep frequently-used content inline.** Only split to references when content is truly conditional.
- **Size phases and cap scope.** See [[principles/cost-aware-delegation]] for specifics.

See also [[principles/cost-aware-delegation]]
