# Agent Team Playbook

This playbook explains how Ollamaclaw's reusable subagents coordinate when auditing **VetCan** or other target repos.

## Agent Roles

| Role | Agent | Responsibility |
|------|-------|----------------|
| Scout | `repo-scout` | Maps unknown repos, identifies surfaces and risks |
| Domain Auditors | `studio-drift-auditor`, `voice-safety-auditor`, `payment-safe-reviewer`, `medical-boundary-reviewer` | Protect product truth in their domain |
| Validator | `test-commander` | Runs minimal relevant tests |
| Scribe | `release-scribe` | Documents changes, rollback, client-safe summaries |

## Default Orchestration Flow

```
┌─────────────┐     ┌───────────────────┐     ┌───────────────┐     ┌───────────────┐
│  Repo Scout │────▶│ Domain Auditor(s) │────▶│   Test        │────▶│   Release     │
│  (first)    │     │ (as needed)       │     │   Commander   │     │   Scribe      │
└─────────────┘     └───────────────────┘     └───────────────┘     └───────────────┘
```

1. **Repo Scout** runs first for unknown scope.
2. **Domain Auditors** run before customer-facing changes.
3. **Test Commander** chooses smallest validation.
4. **Release Scribe** writes final notes.

---

## Workflow: VetCan Studio Wording Change

**Scenario:** Updating Studio onboarding text or launch copy.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/vetcan — identify Studio folders and A21/A22 truth docs" |
| 2 | `studio-drift-auditor` | "Audit /path/to/vetcan Studio copy against A21/A22 truth" |
| 3 | `test-commander` | "Run minimal tests for /path/to/vetcan after changing Studio text" |
| 4 | `release-scribe` | "Document Studio wording changes for commit" |

**Blocker Condition:** If A21/A22 truth docs are missing in VetCan, `studio-drift-auditor` reports BLOCKER. Do not commit wording changes without canonical truth.

---

## Workflow: VetCan Voice-Preview Change

**Scenario:** Adding voice demo, ElevenLabs integration, or audio preview.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/vetcan — identify voice/audio files and configs" |
| 2 | `voice-safety-auditor` | "Audit /path/to/vetcan voice features for preview-only compliance" |
| 3 | `test-commander` | "Run minimal tests for /path/to/vetcan voice changes" |
| 4 | `release-scribe` | "Document voice-preview changes with blocker status" |

**Blocker Condition:** If voice scope truth is missing, default to preview-only. Any live-call language is BLOCKER.

---

## Workflow: VetCan Payment Copy Change

**Scenario:** Updating billing reminders, payment link copy, or invoice text.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/vetcan — identify payment/billing surfaces" |
| 2 | `payment-safe-reviewer` | "Audit /path/to/vetcan payment copy for PCI-safe language" |
| 3 | `test-commander` | "Run minimal tests for /path/to/vetcan payment copy changes" |
| 4 | `release-scribe` | "Document payment copy changes with client-safe summary" |

**Blocker Condition:** If PCI scope truth is missing, any card-handling claim is BLOCKER.

---

## Workflow: VetCan Medical/Front-Desk Automation Change

**Scenario:** Adding intake forms, scheduling, reminders, or vet workflow automation.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/vetcan — identify medical/vet/PHI surfaces" |
| 2 | `medical-boundary-reviewer` | "Audit /path/to/vetcan for medical advice or PHI scope drift" |
| 3 | `test-commander` | "Run minimal tests for /path/to/vetcan medical boundary changes" |
| 4 | `release-scribe` | "Document medical boundary changes with blocker status" |

**Blocker Condition:** If medical scope truth is missing, default to admin-only. Any diagnosis/treatment claim is BLOCKER.

---

## Workflow: VetCan Release Audit

**Scenario:** Preparing a release with mixed changes (Studio, voice, payment, medical).

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/vetcan — full structure and risk map" |
| 2 | `studio-drift-auditor` | "Audit Studio wording in /path/to/vetcan" |
| 3 | `voice-safety-auditor` | "Audit voice features in /path/to/vetcan" |
| 4 | `payment-safe-reviewer` | "Audit payment copy in /path/to/vetcan" |
| 5 | `medical-boundary-reviewer` | "Audit medical boundaries in /path/to/vetcan" |
| 6 | `test-commander` | "Run relevant tests for /path/to/vetcan release" |
| 7 | `release-scribe` | "Generate release notes for /path/to/vetcan" |

