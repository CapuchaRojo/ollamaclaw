# Slice Planning Workflow

## Purpose

Plan and execute focused slices of work in Ollamaclaw. A slice is a unit of work that:

- Has a clear goal and validation criteria
- Touches a bounded set of files
- Can be completed and reviewed independently

## Default: One Slice at a Time

**Recommended approach:** Complete one slice before starting the next.

Benefits:
- Clear git history
- Easier review and rollback
- No file-scope conflicts
- Lower cloud quota consumption

## When to Use Parallel Slices

Parallel work is appropriate only when:

- Slices have **non-overlapping file scopes**
- Each slice has its **own branch or worktree**
- Tasks are **independent** (no cross-slice dependencies)
- Cloud quota can support parallel consumption

See [Parallel Slice Workflow](./parallel-slice-workflow.md) for the full protocol.

## Slice Planning Steps

### 1. Define the Slice

Use `scope-lock` to articulate:

- Goal: What will this slice accomplish?
- File scope: Which files will change?
- Validation: How will we know it is done?
- Stop condition: What is out of scope?

### 2. Check Parallel Safety (If Applicable)

If considering parallel work, run:

```bash
./scripts/parallel-safety-check.sh
```

This script verifies:
- Git state (branch, worktrees, uncommitted changes)
- File-scope risk (high-conflict files)
- Harness safety (doctor, source truth, inventory)
- Provides SAFE / WARN / FAIL recommendation

### 3. Route the Task

Use `task-router` to select the appropriate agent chain for the slice type.

### 4. Implement

Work on the slice using one of these approaches:

| Approach | When to Use |
|----------|-------------|
| Single terminal | Default for most slices |
| Queued prompts | Related tasks in same slice |
| Read-only second terminal | Audit while implementing |
| Separate worktree | True parallel implementation |

### 5. Validate

Before marking the slice complete:

- Run `ollamaclaw-doctor.sh` (harness health)
- Run `source-truth-check.sh` (docs/scripts/agents consistency)
- Run `agent-inventory.sh` (if touching agents)
- Run relevant tests via `test-commander`

### 6. Review and Commit

- Run `git-guardian` to review changes
- Run `release-readiness.sh` before commit
- Use `commit-captain` to create commit message

## File Scope Guidelines

### Safe for Parallel Work

Slices that touch **different** files can run in parallel:

| Slice A | Slice B | Safe? |
|---------|---------|-------|
| `scripts/new-tool.sh` | `docs/new-doc.md` | YES |
| `.claude/agents/agent-a.md` | `.claude/agents/agent-b.md` | YES |
| `src/feature-x.py` | `src/feature-y.py` | YES (if no shared imports) |

### Requires Sequential Work

Slices that touch the **same** files must run sequentially:

| Slice A | Slice B | Why |
|---------|---------|-----|
| `README.md` | `README.md` | High-conflict file |
| `CLAUDE.md` | `CLAUDE.md` | High-conflict file |
| `.claude/settings.json` | `.claude/settings.json` | Settings corruption risk |
| `docs/agent-team-playbook.md` | `docs/agent-team-playbook.md` | Playbook drift risk |

### High-Conflict Files

These files require single-writer discipline:

- `README.md`
- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/agents/README.md`
- `docs/agent-team-playbook.md`
- `docs/next-five-lanes.md`
- `scripts/ollamaclaw`

## Queued Prompts Approach

For related tasks within a slice, use queued prompts in one terminal:

```
# Same terminal, sequential prompts:
1. "Add the new script at scripts/new-tool.sh"
2. "Now add documentation at docs/new-tool-workflow.md"
3. "Now update README.md to link the new doc"
4. "Now run ollamaclaw-doctor.sh to verify"
```

Benefits:
- Single source of truth for context
- No file-scope conflicts
- Efficient cloud quota usage
- Clear session log for the slice

## Session Management

### Starting a Slice

1. Run `/clear` or launch fresh Claude Code session
2. Run session startup checklist (git status, tooling check)
3. Define slice scope with `scope-lock`

### Ending a Slice

1. Validate (doctor, source truth, inventory)
2. Review (git-guardian)
3. Commit (commit-captain)
4. Log session: `./scripts/session-log.sh "Completed slice: <description>"`

### Between Slices

- Use `/clear` to reset context
- Or launch fresh `ollama launch claude --model qwen3.5:397b-cloud`
- Run startup checklist again

## Rollback Plan

If a slice goes wrong:

1. `git status` — identify changed files
2. `git checkout -- <file>` — revert specific files
3. `git reset --hard HEAD` — discard all uncommitted changes (nuclear)
4. `git log` — find last good commit
5. `git reset --hard <commit>` — roll back to previous state (use carefully)

See [Parallel Slice Workflow](./parallel-slice-workflow.md) for multi-terminal rollback guidance.
