# Ollamaclaw Worktree Plan

Plan a parallel worktree slice for Ollamaclaw.

## Usage

```
/ollamaclaw-worktree-plan <slice-name>
```

## Behavior

This command:

1. Runs `./scripts/worktree-slice.sh plan <slice-name>` to generate a plan
2. Runs `./scripts/parallel-safety-check.sh` to verify safety
3. Recommends the appropriate approach:
   - **Queued prompts** for sequential, same-file work
   - **One writer + validation terminal** for most slices
   - **Separate worktree** for true parallel, non-overlapping work

## Safety Rules

- This command **never creates a worktree** automatically
- It only plans and recommends
- Worktree creation requires explicit user request via `./scripts/worktree-slice.sh create <slice-name>`

## If Slice Name Is Missing

Ask the user for a slice name before proceeding.

## High-Conflict Files

Recommend sequential work if the slice touches:

- `README.md`
- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/agents/README.md`
- `docs/agent-team-playbook.md`
- `docs/next-five-lanes.md`
- `scripts/ollamaclaw`

See [Worktree Slice Workflow](../docs/worktree-slice-workflow.md) for details.
