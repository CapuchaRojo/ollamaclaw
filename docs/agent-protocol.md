# Agent Protocol

## Overview

Ollamaclaw uses Claude Code's **project-local subagent system** (`.claude/agents/`) to orchestrate specialized agents for harness maintenance and external repo audits.

This differs from Claw Code's approach, which uses **slash commands** (`/subagent`, `/plugin`) executed by a runtime binary.

## Architecture Comparison

| Aspect | Ollamaclaw | Claw Code Reference |
|--------|------------|---------------------|
| Agent definition | Markdown files in `.claude/agents/` | Rust crates + plugin manifests |
| Invocation | Claude Code `/` command or Agent tool | Slash commands (`/subagent name`) |
| Runtime | Claude Code CLI orchestrates | `claw` binary orchestrates |
| Extension model | Claude Code Agent SDK | Plugin system with lifecycle hooks |
| Language | Markdown prompts | Rust + Python parity layer |

**Key insight:** Ollamaclaw leverages Claude Code's built-in agent system. Claw Code builds its own runtime from scratch.

## Agent Categories

### Install-Stage Harness Agents

For maintaining Ollamaclaw itself (WSL, Ollama, Claude Code, launchers, git):

| Agent | Purpose |
|-------|---------|
| `scope-lock` | Locks goal, target, allowed files, stop condition before work |
| `env-sentinel` | Checks WSL, Ollama, Claude Code, Git, PATH, versions |
| `wsl-mechanic` | Diagnoses WSL path, shell, permission, .wslconfig issues |
| `launcher-smith` | Maintains scripts/ollamaclaw and launcher docs |
| `settings-warden` | Reviews .claude/settings.json for permissions and safety |
| `ollama-route-verifier` | Confirms model routing is correct |
| `model-route-advisor` | Recommends cloud vs local strategy |
| `git-guardian` | Reviews git status, diffs, staging risk |
| `commit-captain` | Creates commit plans and messages |

### Cross-Repo Audit Agents

For auditing external repos (VetCan, etc.):

| Agent | Purpose |
|-------|---------|
| `repo-scout` | Maps target repo structure, dependencies, surfaces |
| `studio-drift-auditor` | Checks Studio wording against A21/A22 truth |
| `voice-safety-auditor` | Audits voice/call features for preview-only posture |
| `payment-safe-reviewer` | Audits payment/billing/PCI claims |
| `medical-boundary-reviewer` | Audits medical/vet/PHI boundaries |
| `test-commander` | Recommends and runs minimal relevant tests |
| `release-scribe` | Generates commit notes, rollback notes, client-safe summaries |

### Package/ZIP Audit Agent

| Agent | Purpose |
|-------|---------|
| `zip-auditor` | Audits source/patch ZIP packages for expected files, secrets, junk |

## Recommended Invocation Chains

### Harness Maintenance Flow

```
1. scope-lock          → Lock scope and constraints
2. env-sentinel        → Diagnose environment state
3. [specialist agent]  → wsl-mechanic, launcher-smith, etc.
4. git-guardian        → Review changes before commit
5. commit-captain      → Create commit message
```

### External Repo Audit Flow

```
1. repo-scout                 → Map target repo (always first)
2. [domain auditors]          → studio-drift, voice-safety, payment-safe, medical-boundary
3. test-commander             → Run minimal relevant tests
4. release-scribe             → Generate commit/release notes
```

### Package Audit Flow

```
1. scope-lock          → Lock package purpose and expected contents
2. zip-auditor         → Inspect archive without extracting to live repo
3. git-guardian        → Review source tree and staging risk
4. commit-captain      → Create commit/package note if needed
```

## Agent Definition Format

Agents are defined in `.claude/agents/*.md` with frontmatter:

```markdown
---
name: agent-name
description: One-line purpose statement
type: specialist
tools: Read, Glob, Grep, Bash
---

Agent instructions and behavior details...
```

See `.claude/agents/README.md` for full format specification.

## Truth Boundary Protocol

**Critical rule:** Domain auditors require **canonical truth** in the target repo.

| Scenario | Behavior |
|----------|----------|
| A21/A22 docs exist in VetCan | `studio-drift-auditor` compares wording against them |
| A21/A22 docs missing | `studio-drift-auditor` reports **BLOCKER** — no commit |
| Voice scope truth missing | Default to preview-only; live-call language is BLOCKER |
| PCI scope truth missing | Any card-handling claim is BLOCKER |
| Medical scope truth missing | Default to admin-only; diagnosis/treatment is BLOCKER |

**Ollamaclaw hosts agents but does not contain product truth.** Truth lives in target repos (e.g., VetCan).

## Claw Code Emulation Notes

Ollamaclaw **emulates concepts, not code**:

| Claw Code Concept | Ollamaclaw Approach |
|-------------------|---------------------|
| Slash command routing | Claude Code Agent tool + `/` commands |
| Plugin lifecycle | Predefined agent set in `.claude/agents/` |
| Runtime orchestration | Claude Code CLI is the orchestrator |
| 50+ module runtime | ~15 focused agents with clear boundaries |

**Design principle:** Prefer fewer, well-defined agents over a large runtime surface.

## Related Docs

- [Agent Team Playbook](./agent-team-playbook.md) — Workflow examples and blocker conditions
- [Architecture](./architecture.md) — High-level system overview
- [Claw Code Reference Audit](../_references/claw-code/docs/ARCHITECTURE_AUDIT_PHASE1.md) — Source material (read-only)
