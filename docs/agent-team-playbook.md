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

## Ollamaclaw Install-Stage Workflows

Workflows for maintaining the Ollamaclaw harness itself.

### Workflow: Broken WSL/Ollama/Claude Setup

**Scenario:** Commands not found, routing broken, environment confusion.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: diagnose broken setup" |
| 2 | `env-sentinel` | "Check WSL, Ollama, Claude Code, Git, PATH, versions" |
| 3 | `wsl-mechanic` | "Diagnose WSL path/shell/permission issues" |
| 4 | `ollama-route-verifier` | "Confirm model routing is correct" |

**Blocker Condition:** If critical tool is missing, stop and propose install commands.

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

**Scenario:** Preparing to zip or upload source package.

| Step | Agent | Command |
|------|-------|---------|
| 1 | `scope-lock` | "Lock scope: audit before zip/upload" |
| 2 | `git-guardian` | "Review all files, flag secrets or junk" |
| 3 | `settings-warden` | "Check settings for dangerous permissions" |

**Blocker Condition:** If secrets detected in working tree, flag before packaging.
