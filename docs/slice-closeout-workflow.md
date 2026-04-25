# Slice Closeout Workflow

## Why Closeout Exists

After completing work on a slice, you need a consistent way to:

1. Validate the harness is still healthy (doctor, source truth, agent inventory)
2. Verify release readiness before marking done
3. Update the slice queue status to reflect completion
4. Capture closeout metadata (when, what, branch, commit)
5. Log the completion to the session record

The slice closeout workflow provides a single command that does all of this **without** committing, pushing, or modifying git state.

## What Closeout Is NOT

| Concept | Closeout | Reality |
|---------|----------|---------|
| **Commit** | Does NOT commit | Git commit captures code changes |
| **Push** | Does NOT push | Push shares code remotely |
| **Branch switch** | Does NOT switch branches | You stay on current branch |
| **Worktree** | Does NOT create worktrees | Worktrees are for parallel implementation |
| **Session log** | Appends to session log | Session log is the historical record |
| **Queue status** | Updates queue status | Queue tracks intent, not code |

## When to Run Closeout

Run `./scripts/slice-closeout.sh` in these situations:

| Situation | Command | Why |
|-----------|---------|-----|
| **After successful commit/push** | `done <slice-name> "<summary>"` | Mark slice complete, log closeout |
| **Slice is blocked** | `blocked <slice-name> "<reason>"` | Track blocker, keep in queue |
| **Slice is deferred** | `deferred <slice-name> "<reason>"` | Postpone for later, keep in queue |
| **Unsure if ready** | `dry-run <slice-name>` | Validate without modifying |

## Safe Sequence

The recommended sequence for completing a slice:

```
1. Finish implementation
   # All code changes complete

2. Validate
   ./scripts/ollamaclaw-doctor.sh
   ./scripts/source-truth-check.sh
   ./scripts/agent-inventory.sh

3. Run OC Self-Test (if scripts/commands changed)
   ./scripts/oc self-test

4. Commit
   git add <files>
   git commit -m "Add feature X"

5. Run closeout
   ./scripts/slice-closeout.sh done <slice-name> "Summary of what was done"

6. Upload zip/package (if needed)
   # Create and audit package for handoff

7. Pick next slice
   ./scripts/slice-queue.sh next
```

## Commands

### help

Show usage and examples:

```bash
./scripts/oc closeout help
./scripts/slice-closeout.sh help
```

### dry-run <slice-name>

Validate a slice before marking it done:

```bash
./scripts/oc closeout dry-run batch-2-repo-hygiene-agents
./scripts/slice-closeout.sh dry-run batch-2-repo-hygiene-agents
```

What dry-run does:

1. Verifies slice exists in `.ollamaclaw/slices/`
2. Shows current slice status and goal
3. Runs diagnostic scripts:
   - `ollamaclaw-doctor.sh`
   - `source-truth-check.sh`
   - `agent-inventory.sh`
   - `release-readiness.sh`
4. Prints what would be changed
5. Does NOT modify any files

Use dry-run when:

- You want to verify diagnostics pass before committing
- You are unsure if the slice is ready for closeout
- You want to see what closeout would do

### done <slice-name> "<summary>"

Mark a slice as completed:

```bash
./scripts/oc closeout done batch-2-repo-hygiene-agents "Added 6 repo hygiene agents"
./scripts/slice-closeout.sh done batch-2-repo-hygiene-agents "Added 6 repo hygiene agents"
```

What done does:

1. Verifies slice exists
2. Warns if working tree has uncommitted changes (does not stop)
3. Runs diagnostic scripts
4. Stops on hard FAIL (does not mark done if diagnostics fail)
5. Updates slice status to `done` via `slice-queue.sh status`
6. Appends closeout notes to slice file:
   ```markdown
   ---
   Closed: 2026-04-25T12:00:00-04:00
   Summary: Added 6 repo hygiene agents
   Branch: main
   Commit: a1b2c3d
   ```
7. Logs to session via `session-log.sh`
8. Prints recommended next command: `./scripts/slice-queue.sh next`

### blocked <slice-name> "<reason>"

Mark a slice as blocked by an external dependency:

```bash
./scripts/slice-closeout.sh blocked feature-x "Waiting on API access"
```

What blocked does:

1. Updates slice status to `blocked`
2. Appends blocker reason to slice file:
   ```markdown
   ---
   Blocked: 2026-04-25T12:00:00-04:00
   Reason: Waiting on API access
   ```
3. Logs to session via `session-log.sh`

Blocked slices remain in the queue for future unblocking.

### deferred <slice-name> "<reason>"

Mark a slice as deferred (lower priority):

```bash
./scripts/slice-closeout.sh deferred nice-to-have "Lower priority than Q2 goals"
```

What deferred does:

1. Updates slice status to `deferred`
2. Appends deferral reason to slice file:
   ```markdown
   ---
   Deferred: 2026-04-25T12:00:00-04:00
   Reason: Lower priority than Q2 goals
   ```
3. Logs to session via `session-log.sh`

