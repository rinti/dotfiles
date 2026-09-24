---
name: security-hub
description: Check AWS Security Hub for HIGH/CRITICAL findings with the aws CLI and write them as markdown issue files under ./.security-hub-issues/. With the argument "fix", pick the first open issue file and propose a fix. Use when the user asks to check Security Hub, review security findings, turn Security Hub findings into issues, or fix a Security Hub issue.
---

# Security Hub to issues

Fetch active Security Hub findings at HIGH severity or above, group them per control, and write one issue file per control to `./.security-hub-issues/` in the current repo. That directory is the only destination: never look for or use `.scratch/`, GitHub, GitLab or any other tracker.

Two modes, chosen by the skill argument:

- **No argument (default)**: fetch findings and write issue files. Follow "Process: collect".
- **`fix`**: take the first open issue file and propose a fix. Follow "Process: fix". Don't touch Security Hub in this mode unless the user asks.

Issue files have a `Status:` line that is either `open` or `fixed`.

## Process: collect

### 1. Resolve profile and region

Take `--profile` (and `--region`, if given) from the user's message. Require an explicit profile: if the user gave none, ask for one before running anything.

### 1b. Prepare the issues directory

```bash
mkdir -p ./.security-hub-issues
git check-ignore -q .security-hub-issues || printf '\n.security-hub-issues/\n' >> .gitignore
```

Create the directory if it is missing, and make sure it is gitignored: if `git check-ignore` reports it is not, append `.security-hub-issues/` to the repo's `.gitignore` (create the file if needed). Do this before fetching findings so a later failure never leaves issue files untracked.

### 2. Fetch findings

```bash
aws securityhub get-findings \
  --profile "$PROFILE" \
  --filters '{
    "SeverityLabel": [
      {"Value": "CRITICAL", "Comparison": "EQUALS"},
      {"Value": "HIGH", "Comparison": "EQUALS"}
    ],
    "RecordState": [{"Value": "ACTIVE", "Comparison": "EQUALS"}],
    "WorkflowStatus": [
      {"Value": "NEW", "Comparison": "EQUALS"},
      {"Value": "NOTIFIED", "Comparison": "EQUALS"}
    ]
  }' \
  --query 'Findings[].{Id:Id,GeneratorId:GeneratorId,Title:Title,Severity:Severity.Label,Description:Description,Resources:Resources[].Id,RemediationText:Remediation.Recommendation.Text,RemediationUrl:Remediation.Recommendation.Url,FirstObserved:FirstObservedAt,Product:ProductName}' \
  --max-items 200 \
  --output json
```

The filter keeps only findings that still need action: HIGH/CRITICAL, record state ACTIVE, workflow NEW or NOTIFIED. The `--query` trims each finding to what the issue needs — raw findings are enormous. If the output ends with a `NextToken`, continue with `--starting-token` until it doesn't.

### 3. Group per control

Security Hub emits one finding per resource; the unit of work is the control. Group findings by `GeneratorId`: one issue per control, listing every affected resource. Order CRITICAL before HIGH.

### 4. Skip already-filed controls

Every issue file carries a marker line `sechub:<GeneratorId>`. Run `grep -rl 'sechub:<GeneratorId>' ./.security-hub-issues/` for each group and drop groups that already have a file with `Status: open`. A `fixed` file doesn't block a new one: if the finding is active again, it gets a fresh issue.

### 5. Confirm with the user

Present a table: severity, control title, affected-resource count — plus a line naming any controls skipped as already filed. Write files only after the user approves.

### 6. Write the issue files

One file per control, CRITICAL first, at `./.security-hub-issues/<NN>-<slug>.md`. `<NN>` continues from the highest number already in the directory (starting at `01`), and `<slug>` is the control title lower-cased and hyphenated. The file starts with `# [<SEVERITY>] <Title>`, then `Labels: security` and `Status: open`, then the template body. Add other labels only if the user asks for them.

If the user asks to mark the findings as handled in Security Hub afterwards, set them to NOTIFIED: `aws securityhub batch-update-findings --profile "$PROFILE" --finding-identifiers Id=<Id>,ProductArn=<ProductArn> --workflow Status=NOTIFIED` (fetch `ProductArn` in step 2's query if needed).

## Process: fix

### 1. Pick the issue

List `./.security-hub-issues/*.md` sorted by filename and take the first file with `Status: open`. If the directory is missing or every file is `fixed`, say so and stop; don't fetch new findings in this mode.

### 2. Understand it

Read the file: severity, description, affected resources, remediation text and URL. Then look at how the affected resources are managed in this repo (Terraform, CDK, CloudFormation, serverless config, scripts) by grepping for the resource ids, names or ARNs from the file. Fetch the remediation URL if the file's remediation text is too thin to act on.

### 3. Propose

Present, in this order:

- **Issue**: filename, severity, control title, affected-resource count.
- **Root cause**: what is misconfigured and where it is defined in this repo (file paths), or that it is not managed here and has to be changed in the AWS console/CLI.
- **Proposed fix**: the concrete change, per resource if they differ. Show the diff or commands you intend to apply. Call out side effects (downtime, cost, access changes).
- **Verification**: how to confirm the fix, ending with the Security Hub re-check.

Then stop and wait. Do not edit any file or run any mutating command until the user accepts the proposal. If they ask for changes, revise and present again.

### 4. Implement on acceptance

Apply exactly the accepted change. Then, in the issue file, set `Status: fixed`, tick the "Remediation applied" acceptance box, and append a `## Fix` section with the date, what was changed (file paths or commands) and how to verify. Leave the Security Hub box unticked until the re-check passes or the user confirms.

<issue-template>

## Finding

**<Severity>** — <Title> (<Product>, first observed <FirstObserved>)

<Description>

## Affected resources

- <resource id, one per line>

## Remediation

<RemediationText>

<RemediationUrl>

## Acceptance criteria

- [ ] Remediation applied to every affected resource
- [ ] Finding resolved in Security Hub (re-check passes or workflow set to RESOLVED)

---

`sechub:<GeneratorId>` | profile: <profile>

</issue-template>
