# Ollamaclaw Release Readiness

## Purpose

Project slash command for release readiness audit. Run this before commit, push, zip, upload, or handoff.

## Behavior

1. **Audit-only.** Do not edit files unless explicitly requested.
2. Run or interpret `./scripts/release-readiness.sh`.
3. Summarize FAIL / WARN / PASS results.
4. Recommend next smallest fix.

## Invocation

```bash
/ollamaclaw-release-readiness
```

Or:

```bash
claude "Run release readiness check"
```

## What This Command Does

1. Runs `./scripts/release-readiness.sh` (or reads output if user already ran it).
2. Reports:
   - Harness health (doctor, source truth, agent inventory)
   - Git state (branch, uncommitted changes, upstream tracking)
   - Package safety (sensitive files, ZIP artifacts, bootstrap junk)
   - Reference-only rule (reference docs exist and state copy-nothing)
   - Release docs (required files present)
   - Session log status
3. Summarizes PASS / WARN / FAIL counts.

## Recommended Agents to Invoke

Based on results, recommend or invoke:

| Agent | When to Invoke |
|-------|----------------|
| `git-guardian` | Before commit; review staged files for safety |
| `release-scribe` | Generate commit notes, rollback notes, client-safe summary |
| `zip-auditor` | Before creating/uploading ZIP packages |
| `source-truth-librarian` | When touching reference docs or source maps |

## Output Format

```markdown
### Release Readiness Result

**Branch:** <branch name>
**Harness Health:** <doctor result> | <source truth result> | <agent inventory result>

### Summary
- PASS: <count>
- WARN: <count>
- FAIL: <count>

### FAIL Items (Blockers)
- <list or none>

### WARN Items (Review)
- <list or none>

### Recommended Next Step
<smallest safe action: fix X, run git-guardian, invoke release-scribe, etc.>
```

## Constraints

- **Do not edit files** unless user explicitly requests it.
- **Do not commit or push.**
- **Do not launch Claude Code** for the check itself (script is standalone).
- **Do not call network.**
- Treat `.claude/settings.local.json`, `.env*`, `*.pem`, `*.key` as do-not-share.
- Reference-only rule: confirm Claw Code / c.src.code references are concept-only unless license allows copying.