**Blocker Condition:** If any domain auditor reports BLOCKER, do not release until resolved.

---

## Workflow: Generic External Repo Audit

**Scenario:** Auditing a repo other than VetCan.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `repo-scout` | "Scout /path/to/external-repo — map structure and surfaces" |
| 2 | (conditional) | Invoke domain auditors based on surfaces detected |
| 3 | `test-commander` | "Run minimal tests for /path/to/external-repo" |
| 4 | `release-scribe` | "Document changes for /path/to/external-repo" |

**Note:** Domain auditors require canonical truth in the target repo. If missing, they report BLOCKER.

---

## Truth Boundary Rules

1. **Ollamaclaw is the harness.** It hosts agents but does not contain product truth.
2. **Target repo (e.g., VetCan) holds truth.** A21/A22 docs, voice scope, payment scope, medical boundaries live there.
3. **Missing truth = BLOCKER.** Domain auditors do not guess. They report blocker and stop.
4. **Never widen capability.** Prefer narrower, safer wording until truth explicitly supports wider claims.

---

## Command Center Workflow

Start Ollamaclaw harness work via the OC Command Center:

```bash
./scripts/oc status      # Fast summary: git, slice queue, doctor checks
./scripts/oc toolchain   # Tool prerequisites
./scripts/oc doctor      # Health check
./scripts/oc truth       # Docs/scripts/agents consistency
./scripts/oc agents      # Agent governance
./scripts/oc release     # Pre-commit/push verification
```

Then route to specialist agents:

```bash
task-router              # Route to appropriate agent
commit-captain           # Create commit message
```

See [docs/command-center-workflow.md](./command-center-workflow.md) for the full command table.

---

## Ollamaclaw Install-Stage Workflows

Workflows for maintaining the Ollamaclaw harness itself.

### Step 0: Doctor Preflight (Recommended First)

**Before any harness work**, run the doctor:

```bash
./scripts/oc doctor
```

Or directly:

```bash
./scripts/ollamaclaw-doctor.sh
```

This validates project structure, agent integrity, settings safety, tooling, script executability, and documentation presence. Fix any FAIL items before proceeding to specialist agents.

**If tooling failures occur** (missing zip, zstd, curl, etc.):

```bash
./scripts/toolchain-doctor.sh   # Diagnose missing tools
```

Install missing tools manually, then re-run doctor.

---

### Workflow: Broken WSL/Ollama/Claude Setup

**Scenario:** Commands not found, routing broken, environment confusion.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: diagnose broken setup" |
| 2 | `toolchain-doctor.sh` | `./scripts/toolchain-doctor.sh` |
| 3 | `env-sentinel` | "Check WSL, Ollama, Claude Code, Git, PATH, versions" |
| 4 | `wsl-mechanic` | "Diagnose WSL path/shell/permission issues" |
| 5 | `ollama-route-verifier` | "Confirm model routing is correct" |

**Blocker Condition:** If critical tool is missing, `toolchain-doctor.sh` prints manual install commands. Do not auto-install.

---

### Workflow: Model Quota or Routing Confusion

**Scenario:** Cloud quota exhausted, seeing raw tool-call JSON, unsure which model to use.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `ollama-route-verifier` | "Confirm current model route and cloud/local status" |
| 2 | `model-route-advisor` | "Recommend cloud vs local strategy based on task and quota" |

**Blocker Condition:** If cloud quota exhausted, pause cloud agent work or switch to local helper only.

---

### Workflow: Adding a New Subagent

**Scenario:** Converting an agent idea into `.claude/agents/*.md`.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: add new agent with exact purpose" |
| 2 | `agent-template-smith` | "Create agent definition with canonical frontmatter" |
| 3 | `agent-lint-reviewer` | "Check new agent for overlap, missing boundaries, unsafe permissions" |
| 4 | `git-guardian` | "Review staged agent files" |
| 5 | `commit-captain` | "Create commit message for new agent" |

**Blocker Condition:** If agent-lint-reviewer reports BLOCKER, fix before committing.

