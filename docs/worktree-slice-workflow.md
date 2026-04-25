# Worktree Slice Workflow

## Why This Exists

Ollamaclaw supports parallel work through git worktrees, but creating worktrees without discipline leads to:

- Branch confusion and file chaos
- Multiple writers on the same branch
- Unmerged worktrees accumulating over time
- Failed merges due to file-scope conflicts

This workflow defines when and how to use worktrees safely.

## Relationship to Parallel Slice Workflow

This document complements [Parallel Slice Workflow](./parallel-slice-workflow.md):

| Doc | Focus |
|-----|-------|
| [Parallel Slice Workflow](./parallel-slice-workflow.md) | When parallel work is safe, terminal roles, file-scope rules |
| [Worktree Slice Workflow](./worktree-slice-workflow.md) | How to create, manage, and clean up git worktrees |

## When to Use Worktrees

Use a worktree when:

- Slices are tracked in the slice queue
- Implementing **non-overlapping features** in parallel
- Each slice has its **own branch** and **separate file scope**
- You need **true isolation** (separate VS Code windows, separate Claude Code sessions)
- Cloud quota can support parallel consumption

- Implementing **non-overlapping features** in parallel
- Each slice has its **own branch** and **separate file scope**
- You need **true isolation** (separate VS Code windows, separate Claude Code sessions)
- Cloud quota can support parallel consumption

## When NOT to Use Worktrees

Do NOT create a worktree when:

- Working on a **single slice** (use one terminal)
- Editing **shared docs** (README, CLAUDE, `.claude/`, `docs/`)
- Tasks are **sequential** or have cross-slice dependencies
- You would run **multiple writers on the same branch**

**Recommended default:** One writer terminal + one WSL validation terminal.

## Slice Queue as Source of Slices

Before planning a worktree, add the slice to the queue:

```bash
./scripts/slice-queue.sh add <slice-name> "<goal>"
./scripts/slice-queue.sh next
```

The queue provides the slice name and goal; worktree-slice handles git isolation.

See [Slice Queue Workflow](./slice-queue-workflow.md) for details.

## The Safe Sequence

```
1. Add slice to queue (if not already tracked)
   ./scripts/slice-queue.sh add <slice-name> "<goal>"

2. Plan the slice
   ./scripts/worktree-slice.sh plan <slice-name>

2. Run parallel safety check
   ./scripts/parallel-safety-check.sh

3. Create the worktree
   ./scripts/worktree-slice.sh create <slice-name>

4. Launch Claude Code in that worktree
   cd ../ollamaclaw-slice-<slice-name>
   ollama launch claude --model qwen3.5:397b-cloud

5. Validate branch independently
   ./scripts/ollamaclaw-doctor.sh
   ./scripts/release-readiness.sh

6. Merge one branch at a time
   - Each branch passes release-readiness.sh independently
   - Run parallel-safety-check.sh to confirm no file conflicts
   - Merge to main, one at a time

7. Rerun release-readiness after merge
   ./scripts/release-readiness.sh
```

## Branch Naming Convention

All worktree branches follow this pattern:

```
slice/<name>
```

Examples:
- `slice/docs-cleanup`
- `slice/agent-inventory-ui`
- `slice/release-automation`

## Worktree Folder Naming Convention

Worktrees live in sibling folders:

```
../ollamaclaw-slice-<name>
```

Examples:
- `../ollamaclaw-slice-docs-cleanup`
- `../ollamaclaw-slice-agent-inventory-ui`
- `../ollamaclaw-slice-release-automation`

## High-Conflict Files

These files require **sequential work** (one slice at a time):

| File | Why |
|------|-----|
| `README.md` | Project entry point, high drift risk |
| `CLAUDE.md` | Core operating instructions |
| `.claude/settings.json` | Settings corruption risk |
| `.claude/agents/README.md` | Agent index drift |
| `docs/agent-team-playbook.md` | Playbook drift risk |
| `docs/next-five-lanes.md` | Roadmap drift risk |
| `scripts/ollamaclaw` | Primary launcher script |

Parallel slices touching these files must run **sequentially**, not in parallel worktrees.

## Cleanup Guidance

After merging a worktree branch:

```bash
# List worktrees
git worktree list

# Remove the worktree directory
git worktree remove ../ollamaclaw-slice-<name>

# Delete the branch (if merged and safe)
git branch -d slice/<name>
```

If the branch was force-pushed or is otherwise unmerged:

```bash
git branch -D slice/<name>  # Force delete (use carefully)
```

## Warning

**Do not run multiple writers on the same branch.**

Each worktree should have:
- One Claude Code writer session
- One branch
- Non-overlapping file scope

Multiple writers on the same branch cause:
- Overwritten changes
- Git conflicts
- Lost work
- Session context confusion

## Rollback Plan

If a worktree slice goes wrong:

```bash
# In the worktree directory
cd ../ollamaclaw-slice-<name>

# Discard uncommitted changes
git reset --hard HEAD

# Or abandon the branch entirely
cd ..
git worktree remove ollamaclaw-slice-<name>
git branch -D slice/<name>
```
