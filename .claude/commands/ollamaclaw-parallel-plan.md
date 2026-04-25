# Ollamaclaw Parallel Plan

**Purpose:** Decide whether a task can be parallelized across multiple terminals or should run sequentially.

**Mode:** Audit-only. This command does not create branches, worktrees, or commits.

## Execution

1. Run or interpret: `./scripts/parallel-safety-check.sh`
2. Ask for target slice names if not provided
3. Analyze file scopes for each slice
4. Recommend one of:
   - Single terminal (default)
   - Queued prompts in one terminal
   - Read-only second terminal
   - Separate worktree branches for true parallel work

## Rules

1. **Default to one terminal.** Parallel work introduces complexity and quota cost.
2. **Require non-overlapping file scopes** before approving parallel editing.
3. **One writer per branch.** Never allow two writers on the same branch.
4. **High-conflict files** (README, CLAUDE, .claude/, docs/) require sequential work.
5. **Before merge/commit:** Require `git-guardian` and `release-readiness.sh`.

## High-Conflict Files

These files require sequential, single-writer discipline:

- `README.md`
- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/agents/README.md`
- `docs/agent-team-playbook.md`
- `docs/next-five-lanes.md`
- `scripts/ollamaclaw`

## Decision Matrix

| Scenario | Recommendation |
|----------|----------------|
| Single slice, any files | One terminal |
| Multiple slices, same files | Queued prompts in one terminal |
| Multiple slices, non-overlapping files | Separate branches + parallel terminals |
| Read-only audit while editing | Two terminals (one writer, one auditor) |
| Cloud quota limited | One terminal only |
| High-conflict files touched | Sequential work only |

## Output Format

After analysis, print:

```
PARALLEL PLAN RECOMMENDATION
============================
Terminal Mode: [SINGLE / QUEUED / PARALLEL / READ-ONLY]
Branch Strategy: [CURRENT / SEPARATE / N/A]
File Scopes: [LIST PER SLICE]
Validation Required: [git-guardian, release-readiness, etc.]
Cloud Note: [QUOTA WARNING if applicable]
```

## Pre-Commit Requirements

Before any parallel work is merged:

1. Each branch passes `./scripts/release-readiness.sh`
2. Run `./scripts/parallel-safety-check.sh` to confirm no conflicts
3. Run `git-guardian` agent for final review
4. Merge one branch at a time
5. Run `ollamaclaw-doctor.sh` after all merges
