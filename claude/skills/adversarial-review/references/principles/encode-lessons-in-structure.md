# Encode Lessons in Structure

**Principle:** Encode recurring fixes in mechanisms (tools, code, metadata, automation) rather than textual instructions. Every error, human correction, and unexpected outcome is a learning signal — capture it, route it, and close the loop.

## Why

Textual instructions are routinely ignored. They require the reader to notice, remember, and comply. Structural mechanisms — lint rules, metadata flags, runtime checks, automation scripts — enforce the rule without cooperation.

## Pattern

When you catch yourself writing the same instruction a second time:

1. Ask: can this be a lint rule, a metadata flag, a runtime check, or a script?
2. If yes, encode it. Delete the instruction.
3. If no (genuinely requires judgment), make the instruction more prominent and add an example of the failure mode.

**Corollary — don't paper over symptoms.** If the fix is structural, ONLY use the structural fix.

## Feedback Loop

- **Capture every correction.** When the human intervenes or tests fail, decide if it's a one-off or a pattern.
- **Route to the right layer.** A one-off → note. A recurring fix → lint rule. A systemic issue → principle.
- **Close the loop.** Don't only record — apply now or create a concrete todo.

See also [[principles/never-block-on-the-human]]
