# Session Design

## Overview

This document explains how Ollamaclaw currently handles sessions through Claude Code + Ollama, contrasts with Claw Code's session persistence model conceptually, and proposes a future lightweight session log design for Ollamaclaw.

## Current State: Claude Code Sessions

### How Sessions Work Today

Claude Code manages sessions internally:

- Sessions are tied to the Claude Code CLI process
- Conversation history is maintained in-memory during a session
- On restart, Claude Code may resume from its internal state
- No user-accessible session files in Ollamaclaw project directory

**Limitation:** Users cannot easily inspect, resume, or fork past sessions.

### Ollama's Role

Ollama Cloud acts as a **stateless proxy**:

```
Claude Code → Local Ollama (Anthropic-compatible endpoint) → Ollama Cloud → qwen3.5:397b-cloud → Response
```

Ollamaclaw does not call Anthropic API directly. Ollama routes requests through Ollama Cloud to the selected model.

Ollama does not persist session state. Each request is independent.

## Claw Code Session Model (Conceptual Reference)

The Claw Code reference implements `.claw/sessions/*.jsonl` with:

| Feature | Description |
|---------|-------------|
| File format | JSONL (one message per line) |
| Rotation | 256KB threshold — old sessions archive |
| Fork/provenance | Track branching conversations |
| Prompt history | Per-session command log |
| Workspace binding | Sessions tied to repo root to prevent cross-repo collisions |
| Resume flag | `--resume latest|<session-id>` CLI option |

**Key insight:** Claw Code treats sessions as **first-class artifacts** that users can inspect, resume, and manage.

## Proposed Ollamaclaw Session Log Design

### Design Goals

1. **Lightweight** — No 50-module runtime; simple file logging
2. **Optional** — Users can enable/disable per-project
3. **Inspectable** — Human-readable format (JSONL or markdown)
4. **Resume-friendly** — Enough context to restart a conversation

### Proposed Structure

```
.claude/sessions/
  ├── 2026-04-24-initial-audit.jsonl
  ├── 2026-04-24-claw-code-emulation.jsonl
  └── latest → symlink to most recent session
```

### Session Entry Format (JSONL)

```jsonl
{"timestamp": "2026-04-24T18:00:00Z", "role": "user", "content": "Audit the Claw Code reference"}
{"timestamp": "2026-04-24T18:00:05Z", "role": "assistant", "content": "I'll run scope-lock first..."}
{"timestamp": "2026-04-24T18:00:10Z", "role": "tool", "tool": "scope-lock", "result": "Scope locked"}
```

### Alternative: Markdown Format

```markdown
## Session: 2026-04-24-claw-code-emulation

### 18:00:00 — User
Audit the Claw Code reference

### 18:00:05 — Assistant
I'll run scope-lock first...

### 18:00:10 — Tool: scope-lock
Scope locked
```

### Implementation Considerations (Not Yet Implemented)

| Question | Options |
|----------|---------|
| Who writes logs? | Claude Code hook vs. custom middleware |
| When to rotate? | By size (256KB) or by date (daily) |
| Where to store? | Project-local (`.claude/sessions/`) or global (`~/.ollamaclaw/sessions/`) |
| Resume support? | Manual (user copies session) vs. automated (`--resume` flag) |

## Implemented Phase 1

Ollamaclaw now provides manual session logging scripts:

| Script | Purpose |
|--------|---------|
| `scripts/session-log.sh` | Append timestamped work notes to `.ollamaclaw/sessions/YYYY-MM-DD.md` |
| `scripts/session-summary.sh` | View today's log (or a specific date) |
| `docs/session-log-workflow.md` | Usage guide and when-to-log guidance |

**What Phase 1 logs:**

- High-level work notes (what was done)
- Git branch and working directory
- Timestamp

**What Phase 1 does NOT log:**

- Full conversation transcripts
- Individual tool calls
- Model responses

See [Session Log Workflow](./session-log-workflow.md) for usage.

## Recommendations

### Phase 1: Manual Session Logging (Implemented)

Users can now:

1. Log work notes: `./scripts/session-log.sh "Added provider routing docs"`
2. View logs: `./scripts/session-summary.sh`
3. Browse history: `.ollamaclaw/sessions/YYYY-MM-DD.md`

### Phase 2: Hook-Based Auto-Logging

Future enhancement:

- Add a post-response hook in `.claude/settings.json`
- Hook appends each turn to `.claude/sessions/<session-name>.jsonl`
- Session name derived from first user prompt or `--session` flag

### Phase 3: Resume Support

If Phase 2 proves valuable:

- Add `--resume latest|<name>` to `./scripts/ollamaclaw`
- Load session history and inject as context
- Fork support: `--fork <name>` creates new session with prior context

## Comparison Summary

| Feature | Claude Code (Current) | Claw Code Reference | Ollamaclaw (Proposed) |
|---------|----------------------|---------------------|----------------------|
| Session files | Internal, not exposed | `.claw/sessions/*.jsonl` | `.claude/sessions/*.jsonl` |
| Rotation | N/A | 256KB threshold | TBD (daily or size) |
| Fork/provenance | No | Yes | Future consideration |
| Resume flag | No | `--resume` | Future consideration |
| Workspace binding | Yes (implicit) | Yes (explicit) | Yes (project-local) |

## Related Docs

- [Tool Abstraction](./tool-abstraction.md) — How tool calls are logged
- [Launcher Patterns](./launcher-patterns.md) — Future `--session` and `--resume` flags
- [Architecture](./architecture.md) — Where session logging fits in the flow
