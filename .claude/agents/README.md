# Ollamaclaw Agent Library

Ollamaclaw hosts reusable project-local subagents for auditing external repos and maintaining the harness itself. These agents do not assume Ollamaclaw is the target — they audit **VetCan** or other specified repos.

## Primary Target

**VetCan** is the primary audit target. Other repos may be audited using the same agents.

---

## Harness / Install Agents

Agents for maintaining the Ollamaclaw harness itself: WSL, Ollama routing, Claude Code settings, launchers, subagent hygiene, git hygiene, and task routing.

| Agent | Purpose | When to Invoke |
|-------|---------|----------------|
| [`scope-lock`](scope-lock.md) | Locks goal, target repo, allowed files, and stop condition before work begins | When work starts getting broad, multiple agents involved, controlled patching needed |
| [`task-router`](task-router.md) | Selects which agent or agent chain should handle a user request | When request could match multiple agents, target repo unclear, workflow needs sequencing |
| [`env-sentinel`](env-sentinel.md) | Checks WSL, Ollama, Claude Code, Git, PATH, versions, memory hints, project health | Setup breaks, commands not found, cloud/local routing seems wrong, WSL memory/PATH confusion |
| [`wsl-mechanic`](wsl-mechanic.md) | Diagnoses WSL path, shell, permission, `.wslconfig`, mount, VS Code terminal issues | PowerShell and WSL behavior differ, Windows/Linux paths mixed, executable bits fail, WSL memory/swap tuning |
| [`ollama-route-verifier`](ollama-route-verifier.md) | Confirms Claude Code is routing through Ollama and the intended model | Changing model route, seeing quota errors, seeing raw tool-call JSON, testing cloud vs local |
| [`model-route-advisor`](model-route-advisor.md) | Recommends cloud vs local model strategy based on task, quota, speed, hardware | Choosing qwen3.5 cloud vs local, cloud quota exhausted, local model performance questionable |
| [`launcher-smith`](launcher-smith.md) | Maintains `scripts/ollamaclaw`, `scripts/launch-qwen-cloud.sh`, launcher documentation | Launcher help text needs updating, cloud command changes, fallback strategy changes |
| [`settings-warden`](settings-warden.md) | Reviews `.claude/settings.json` for permissions, env safety, dangerous auto-allow rules | Changing Claude Code permissions, adding commands to allow/deny, investigating edit/commit/push permissions |
| [`git-guardian`](git-guardian.md) | Reviews git status, branch state, diffs, staging risk, ignored files, untracked files, commit safety | Before commits, before zips, after Claude edits, deciding what to stage |
| [`commit-captain`](commit-captain.md) | Creates clean commit plans and commit messages after validation | Changes ready, user asks for commit message, multiple slices need separate commits |
| [`agent-template-smith`](agent-template-smith.md) | Creates consistent subagent Markdown definitions using Ollamaclaw approved style | Adding new subagent, converting idea into `.claude/agents/*.md`, normalizing frontmatter |
| [`agent-lint-reviewer`](agent-lint-reviewer.md) | Checks agents for overlap, vague scope, unsupported frontmatter, missing boundaries, unsafe tool permissions | After adding agents, before committing `.claude/agents/`, when agents seem redundant |
| [`zip-auditor`](zip-auditor.md) | Audits source and patch ZIPs for expected files, secrets, junk, and package safety | Before uploading source zips, applying manual patches, or trusting a shared archive |

---

## Cross-Repo Audit Agents

Agents for auditing external repos like VetCan.

| Agent | Purpose | When to Invoke |
|-------|---------|----------------|
| [`repo-scout`](repo-scout.md) | Maps structure, dependencies, entry points, API/UI surfaces, risk coupling | First step for any unknown repo or before major changes |
| [`studio-drift-auditor`](studio-drift-auditor.md) | Checks Studio wording against A21/A22 canonical truth | Before Studio UI changes, launch copy edits, onboarding updates |
| [`voice-safety-auditor`](voice-safety-auditor.md) | Audits voice/call features against preview-only posture | Before voice, ElevenLabs, audio, or call-related changes |
| [`payment-safe-reviewer`](payment-safe-reviewer.md) | Reviews payment/billing/PCI claims | Before payment copy, checkout, billing, or invoice changes |
| [`medical-boundary-reviewer`](medical-boundary-reviewer.md) | Detects medical/vet/PHI boundary drift | Before medical, vet, intake, or eligibility-related changes |
| [`test-commander`](test-commander.md) | Runs minimal relevant test group | After code changes, before commits |
| [`release-scribe`](release-scribe.md) | Generates commit notes, rollback notes, client-safe summaries | Before commits and releases |

---

## Suggested Agent Chains

### Harness Work (Ollamaclaw Maintenance)

```
scope-lock → task-router → (specialist agent) → git-guardian → commit-captain
```

### Broken Setup Diagnosis

```
scope-lock → env-sentinel → wsl-mechanic → ollama-route-verifier
```

### Model Quota or Routing Confusion

```
ollama-route-verifier → model-route-advisor
```

### Adding a New Subagent

```
scope-lock → agent-template-smith → agent-lint-reviewer → git-guardian → commit-captain
```

### Pre-Commit Review

```
git-guardian → commit-captain
```

### Zip/Source Package Audit Preparation

```
scope-lock → zip-auditor → git-guardian → (auditor agents as needed)
```

---

## Cross-Repo Orchestration Order

1. **Repo Scout** — understand the target
2. **Relevant Domain Auditor** — studio, voice, payment, or medical
3. **Test Commander** — validate changes
4. **Release Scribe** — document for commit

## Missing Truth Protocol

If canonical truth docs (A21/A22, voice scope, payment scope, medical boundaries) are **missing from the target repo**, domain auditors will report **BLOCKER** instead of guessing. This is intentional — do not widen capability claims without explicit truth.
