# Release Readiness Workflow

## Why This Workflow Exists

Ollamaclaw is the coding harness for VetCan and other client projects. Before committing, pushing, zipping, uploading, or handing off code, you must verify:

1. The harness itself is healthy (doctor passes).
2. Docs and scripts are consistent (source truth passes).
3. Agents have valid frontmatter (inventory passes).
4. No sensitive files will leak (settings.local.json, .env, keys, PEMs).
5. Reference-only boundaries are documented (no Claw Code / c.src.code copying unless license allows).
6. Required release docs exist and are up to date.

This workflow provides a fast, non-destructive gate before any release action.

## When to Run

Run `./scripts/release-readiness.sh` in these situations:

| Situation | Why |
|-----------|-----|
| **Before commit** | Catch sensitive files, missing docs, harness issues |
| **Before push** | Final safety check before sharing remotely |
| **Before creating/uploading a ZIP** | Verify package safety, no secrets or junk |
| **After applying manual patches** | Confirm no structural damage |
| **Before reference-driven implementation** | Confirm reference-only boundaries are clear |
| **Before client handoff** | Ensure release docs and audit trails exist |

## What Scripts to Run

### Primary Command

```bash
./scripts/release-readiness.sh
```

This script runs all checks and reports PASS / WARN / FAIL.

### Supporting Scripts (Optional Deep Dives)

```bash
./scripts/ollamaclaw-doctor.sh    # Harness health
./scripts/source-truth-check.sh   # Docs/scripts/agents consistency
./scripts/agent-inventory.sh      # Agent frontmatter validation
```

## How release-scribe and zip-auditor Fit

### release-scribe

After release-readiness passes, invoke `release-scribe` to document:

- What changed (from git diff)
- Validation results (doctor, source truth, agent inventory)
- Rollback notes
- Client-safe summary
- Not-changed / not-claimed section

```bash
# Example invocation
claude "Document this release for VetCan"
```

### zip-auditor

Before zipping or trusting a ZIP package, invoke `zip-auditor`:

- Inspect archive contents without extracting
- Flag secrets, local config, nested archives, junk
- Confirm expected files present
- Report PASS / WARN / BLOCKER verdict

```bash
# Example invocation
claude "Audit this ZIP before I upload it: /path/to/package.zip"
```

## Reference-Only Rule

Ollamaclaw emulates concepts from the Claw Code reference implementation and c.src.code Python source analysis **without copying code**.

### Current Stance

- **Claw Code**: Reference-only, concept emulation. No code copying unless license explicitly allows it.
- **c.src.code**: Reference-only, concept mapping. No code copying.
- **Ollamaclaw agents/docs**: Original implementation inspired by reference analysis.

### Verification

Before any release that touches reference docs:

1. Confirm `docs/reference-synthesis.md` states reference-only stance.
2. Confirm `docs/c-src-reference-map.md` states reference-only stance.
3. If LICENSE is missing from referenced sources, docs must say "reference-only / copy-nothing".
4. Never describe docs-only emulation as runtime capability.

## PASS / WARN / FAIL Meanings

### PASS

All checks passed. The harness is ready for release actions.

```
RESULT: PASS - All release readiness checks passed.
```

**Action:** Safe to commit, push, zip, or hand off.

### WARN

Warnings detected but no hard blockers. Examples:

- Uncommitted changes in working tree
- Branch not tracking upstream
- Root ZIP files present (may be intentional)
- Reference docs do not clearly state reference-only
- Session log directory missing

```
RESULT: WARN - Warnings detected. Safe to proceed with caution.
```

**Action:** Review warnings. Safe to proceed if warnings are expected or acceptable.

### FAIL

Hard release blockers detected. Examples:

- Doctor, source truth, or agent inventory failed
- Sensitive files tracked (.env, .key, .pem, settings.local.json)
- Required release docs missing
- Reference docs missing (reference-synthesis.md, c-src-reference-map.md)

```
RESULT: FAIL - Hard release blockers detected. Fix before proceeding.
```

**Action:** Fix failures before proceeding. Script exits with code 1.

## Recommended Commit Discipline

1. Run `./scripts/release-readiness.sh` and fix any FAIL items.
2. Review WARN items; accept or fix.
3. Run `git-guardian` agent to review staged files:
   ```bash
   claude "Review staged changes with git-guardian"
   ```
4. Run `release-scribe` to generate commit notes:
   ```bash
   claude "Generate commit notes with release-scribe"
   ```
5. Commit with a narrow, accurate message:
   ```bash
   git commit -m "Add release readiness workflow"
   ```
6. Run doctor one more time after commit if desired.

## Full Release Checklist

```
1. scope-lock (if adding new functionality)
2. ./scripts/release-readiness.sh
3. Fix any FAIL items
4. Review WARN items
5. git-guardian (review staged files)
6. source-truth-librarian (if touching reference docs)
7. zip-auditor (if creating/uploading ZIP)
8. release-scribe (generate commit notes)
9. commit-captain (create commit message)
10. git push (after all checks pass)
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | PASS or WARN (safe to proceed) |
| 1 | FAIL (hard blockers detected) |
