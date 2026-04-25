# Ollamaclaw Slice Queue

Audit-first slice queue management.

## What This Command Does

This is a read-only audit wrapper for the slice queue system. It helps you:

- View the current slice queue
- Identify the next planned slice
- Decide whether to work on a slice, defer it, or plan a worktree

## Usage

```bash
/ollamaclaw-slice-queue
```

## Behavior

1. **Audit first** — Run `./scripts/slice-queue.sh list` to show all slices
2. **Show next** — Run `./scripts/slice-queue.sh next` to find the next planned slice
3. **Recommend** — Based on the queue state, recommend whether to:
   - Work the next planned slice (if one exists and is not blocked)
   - Defer blocked slices (if blockers are resolvable)
   - Create a worktree plan (if parallel-safe and non-overlapping)
   - Use queued prompts in one terminal (if slices touch same files)

## What This Command Does NOT Do

- Does NOT edit slice files
- Does NOT create worktrees
- Does NOT switch branches
- Does NOT commit or push
- Does NOT launch Claude Code sessions

## Recommended Follow-ups

After reviewing the queue:

```bash
# Start working on a slice
./scripts/slice-queue.sh status <slice-name> active

# Plan a worktree (if parallel-safe)
./scripts/worktree-slice.sh plan <slice-name>

# Use queued prompts (same terminal, sequential work)
# Just prompt Claude Code directly with the slice goal
```

## When to Use

- Starting a new work session
- Deciding what to work on next
- Checking if parallel work is safe
- Reviewing project backlog
