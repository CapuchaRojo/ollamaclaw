# Slice Queue Workflow

## Why the Queue Exists

Ollamaclaw needs a lightweight way to track planned work slices before creating worktrees, launching Claude Code sessions, or running parallel implementations.

The slice queue provides:

- A simple backlog of intended work
- Clear status tracking (planned, active, blocked, done, deferred)
- File-based storage (no database, no JSON)
- Integration with worktree and parallel slice workflows

## What the Queue Is NOT

| Concept | Queue | Reality |
|---------|-------|---------|
| **Roadmap** | Strategic lanes, long-term goals | Slice queue tracks immediate next slices |
| **Slice Queue** | Intent backlog, Markdown files | Tracks what to work on next |
| **Worktree** | Git isolation for parallel work | Actual isolated directory + branch |
| **Session Log** | Record of what was done | `.ollamaclaw/sessions/YYYY-MM-DD.md` |

## When to Add a Slice

Add a slice to the queue when:

- You have a clear, bounded goal
- The work can be validated independently
- You want to track it before starting implementation
- You need to defer work until dependencies resolve

## Status Lifecycle

```
planned ──▶ active ──▶ done
    │           │
    ▼           ▼
deferred    blocked
```

| Status | Meaning | When to Use |
|--------|---------|-------------|
| `planned` | Ready to start | Default for new slices |
| `active` | Currently being worked on | One slice at a time unless worktree |
| `blocked` | Waiting on external dependency | API access, decisions, other branches |
| `done` | Completed and validated | After release-readiness passes |
| `deferred` | Postponed | Lower priority, not urgent |

## Commands

```bash
# Add a new slice
./scripts/slice-queue.sh add <slice-name> "<goal>"

# List all slices
./scripts/slice-queue.sh list

# Show a specific slice
./scripts/slice-queue.sh show <slice-name>

# Update status
./scripts/slice-queue.sh status <slice-name> <status>

# Find next planned slice
./scripts/slice-queue.sh next

# Show help
./scripts/slice-queue.sh help
```

## How the Queue Interacts with Other Workflows

### roadmap-status.sh

The roadmap (`docs/next-five-lanes.md`) defines strategic lanes and long-term goals. The slice queue holds the next actionable slices derived from roadmap lanes.

**Flow:** Roadmap lane → Slice added to queue → Slice becomes active → Slice marked done

### worktree-slice.sh

Before creating a worktree:

1. Add slice to queue (if not already tracked)
2. Run `./scripts/worktree-slice.sh plan <slice-name>`
3. Run `./scripts/parallel-safety-check.sh`
4. Create worktree if parallel-safe

The queue provides the slice name and goal; worktree-slice handles git isolation.

### parallel-safety-check.sh

Before running parallel slices:

1. Each slice should be in the queue with distinct file scopes
2. Run `./scripts/parallel-safety-check.sh` to confirm no file-scope conflicts
3. Each parallel slice needs its own branch/worktree

### release-readiness.sh

Before marking a slice done:

1. Run `./scripts/release-readiness.sh`
2. Fix any FAIL items
3. Commit changes
4. Update slice status: `./scripts/slice-queue.sh status <slice-name> done`

### session-log.sh

After completing a slice:

```bash
./scripts/session-log.sh "Completed slice: <slice-name> - <brief description>"
```

The session log captures what was done; the queue captures what to do next.

## Recommended Sequence

```
1. Add slice to queue
   ./scripts/slice-queue.sh add docs-cleanup "Clean and align documentation"

2. Check what's next
   ./scripts/slice-queue.sh next

3. Plan worktree (if parallel-safe)
   ./scripts/worktree-slice.sh plan docs-cleanup
   ./scripts/parallel-safety-check.sh

4. Execute the slice
   # Work in one terminal (queued prompts) or separate worktree

5. Validate
   ./scripts/ollamaclaw-doctor.sh
   ./scripts/source-truth-check.sh
   ./scripts/release-readiness.sh

6. Mark done
   ./scripts/slice-queue.sh status docs-cleanup done

7. Log session
   ./scripts/session-log.sh "Completed docs-cleanup slice"
```

## Core Rule

**Queue tracks intent; Git tracks actual code.**

The slice queue is a planning tool. Git branches, commits, and worktrees are the implementation reality. Never confuse a planned slice with merged code.

## Slice File Structure

Each slice is a Markdown file at `.ollamaclaw/slices/<slice-name>.md`:

```markdown
# Slice: docs-cleanup
Status: planned
Goal: Clean and align documentation after worktree protocol
Branch:
Worktree:
File Scope:
Validation:
Blockers:
Notes:
Created: 2026-04-25T10:00:00+00:00
Updated: 2026-04-25T10:00:00+00:00
```

Fields:

- `Status`: Current state (planned/active/blocked/done/deferred)
- `Goal`: One-line description of what success looks like
- `Branch`: Git branch name (filled when worktree planned)
- `Worktree`: Worktree path (filled when worktree created)
- `File Scope`: Which files will change (filled during planning)
- `Validation`: How to verify completion (filled during planning)
- `Blockers`: What's blocking progress (if status is blocked)
- `Notes`: Additional context
- `Created`/`Updated`: Timestamps

## Naming Convention

Slice names must be:

- Lowercase letters, numbers, and hyphens only
- 2-64 characters
- Descriptive but concise

Examples:

- `docs-cleanup`
- `agent-inventory-ui`
- `release-automation`
- `json-leak-detector`

## Multiple Slices

You can have multiple slices in different statuses:

```
planned:     docs-cleanup, agent-inventory-ui
active:      release-automation (one active slice per branch)
blocked:     cloud-integration (waiting on API key)
done:        slice-queue-foundation
deferred:    ui-dashboard (low priority)
```

## Cleanup

Slices are never deleted—they are part of the project history. If a slice is no longer relevant:

- Mark as `deferred` if it might be revisited
- Leave as `done` if completed
- Add a note explaining why something was deferred or abandoned
