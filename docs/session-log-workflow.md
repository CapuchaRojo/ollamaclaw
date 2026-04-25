# Session Log Workflow

## Overview

Ollamaclaw provides lightweight session logging scripts to track work progress, model routing changes, and audit activities. This is a **Phase 1** manual logging system — simple, human-readable Markdown logs.

## Scripts

| Script | Purpose |
|--------|---------|
| `./scripts/session-log.sh` | Append a timestamped entry to today's session log |
| `./scripts/session-summary.sh` | View today's log (or a specific date) |

## What Gets Logged

Session logs capture **high-level work notes**:

- What was done (e.g., "Added provider routing docs")
- Current git branch
- Current working directory relative to project root
- Timestamp

**Example entry:**

```markdown
## 2026-04-24 18:30:00

**Branch:** main
**Directory:** docs

Added Claw Code emulation architecture docs (5 new files).

---
```

## What Should NOT Be Logged

Do **not** log:

- Secrets or API keys (scripts don't capture these, but don't paste them in messages)
- Full conversation transcripts (use Claude Code's built-in features)
- Sensitive file contents
- Credential paths or `.env` file contents

## When to Log

### After a Committed Slice

```bash
./scripts/session-log.sh "Committed: Claw Code emulation docs (5 files created, 2 modified)"
```

### After a Cloud Quota Issue

```bash
./scripts/session-log.sh "Cloud quota exhausted — paused agent work, switched to local helper mode"
```

### After a Model Routing Change

```bash
./scripts/session-log.sh "Updated launcher to use qwen3.5:397b-cloud as default; fallback is launch-qwen-cloud.sh"
```

### After a Package/ZIP Audit

```bash
./scripts/session-log.sh "Completed zip-auditor review of source package — no secrets detected, 3 expected files missing"
```

## How to Use

### Log a Work Note

```bash
./scripts/session-log.sh "Your message here"
```

### View Today's Log

```bash
./scripts/session-summary.sh
```

### View a Specific Date

```bash
./scripts/session-summary.sh 2026-04-24
```

### View Recent Logs Manually

```bash
ls -la .ollamaclaw/sessions/
cat .ollamaclaw/sessions/2026-04-24.md
```

## Location

Session logs are stored in:

```
.ollamaclaw/sessions/YYYY-MM-DD.md
```

This directory is **not** gitignored — logs are intentionally versioned project history.

## Comparison: Claw Code Session Model

| Feature | Claw Code Reference | Ollamaclaw Phase 1 |
|---------|---------------------|--------------------|
| Format | JSONL (structured, machine-readable) | Markdown (human-readable) |
| Auto-logging | Yes (runtime-managed) | No (manual scripts) |
| Rotation | 256KB threshold | Daily files (no auto-rotation) |
| Resume support | `--resume` flag | Manual (copy context) |
| Tool call logging | Automatic per-call | Not logged |

**Key difference:** Claw Code treats sessions as runtime state. Ollamaclaw Phase 1 treats sessions as **work notes** — a lightweight alternative to full transcript logging.

## Future Roadmap

### Structured JSONL Option (Phase 2)

Add a `--json` flag to output structured entries:

```bash
./scripts/session-log.sh --json "Message"
# Outputs: {"timestamp": "...", "message": "...", "branch": "...", "cwd": "..."}
```

### Auto-Hook Integration (Phase 3)

Add a Claude Code hook in `.claude/settings.json`:

```json
{
  "hooks": {
    "afterResponse": "./scripts/session-log.sh \"Claude Code response completed\""
  }
}
```

This would auto-log every Claude Code turn (opt-in only).

### Package Audit Integration (Phase 3)

Have `zip-auditor` auto-log its findings:

```bash
zip-auditor --log ./scripts/session-log.sh "Zip audit complete: 12 files, 0 secrets, 2 missing"
```

### Release Scribe Integration (Phase 3)

Have `release-scribe` append commit notes to session logs:

```bash
release-scribe --log-session
```

This creates a unified work history alongside commit messages.

## Related Docs

- [Session Design](./session-design.md) — Full session architecture and future phases
- [Agent Protocol](./agent-protocol.md) — How agents fit into work logging
- [Launcher Patterns](./launcher-patterns.md) — Model routing changes worth logging