---

### Workflow: Pre-Commit Review

**Scenario:** Changes ready, need to commit safely.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: pre-commit review" |
| 2 | `git-guardian` | "Review git status, branch state, risky files" |
| 3 | `commit-captain` | "Create commit plan and message" |

**Blocker Condition:** If do-not-commit files detected (`.env*`, credentials), exclude before staging.

---

### Workflow: Zip/Source Package Audit Preparation

**Scenario:** Preparing to zip, upload, or trust a source package/manual patch.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: audit before zip/upload" |
| 2 | `source-truth-check.sh` | "Run automated source truth consistency check" |
| 3 | `zip-auditor` | "Audit the ZIP/package against expected files and safety rules" |
| 4 | `git-guardian` | "Review working tree, ignored files, and staging risk" |
| 5 | `settings-warden` | "Check settings for dangerous permissions or local config leakage" |

**Blocker Condition:** If secrets, `.claude/settings.local.json`, `.env*`, nested junk archives, or missing required files are detected, flag before packaging. If source truth check reports FAIL, fix contradictions first.

---

### Workflow: Agent Governance

**Scenario:** Adding new agents safely without README drift, playbook drift, or boundary confusion.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: add new agent(s) with clear boundaries" |
| 2 | `./scripts/agent-inventory.sh` | "Run baseline inventory check" |
| 3 | `agent-indexer` | "Plan README index and category updates" |
| 4 | `agent-lint-reviewer` | "Check for overlap, vague scope, unsafe permissions" |
| 5 | `playbook-steward` | "Add/update workflows for new agents" |
| 6 | `git-guardian` | "Review all staged changes" |
| 7 | `commit-captain` | "Create commit message" |

**Blocker Condition:** If `agent-lint-reviewer` reports BLOCKER (overlap, unsafe permissions, vague boundaries), fix before committing. If `agent-inventory.sh` fails (missing frontmatter, deprecated `type: subagent`), fix before proceeding.

**Rule:** Do not mass-create agents without governance, inventory, and playbook updates.

---

### Workflow: Repo Hygiene

**Scenario:** Making changes to scripts, dependencies, docs, or preparing a release with full hygiene audit.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: repo hygiene audit" |
| 2 | `patch-planner` | "Plan minimal safe hygiene changes" |
| 3 | `source-truth-librarian` | "Verify docs, scripts, agents are consistent" |
| 4 | `docs-to-code-syncer` | "Verify documented commands match implemented scripts" |
| 5 | `script-hardener` | "Review scripts for safety, portability, clear errors" (if scripts touched) |
| 6 | `dependency-scout` | "Review dependencies, lockfiles, install docs" (if dependencies/install docs touched) |
| 7 | `security-sweeper` | "Search for secrets, unsafe commands, permission risks" |
| 8 | `license-warden` | "Review license, attribution, reference-only boundaries" (if reference/license docs touched) |
| 9 | `rollback-planner` | "Create rollback plan for all changes" |
| 10 | `git-guardian` | "Review all staged changes for release safety" |
| 11 | `./scripts/release-readiness.sh` | Run release readiness check |
| 12 | `commit-captain` | "Create commit message" |

**Blocker Condition:** If any agent reports BLOCKER (secrets found, unsafe scripts, license risk, missing rollback), fix before committing.

---

### Workflow: Release Readiness

**Scenario:** Preparing to commit, push, zip, upload, or hand off a release.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: release readiness audit" |
| 2 | `release-readiness.sh` | `./scripts/release-readiness.sh` |
| 3 | `git-guardian` | "Review staged changes for release safety" |
| 4 | `source-truth-librarian` | "Verify reference-only boundaries if touching reference docs" |
| 5 | `zip-auditor` | "Audit ZIP/package before upload or handoff" |
| 6 | `release-scribe` | "Generate release notes with doctor/source-truth/inventory results" |
| 7 | `commit-captain` | "Create commit message for release" |

**Blocker Condition:** If `release-readiness.sh` reports FAIL, fix blockers before proceeding. If reference docs are touched without copy-nothing confirmation, flag as BLOCKER.

---

### Workflow: Slice Queue Workflow

