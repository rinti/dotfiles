---
name: car
description: "Changelog and release. Runs git flow release start, bumps version via ./bump-version.sh, rolls the CHANGELOG.md [Unreleased] section into the new version, then runs git flow release finish. Use when the user runs /car <version> or asks to cut a release."
argument-hint: "<version> (required, e.g. 1.2.0)"
---

# CAR — Changelog And Release

Cut a release with git-flow. Sibling of [[cac]] — same changelog discipline ([Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/)) but for releases instead of single commits.

Pipeline:

1. `git flow release start <version>`
2. `./bump-version.sh <version>` (if it exists)
3. Edit `CHANGELOG.md`: rename `## [Unreleased]` to `## [<version>] - YYYY-MM-DD`, add a fresh empty `## [Unreleased]` above it, update link references if present.
4. Show the diff, get explicit confirmation.
5. `git flow release finish <version>` (non-interactive).

Never push automatically — leave that to the user.

## Step 0 — Validate

- `<version>` is required. If missing, ask for it and stop.
- Confirm the repo has git-flow initialised: `git config --get gitflow.branch.develop` should return something. If not, stop and tell the user — this skill is git-flow specific.
- Confirm the working tree is clean (`git status --porcelain` empty). If dirty, stop and ask the user to commit/stash first — releases on top of unrelated work are dangerous.
- Confirm we're on `develop` (or whatever `gitflow.branch.develop` returns). If not, stop and ask.

## Step 1 — Start the release branch

```bash
git flow release start <version>
```

This switches to a `release/<version>` branch off develop.

## Step 2 — Bump the version

Check for `./bump-version.sh` at the repo root.

- If it exists: `./bump-version.sh <version>`
- If it does not exist: skip and tell the user. Do not invent an alternative bump command — the user can run it manually before the release finish step if needed.

After bumping, run `git status` and `git diff` to see what changed.

## Step 3 — Update CHANGELOG.md

Read `CHANGELOG.md` at the repo root. If it doesn't exist, tell the user and skip this step (the release can still proceed; it's the user's call).

Otherwise, edit it precisely with `Edit`:

1. Find the line `## [Unreleased]`. If it's missing, stop and ask the user — the skill expects the Keep a Changelog layout.
2. If `## [Unreleased]` is empty (no entries between it and the next heading), warn the user — cutting an empty release is usually a mistake, but proceed if they confirm.
3. Insert a new empty `## [Unreleased]` block above the existing one. Keep the project's exact whitespace conventions.
4. Rename the now-second `## [Unreleased]` to `## [<version>] - <YYYY-MM-DD>` using today's date (`date +%Y-%m-%d`).

If the file has link references at the bottom (e.g. `[Unreleased]: .../compare/vA.B.C...HEAD`), update them too:

- Change the `[Unreleased]` compare URL so its base is the new version tag (e.g. `vA.B.C` → `v<version>`).
- Add a new line for `[<version>]` pointing to the compare range between the previous version and `v<version>`, matching the existing URL style. If you can't infer the previous version from the existing references, leave a TODO comment and tell the user.

End result, schematic:

```markdown
## [Unreleased]

## [1.2.0] - 2026-05-21
### Added
- ... (previously under Unreleased)
```

## Step 4 — Stage and confirm

Run `git add` for the version-bumped files and `CHANGELOG.md` (only those — never `git add -A`).

Show the user:
- The list of staged files.
- The CHANGELOG.md diff.
- The commit message you intend to use (default: `Release <version>`).

Then ask for explicit confirmation. **Do not proceed to `release finish` without it.** This step creates commits, a tag, and a merge into the main branch — it's not trivially reversible.

After approval, commit on the release branch:

```bash
git commit -m "Release <version>"
```

(Follow the [seven rules of a great commit message](https://cbea.ms/git-commit/) — subject capitalized, imperative, no trailing period, under 50 chars. The default is fine for releases; tailor if the repo's commit log shows a different style.)

## Step 5 — Finish the release

Run `git flow release finish` non-interactively so it doesn't drop into `$EDITOR` for the merge commit and tag annotation:

```bash
GIT_MERGE_AUTOEDIT=no git flow release finish -m "Release <version>" <version>
```

`-m` supplies the tag annotation. `GIT_MERGE_AUTOEDIT=no` accepts the default merge commit messages git-flow generates.

**Tag-annotation gotcha — read before running.** The original `git-flow` (not `git-flow-avh`) wraps `getopt` in a way that rejects spaces inside `-m` values and aborts with `flags:FATAL the available getopt does not support spaces in options`. Do **not** work around it by passing a no-space annotation like `-mRelease-<version>` — that leaks the bug into the repo's permanent tag history (which is what happened on `v1.0.2` in `delight` and required a retag). Instead, skip the auto-tag and tag manually:

```bash
GIT_MERGE_AUTOEDIT=no git flow release finish -n <version>
git tag -a v<version> -m "Release <version>" <main-branch>
```

(`-n` means "don't tag this release". Substitute `<main-branch>` with whatever `git config --get gitflow.branch.master` returns, typically `main` or `master`.)

This path also works on `git-flow-avh`, so when in doubt, prefer it over the inline `-m`.

If the version-finish flags differ in this project's git-flow variant, inspect with `git flow release finish -h` and adapt — but still avoid opening an editor.

After finishing, run `git tag -n10 v<version>` and confirm the annotation reads exactly `Release <version>` (with a space, no dash). Also run `git status` and `git log --oneline -10` so the user can see the result: a tag `<version>` (or whatever `gitflow.prefix.versiontag` configures), `develop` and the main branch advanced, release branch removed.

## Step 6 — Hand off

Tell the user:
- The tag that was created.
- The branches that were touched.
- That nothing has been pushed.
- The exact push command they likely want, e.g. `git push origin <main-branch> develop --tags` — but do **not** run it. Per global rules, never push without explicit permission.

## Rules

- Never push. Not the branches, not the tag. The user pushes.
- Never `--amend` an existing commit; never `--no-verify`.
- Never add Claude/AI attribution to commit messages or tag annotations.
- If any step fails partway (e.g. `bump-version.sh` errors, hook rejects the commit), stop and report. Do **not** try to clean up by running `git flow release delete` or resetting branches without asking — the user may want to inspect the partial state.
- If the user passed extra arguments after the version, treat them as freeform context for the release commit body / tag annotation.
