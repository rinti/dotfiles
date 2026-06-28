---
name: cac
description: "Changelog and commit. Updates CHANGELOG.md (if present) following Keep a Changelog 1.0.0, then prepares a git commit following Tim Pope / cbea.ms seven rules. Use when the user runs /cac or asks to record a change in the changelog and commit it."
argument-hint: "Optional: extra context about the change (e.g. issue ref, scope hint)"
---

# CAC — Changelog And Commit

Two-step workflow:

1. Add an entry to `CHANGELOG.md` (if it exists) following [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/).
2. Prepare and create a git commit following the [seven rules of a great commit message](https://cbea.ms/git-commit/).

Always show the user the changelog edit and the proposed commit message **before** running `git commit`. Per global rules, never commit without explicit user permission.

## Step 1 — Inspect the change

Run these in parallel to learn what's changing:

```bash
git status
git diff --staged
git diff
```

If nothing is staged, treat the unstaged changes as the candidate set and tell the user — don't silently `git add -A`. Ask which files to stage if it's ambiguous.

## Step 2 — Update CHANGELOG.md (if it exists)

Check for `CHANGELOG.md` at the repo root (`git rev-parse --show-toplevel`). If it does not exist, skip to Step 3 and mention you skipped because there is no changelog.

When updating, follow Keep a Changelog 1.0.0:

- Entries live under `## [Unreleased]` at the top of the file. If that section does not exist, add it above the most recent version section.
- Group entries under one of these subsection headings, in this order when multiple apply:
  - `### Added` — new features
  - `### Changed` — changes in existing functionality
  - `### Deprecated` — soon-to-be-removed features
  - `### Removed` — now-removed features
  - `### Fixed` — bug fixes
  - `### Security` — vulnerabilities
- Write entries for humans, not machines. Imperative, present tense, one line each, no trailing period required by Keep a Changelog but match the file's existing style.
- Do not invent a version bump or release date. Only modify `## [Unreleased]`.
- Match the existing file's formatting (dash vs asterisk bullets, blank-line conventions, link references at the bottom) — read the file first to detect the style.

Use `Read` then `Edit` to modify the file precisely. Do not rewrite the whole file.

## Step 3 — Draft the commit message

Follow the seven rules from https://cbea.ms/git-commit/:

1. Separate subject from body with a blank line.
2. Limit the subject line to 50 characters (hard cap 72).
3. Capitalize the subject line.
4. Do not end the subject line with a period.
5. Use the imperative mood in the subject line ("Add", "Fix", "Refactor" — not "Added"/"Adds").
6. Wrap the body at 72 characters.
7. Use the body to explain *what* and *why*, not *how*.

Body guidance:
- **Default to subject-only.** A body is the exception, not the rule. Most commits — version bumps, lockfile syncs, typo fixes, single-file tweaks, dependency upgrades the changelog already explains — need nothing beyond the subject line.
- Add a body **only** when there is genuinely non-obvious context the diff can't show: *why* a counterintuitive choice was made, an external constraint, a subtle invariant the next reader could break, cross-repo coordination, a surprise the author hit.
- Match body length to change size. As a rule of thumb, the body should be **shorter than the diff itself**. A 4-line diff doesn't get an 8-line body. Tiny changes get at most 1–2 sentences if they need a body at all; a paragraph is for substantive changes.
- **Don't duplicate the changelog.** If the change is recorded in `CHANGELOG.md`, the narrative already lives there — the commit message should not echo it. If you wrote a changelog entry, lean toward subject-only.
- Don't restate the diff in prose. Don't explain *how*; the code shows that. Don't include a chronology of debugging steps.
- Reference issues/PRs at the bottom of the body when relevant (e.g. `Refs #123`).
- Match the repository's existing commit style — run `git log --oneline -20` to check for conventions (e.g. conventional commits prefix like `feat:`, scope tags, etc.). If the repo clearly uses conventional commits, follow that style while still respecting the seven rules.

Examples of right-sized commits:

```
# Tiny change → subject only
Bump frontend Node from 22 to 24
```

```
# Small change, brief why → one short paragraph
Pin idna to 3.15

Addresses CVE-2026-45409; no API changes in the bump.
```

```
# Substantive change with non-obvious motivation → real body
Fix silently-dropped Slack CI notifications

The Slack action runs with errors: false by default, so an invalid
JSON payload (multi-line commit messages interpolated raw) made every
send no-op while the step still reported success.
```

## Step 4 — Confirm with the user

Present:
- The CHANGELOG.md diff (or note that you skipped because the file doesn't exist).
- The proposed commit message in full.
- The list of files that will be included.

Then ask for confirmation. **Do not commit without explicit user permission.**

## Step 5 — Commit

After approval, stage the changelog change if needed and create the commit. Use a heredoc to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
Subject line

Body paragraph wrapped at 72 columns.
EOF
)"
```

Then run `git status` to confirm.

## Rules

- Never `--amend` without asking, and never if the previous commit was pushed.
- Never add Claude/AI attribution to the commit message (no `Co-Authored-By: Claude`, no "Generated with Claude Code").
- Never `git push` unless the user asks.
- If a pre-commit hook fails, fix the underlying issue and create a new commit — do not `--no-verify`.
- If the user passed arguments to `/cac`, treat them as extra context (issue ref, scope hint, framing) for the changelog entry and commit body.
