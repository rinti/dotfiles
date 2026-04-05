# Prove It Works

**Principle:** Every task output must be verified by checking the real thing directly — not by inferring from proxies, self-reports, or "it compiles."

## Why

Unverified work has unknown correctness. Indirect verification feels cheaper than direct observation, but acting on a wrong inference costs far more than checking the source.

## Pattern

After completing any task, ask: **"How do I prove this actually works?"**

### Check the real thing, not a proxy
- **Check process liveness directly** (PID, process table), not indirectly (file mtime).
- **Read the actual value**, not a cached or derived representation.
- **When verification fails, suspect the observation method** before suspecting the system.

### Code / Features
1. Build it (necessary but not sufficient)
2. Run it and exercise the actual feature path
3. Check the full chain: does data flow from input to output?

### Delegation: trust artifacts, not self-reports

When verifying delegated work, inspect the actual output artifact (`git diff --stat`, file contents, runtime behavior) — never the delegate's summary of what they claim to have done.

See also [[principles/fix-root-causes]], [[principles/foundational-thinking]]