Deferred slices remain in the queue for future reactivation.

## Why Closeout Does NOT Commit or Push

The closeout workflow intentionally does NOT:

- **Commit**: Git commit is a separate, auditable action. You should review changes with `git-guardian` before committing.
- **Push**: Pushing shares code remotely. This should be a deliberate, separate action.
- **Switch branches**: Branch management is orthogonal to closeout.
- **Create worktrees**: Worktrees are for parallel implementation, not closeout.

This separation of concerns ensures:

1. **Clear audit trail**: Commit messages capture code changes; closeout notes capture workflow state.
2. **Flexibility**: You can close out a slice that was committed manually or via agent.
3. **Safety**: Closeout cannot accidentally commit unreviewed changes.
4. **Clarity**: Queue status tracks workflow state; git tracks code.

## Diagnostic Scripts

Closeout runs these scripts to verify harness health:

| Script | Purpose |
|--------|---------|
| `ollamaclaw-doctor.sh` | Project structure, agent integrity, settings safety, tooling |
| `source-truth-check.sh` | Docs/scripts/agents consistency |
| `agent-inventory.sh` | Agent frontmatter validation |
| `release-readiness.sh` | Pre-release safety gate |

If any script reports FAIL, closeout stops before marking done.

## Closeout Notes Format

When a slice is marked done, the following metadata is appended to the slice file:

```markdown
---
Closed: 2026-04-25T12:00:00-04:00
Summary: Added 6 repo hygiene agents
Branch: stellar/heygen-social-ops
Commit: 4d10744
```

Fields:

- `Closed`: ISO 8601 timestamp when closeout ran
- `Summary`: Brief description of what was accomplished
- `Branch`: Git branch name at closeout time
- `Commit`: Short git commit hash at closeout time

## Session Log Integration

Closeout logs each action to the session log:

| Command | Session Log Entry |
|---------|-------------------|
| `done` | "Completed slice: batch-2-repo-hygiene-agents - Added 6 repo hygiene agents" |
| `blocked` | "Blocked slice: feature-x - Waiting on API access" |
| `deferred` | "Deferred slice: nice-to-have - Lower priority than Q2 goals" |

Session logs are stored at `.ollamaclaw/sessions/YYYY-MM-DD.md`.

## Examples

### Example 1: Completing a Slice

```bash
# After committing changes
./scripts/slice-closeout.sh done batch-2-repo-hygiene-agents "Added 6 repo hygiene agents"

# Output:
# === Slice Closeout: batch-2-repo-hygiene-agents ===
# [PASS] Slice file exists
# [PASS] Working tree is clean
# [PASS] All diagnostics passed
# Updated slice status to 'done'
# Appending closeout notes
# Logged to session
#
# Recommended next command:
#   ./scripts/slice-queue.sh next
```

### Example 2: Dry-Run Before Closeout

```bash
# Verify before marking done
./scripts/slice-closeout.sh dry-run batch-2-repo-hygiene-agents

# Output:
# === Slice Closeout Dry-Run ===
# [PASS] Slice file exists
# Status: planned
# Goal: Add missing Batch 2 repo hygiene and source truth agents
#
# === Diagnostics Summary ===
# PASS: 4 | WARN: 0 | FAIL: 0
#
# Dry-run complete. No files were modified.
```

### Example 3: Handling a Blocker

```bash
# Slice is blocked by external dependency
./scripts/slice-closeout.sh blocked feature-x "Waiting on API access"

# Output:
# === Slice Closeout: feature-x (Blocked) ===
# Updated slice status to 'blocked'
# Appending blocker reason
# Logged to session
#
# Slice remains in queue for future unblocking.
```

## Relationship to Other Workflows

| Workflow | Relationship |
|----------|--------------|
| [Slice Queue](./slice-queue-workflow.md) | Closeout updates queue status |
| [Slice Planning](./slice-planning-workflow.md) | Closeout is the final step after commit |
| [Release Readiness](./release-readiness-workflow.md) | Closeout runs release-readiness as a diagnostic |
| [Doctor](./doctor-workflow.md) | Closeout runs doctor as a diagnostic |
| [Session Log](./session-log-workflow.md) | Closeout appends to session log |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (command completed) |
| 1 | Error (slice not found, invalid command, diagnostics failed) |

## Troubleshooting

### "Slice not found"

Ensure the slice exists:

```bash
./scripts/slice-queue.sh list
```

Slice names must be lowercase hyphenated (e.g., `batch-2-repo-hygiene-agents`).

### "Diagnostics failed"

Review the diagnostic output to identify the failure:

```bash
./scripts/ollamaclaw-doctor.sh
./scripts/source-truth-check.sh
./scripts/agent-inventory.sh
./scripts/release-readiness.sh
```

Fix any FAIL items before re-running closeout.

### "Uncommitted changes" warning

This is a warning, not an error. Closeout does not commit, so uncommitted changes are allowed. However, you should:

1. Review changes: `git status`
2. Commit if ready: `git commit -m "..."`
3. Then re-run closeout
