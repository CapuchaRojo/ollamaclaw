# Agent Governance

## Why Agent Governance Exists

Ollamaclaw hosts a growing library of reusable subagents for auditing external repos and maintaining the harness itself. Without governance:

- **README drift:** Agent index becomes inaccurate as agents are added/removed
- **Playbook drift:** Workflows reference nonexistent agents or files
- **Duplicate agents:** Overlapping purposes cause confusion
- **Vague boundaries:** Agents with unclear responsibilities
- **Frontmatter inconsistency:** Missing required fields break tooling

This governance layer ensures safe, scalable agent expansion.

---

## Current Agent File Standard

All agents live in `.claude/agents/*.md` and must follow this structure:

### Required Frontmatter

```markdown
---
name: agent-name
description: One-line purpose statement
tools: Read, Glob, Grep, Bash
model: inherit
---
```

### Required Fields

| Field | Format | Example |
|-------|--------|---------|
| `name:` | kebab-case | `agent-indexer` |
| `description:` | one line | `Maintains agent inventory and README index` |
| `tools:` | comma-separated | `Read, Glob, Grep, Bash` |
| `model:` | always `inherit` | `inherit` |

### Deprecated Fields

- `type: subagent` — **REMOVE** — no longer supported

### Naming Rules

- Use kebab-case: `agent-name.md`
- Be specific: `studio-drift-auditor` not `studio-agent`
- Avoid overlap: each agent should have a distinct boundary

### Category Rules

Agents are grouped into categories in `.claude/agents/README.md`:

1. **Harness / Install Agents** — WSL, Ollama, Claude Code, launchers, settings
2. **Repo Hygiene / Source Truth Agents** — docs-to-code sync, source-truth checks, script hardening, dependency scanning, security sweeping, license review, rollback planning, patch planning
3. **Cross-Repo Audit Agents** — VetCan auditors (studio, voice, payment, medical)
4. **Validation / Release Agents** — test-commander, release-scribe, git-guardian
5. **Package / Reference Agents** — zip-auditor, reference analysis
6. **Personal / Business / Future Agents** — only if they exist

**Batch 2 Note:** The recommended first expansion after governance is the Batch 2 Repo Hygiene agent pack: `script-hardener`, `dependency-scout`, `security-sweeper`, `license-warden`, `rollback-planner`, `patch-planner`.

---

## How to Add a New Agent Safely

**Do not mass-create agents without governance, inventory, and playbook updates.**

### Step-by-Step Process

1. **Lock scope**
   ```
   /agent scope-lock — lock goal, target, allowed files, stop condition
   ```

2. **Run inventory baseline**
   ```bash
   ./scripts/agent-inventory.sh
   ```

3. **Create agent definition**
   ```
   /agent agent-template-smith — create with canonical frontmatter
   ```

4. **Lint for overlap**
   ```
   /agent agent-lint-reviewer — check boundaries, permissions, duplication
   ```

5. **Update README index**
   ```
   /agent agent-indexer — add to correct category in .claude/agents/README.md
   ```

6. **Update playbook**
   ```
   /agent playbook-steward — add workflow if needed
   ```

7. **Review changes**
   ```
   /agent git-guardian — review staged files
   ```

8. **Commit**
   ```
   /agent commit-captain — create commit message
   ```

---

## Governance Agents

| Agent | Purpose |
|-------|---------|
| [`agent-indexer`](../.claude/agents/agent-indexer.md) | Maintains agent inventory, README index, categories, counts |
| [`playbook-steward`](../.claude/agents/playbook-steward.md) | Maintains agent-team-playbook.md workflows |
| [`readme-carpenter`](../.claude/agents/readme-carpenter.md) | Keeps README.md accurate and runnable |
| [`claude-md-steward`](../.claude/agents/claude-md-steward.md) | Keeps CLAUDE.md aligned with actual behavior |
| [`agent-lint-reviewer`](../.claude/agents/agent-lint-reviewer.md) | Checks agents for overlap, vague scope, unsafe permissions |
| [`agent-template-smith`](../.claude/agents/agent-template-smith.md) | Creates consistent agent definitions |

### Related Harness Agents

| Agent | Relationship |
|-------|--------------|
| [`source-truth-librarian`](../.claude/agents/source-truth-librarian.md) | Audits docs for contradictions; governance ensures agent docs stay aligned |
| [`docs-to-code-syncer`](../.claude/agents/docs-to-code-syncer.md) | Verifies documented commands match implemented scripts |
| [`git-guardian`](../.claude/agents/git-guardian.md) | Reviews agent file changes before commit |
| [`commit-captain`](../.claude/agents/commit-captain.md) | Creates commit messages for agent additions |

---

## Diagnostic Commands

### Agent Inventory

```bash
./scripts/agent-inventory.sh
```

Fast non-destructive check of `.claude/agents/` frontmatter. Exit code 1 if missing fields or deprecated `type: subagent` found.

### Source Truth Check

```bash
./scripts/source-truth-check.sh
```

Validates docs, scripts, and agents for contradictions and stale references.

### Doctor Preflight

```bash
./scripts/ollamaclaw-doctor.sh
```

Full harness health check including agent integrity validation.

---

## Agent Governance Workflow

Before creating new agents or modifying existing ones:

```
1. scope-lock — lock goal and boundaries
2. ./scripts/agent-inventory.sh — baseline current state
3. agent-indexer — plan README/category updates
4. agent-lint-reviewer — validate no overlap or unsafe permissions
5. playbook-steward — add/update workflows
6. git-guardian — review all changes
7. commit-captain — create commit message
```

---

## Rule: No Mass Agent Creation

**Do not create more than 4 agents in a single session without:**

1. Running `./scripts/agent-inventory.sh` before and after
2. Updating `.claude/agents/README.md` with correct categories
3. Updating `docs/agent-team-playbook.md` with new workflows
4. Running `agent-lint-reviewer` to check for overlap
5. Getting explicit user approval for the agent catalog plan

This prevents README drift, playbook drift, and agent boundary confusion.

---

## Rule: Repo Hygiene Agents Must Be Audit-First

**New repo hygiene agents must remain audit-first and mutation-averse.**

Repo hygiene agents (`script-hardener`, `dependency-scout`, `security-sweeper`, `license-warden`, `rollback-planner`, `patch-planner`) follow a strict audit-first discipline:

- They inspect and report, not edit.
- They propose exact fixes, not apply them.
- They require explicit user approval before any mutation.
- They flag blockers, not warnings, when safety is in question.

This prevents accidental destructive changes during hygiene audits.
