# Parallel Slice / Multi-Terminal Protocol

## Purpose

This document defines when and how to safely use multiple Claude Code terminals in Ollamaclaw for parallel work.

## Core Principle

**One writer per branch.** Multiple terminals are safe only when branch, file scope, and validation boundaries are clear.

## When to Use One Terminal

Use a single Claude Code terminal when:

- Working on a single slice or feature
- Editing shared docs (README, CLAUDE, .claude/, docs/)
- Running sequential tasks that build on each other
- Cloud quota is limited (multiple terminals consume quota faster)
- The task requires understanding context from previous prompts

**Recommended default:** One focused terminal + one WSL validation terminal.

## When to Use Multiple Terminals

Multiple terminals are appropriate when:

- Slices have **non-overlapping file scopes**
- Each slice has its **own branch or worktree**
- Tasks are **independent** (no cross-slice dependencies)
- You need **read-only audits** while one writer terminal edits
- Cloud quota can support parallel consumption

## Safe Terminal Roles

| Role | Description | Branch Requirement |
|------|-------------|-------------------|
| **Writer** | Primary editing session | Own branch/worktree |
| **Validator** | Runs tests, smoke tests, doctor | Same or different branch (read-only) |
| **Read-only Auditor** | Reviews code, docs, agents | Any branch (no edits) |
| **Separate Worktree Implementer** | Parallel implementation on isolated worktree | Separate worktree + separate branch |

## Unsafe Patterns

**Never do the following:**

| Pattern | Risk | Mitigation |
|---------|------|------------|
| Two writers on same branch | Git conflicts, overwritten changes | Use separate branches |
| Two sessions editing README/CLAUDE/docs at once | Drift, contradictions | Queue prompts in one terminal |
| Stale sessions continuing after settings/agents changed | Inconsistent behavior | Use /clear or fresh launch between major slices |
| Committing from multiple terminals without review | Unreviewed changes, double commits | Run git-guardian + release-readiness before any commit |
| Parallel edits to .claude/settings.json | Settings corruption | One terminal owns settings changes |

## Parallel Worktree Approach

For true parallel implementation work:

```
1. Add slices to queue — Track intent (see docs/slice-queue-workflow.md)
2. scope-lock          — Lock slice goal, file scope, branch name
3. worktree-slice.sh plan — Plan the worktree (see docs/worktree-slice-workflow.md)
4. parallel-safety-check.sh — Verify boundaries before create
5. worktree-slice.sh create — Create isolated worktree
6. Implement           — Non-overlapping files only
7. parallel-safety-check.sh — Verify boundaries before merge
8. git-guardian        — Review changes
9. release-readiness   — Pass before merge
10. Merge to main      — One slice at a time
```

Use `./scripts/worktree-slice.sh` for safe worktree management. See [Worktree Slice Workflow](./worktree-slice-workflow.md) for details.

### Non-Overlapping File Scopes

Parallel slices are safe when they touch **different** files:

| Slice A | Slice B | Safe? |
|---------|---------|-------|
| `scripts/new-tool.sh` | `docs/new-doc.md` | YES |
| `.claude/agents/agent-a.md` | `.claude/agents/agent-b.md` | YES |
| `README.md` | `README.md` | NO |
| `.claude/settings.json` | `.claude/settings.json` | NO |
| `docs/agent-team-playbook.md` | `docs/agent-team-playbook.md` | NO |

## Queue Prompt Approach

For related tasks in the same slice:

1. Use **one** Ollamaclaw terminal
2. Queue related prompts sequentially
3. Wait for each prompt to complete before the next
4. Use `/clear` or fresh launch between major slices

**Example:**
```
# Same terminal, queued prompts:
1. "Add parallel-safety-check.sh script"
2. "Now add the parallel-slice-workflow.md doc"
3. "Now update README to link the new doc"
```

## Cloud Usage Note

Multiple Claude Code terminals consuming cloud models:

- Drain quota faster (each terminal makes independent API calls)
- May hit rate limits if both are actively prompting
- Work best when one terminal is idle (auditing) while the other works

**Recommendation:** Use one focused prompt per terminal when possible.

## Recommended Default Setup

```
Terminal 1 (Writer):     Claude Code — qwen3.5:397b-cloud
Terminal 2 (Validator):  WSL bash — runs tests, doctor, smoke tests
```

This setup provides:
- Single source of truth for edits
- Fast validation loop
- No quota waste from parallel cloud calls
- No risk of conflicting edits

## Slice Queue as Planning Layer

Before planning parallel work, add slices to the queue:

```bash
./scripts/slice-queue.sh add <slice-name> "<goal>"
./scripts/slice-queue.sh list
```

The queue tracks intent; worktrees provide isolation. See [Slice Queue Workflow](./slice-queue-workflow.md) for details.

## Pre-Flight Check

Before starting parallel work, run:

```bash
./scripts/parallel-safety-check.sh
```

This script verifies:
- Git state (branch, worktrees, uncommitted changes)
- File-scope risk (high-conflict files)
- Harness safety (doctor, source truth, inventory)
- Provides SAFE / WARN / FAIL recommendation

## Merge / Review Sequence

When merging parallel work:

1. Each branch passes `release-readiness.sh` independently
2. Run `parallel-safety-check.sh` to confirm no file conflicts
3. Merge one branch at a time
4. Run `git-guardian` after each merge
5. Run full `ollamaclaw-doctor.sh` after all merges

## Rollback Plan

If parallel work causes issues:

1. `git status` — identify conflicted files
2. `git checkout --ours/--theirs <file>` — resolve per-file
3. `git reset --hard HEAD` — discard all uncommitted changes (nuclear)
4. `git worktree prune` — clean up abandoned worktrees
5. Fresh `ollama launch claude` — clear any stale sessions