**Scenario:** Planning and tracking slices before implementation.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: define slice goal" |
| 2 | `slice-queue.sh list` | `./scripts/slice-queue.sh list` |
| 3 | `slice-queue.sh add/show/next` | `./scripts/slice-queue.sh add <name> "<goal>"` |
| 4 | `slice-planner` | Plan slice scope and validation |
| 5 | `worktree-slice.sh plan` (if parallel-safe) | `./scripts/worktree-slice.sh plan <slice-name>` |
| 6 | `git-guardian` | "Review changes" |
| 7 | `release-readiness.sh` | `./scripts/release-readiness.sh` |
| 8 | `commit-captain` | "Create commit message" |

**Note:** The slice queue tracks intent; Git tracks actual code. Add slices before starting work.

---

### Workflow: OC Self-Test Workflow

**Scenario:** Validating the command center and core workflows after major harness changes.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `oc self-test` | `./scripts/oc self-test` |
| 2 | (if needed) `oc self-test full` | `./scripts/oc self-test full` |
| 3 | `release-readiness.sh` | `./scripts/release-readiness.sh` |
| 4 | `git-guardian` | "Review staged changes for release safety" |
| 5 | `slice-closeout.sh` | `./scripts/slice-closeout.sh done <slice-name> "<summary>"` |

**Blocker Condition:** If `oc self-test` reports FAIL, fix blockers before proceeding. Known acceptable WARNs: root ZIP, `_bootstrap_junk`, uncommitted changes.

**Note:** Self-test does NOT launch Claude Code, create packages, or create worktrees.

---

### Workflow: Slice Closeout Workflow

**Scenario:** Finalizing a completed slice after commit.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `release-readiness.sh` | `./scripts/release-readiness.sh` |
| 2 | `git-guardian` | "Review staged changes for release safety" |
| 3 | `commit-captain` | "Create commit message" |
| 4 | `slice-closeout.sh dry-run` | `./scripts/slice-closeout.sh dry-run <slice-name>` |
| 5 | `slice-closeout.sh done/blocked/deferred` | `./scripts/slice-closeout.sh done <slice-name> "<summary>"` |
| 6 | `slice-queue.sh next` | `./scripts/slice-queue.sh next` |

**Blocker Condition:** If `release-readiness.sh` reports FAIL, fix blockers before closeout. If `slice-closeout.sh dry-run` reports FAIL, do not mark done.

**Note:** Closeout does NOT commit or push. It updates queue status, appends closeout notes, and logs to session.

---

### Workflow: Artifact Packaging Workflow

**Scenario:** Creating a safe source package for upload, sharing, or client handoff.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: define package purpose and destination" |
| 2 | `artifact-hygiene-check.sh` | `./scripts/artifact-hygiene-check.sh` |
| 3 | `release-readiness.sh` | `./scripts/release-readiness.sh` |
| 4 | `package-ollamaclaw.sh` | `./scripts/package-ollamaclaw.sh [filename.zip]` |
| 5 | `zip-auditor` | "Audit this package: .ollamaclaw/artifacts/filename.zip" |
| 6 | `release-scribe` | "Document package creation for commit/session log" |
| 7 | `slice-closeout.sh` | `./scripts/slice-closeout.sh done <slice-name> "<summary>"` |

**Blocker Condition:** If `artifact-hygiene-check.sh` or `release-readiness.sh` reports FAIL, fix blockers before packaging. If `zip-auditor` reports BLOCKER, do not upload.

**Note:** Packages go to `.ollamaclaw/artifacts/` (git-ignored). Upload manually after audit.

**Exclusions:** The package script automatically excludes:
- `.git/`, `.claude/settings.local.json`, `.env*`, `*.pem`, `*.key`
- `node_modules/`, `__pycache__/`, `.venv/`, `venv/`
- `_bootstrap_junk/`, `*.tar*`, root-level `*.zip`
- `.ollamaclaw/artifacts/`, `.ollamaclaw/tmp/`

---

### Workflow: Parallel Slice Workflow

**Scenario:** Implementing multiple independent slices simultaneously using multiple terminals or worktrees.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: define slice names and file scopes" |
| 2 | `slice-queue.sh add` | Add each slice to queue: `./scripts/slice-queue.sh add <name> "<goal>"` |
| 3 | `parallel-safety-check.sh` | `./scripts/parallel-safety-check.sh` |
| 4 | `task-router` | "Route each slice to appropriate agent chain" |
| 5 | (Implement) | Parallel work on separate branches/worktrees |
| 6 | `git-guardian` | "Review changes from each branch before merge" |
| 7 | `release-readiness.sh` | `./scripts/release-readiness.sh` (each branch) |
| 8 | `release-readiness.sh` | `./scripts/release-readiness.sh` (after merge) |
| 9 | `commit-captain` | "Create commit message for merged changes" |

**Blocker Condition:** If `parallel-safety-check.sh` reports high-conflict file conflicts, use sequential work instead. If `release-readiness.sh` reports FAIL on any branch, fix before merge.

**File Scope Rule:** Parallel slices must have non-overlapping file scopes. High-conflict files (README, CLAUDE, .claude/, docs/) require sequential work.

---

### Workflow: Worktree Slice Workflow

**Scenario:** Creating an isolated worktree for parallel implementation.

| Step | Agent / Script | Command |
|------|----------------|---------|
| 1 | `scope-lock` | "Lock scope: define slice goal, file scope, branch name" |
| 2 | `slice-queue.sh add` | `./scripts/slice-queue.sh add <slice-name> "<goal>"` |
| 3 | `worktree-slice.sh plan` | `./scripts/worktree-slice.sh plan <slice-name>` |
| 4 | `parallel-safety-check.sh` | `./scripts/parallel-safety-check.sh` |
| 5 | `task-router` | "Route slice to appropriate agent chain" |
| 6 | `worktree-slice.sh create` | `./scripts/worktree-slice.sh create <slice-name>` |
| 7 | (Implement) | Work in the new worktree |
| 8 | `release-readiness.sh` | `./scripts/release-readiness.sh` (in worktree) |
| 9 | `git-guardian` | "Review changes before merge" |
| 10 | `release-readiness.sh` | `./scripts/release-readiness.sh` (after merge) |
| 11 | `commit-captain` | "Create commit message" |
| 12 | `slice-queue.sh status` | `./scripts/slice-queue.sh status <slice-name> done` |

**Blocker Condition:** If `parallel-safety-check.sh` reports FAIL, do not create the worktree. If `release-readiness.sh` reports FAIL in the worktree, fix before merge.

**Cleanup:** After merge, remove worktree with `git worktree remove <path>` and delete branch with `git branch -d slice/<name>` if safe.

See [Worktree Slice Workflow](../docs/worktree-slice-workflow.md) for details.

---

## Claw Code Emulation Docs

Ollamaclaw emulates concepts from the Claw Code reference implementation without copying code. These docs capture the architectural decisions:

| Doc | Purpose |
|-----|---------|
| [Provider Routing](./provider-routing.md) | Cloud-first model routing vs. Claw Code's multi-provider sniffing |
| [Tool Abstraction](./tool-abstraction.md) | Tool-call behavior, JSON leakage issue, smoke-test requirements |
| [Agent Protocol](./agent-protocol.md) | `.claude/agents/` system vs. Claw Code's slash-command/runtime model |
| [Session Design](./session-design.md) | Session logging approach vs. Claw Code's `.claw/sessions/*.jsonl` |
| [Launcher Patterns](./launcher-patterns.md) | `ollama launch claude` vs. `claw` binary patterns |

**Reference audit source:** `/mnt/c/Users/mich3/GitHubProjects/_references/claw-code` (read-only, no LICENSE — reference-only artifact)

---

## Reference-Driven Build Lanes

Ollamaclaw's strategic build lanes are derived from reference analysis:

- [Next Five Lanes](./next-five-lanes.md) — 5-lane roadmap with goals, slices, and validation

**Lane summary:**

| Lane | Goal | First Slice |
|------|------|-------------|
| 1 | Model routing hardening | Update provider-routing.md |
| 2 | JSON-leak detection | Auto-detect in smoke test |
| 3 | Session logging evolution | JSONL option |
| 4 | Agent-chain orchestration | Quick command reference |
| 5 | Release audit discipline | Reference-only verification |

**Recommended order:** 1 → 2 → 5 → 3 → 4
