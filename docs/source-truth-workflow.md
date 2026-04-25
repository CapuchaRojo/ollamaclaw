# Source Truth Workflow

## Why This Exists

Ollamaclaw is a **Claude Code + Ollama Cloud harness** and **reusable cross-repo audit-agent library**. As the project evolves through doc edits, script additions, and agent updates, **truth drift** can occur:

- Docs contradict each other (e.g., one says "calls Anthropic API directly," another says "does not").
- Docs describe scripts or commands that don't exist.
- Scripts reference agents that were renamed or removed.
- Settings claim safety features that aren't implemented.

This workflow provides **automated and agent-based checks** to catch truth drift before it reaches commits, releases, or ZIP uploads.

---

## What source-truth-check.sh Checks

The `./scripts/source-truth-check.sh` script validates:

| Check | Type | Description |
|-------|------|-------------|
| **A. Route Wording** | FAIL if incorrect | Detects claims like "routes to Anthropic API" or "calls Anthropic API directly" without Ollama Cloud clarification |
| **B. Local Fallback Claims** | WARN if risky | Flags docs that claim local models are "stable fallbacks" (should be "experimental" or "direct-helper-only") |
| **C. Script References** | WARN if missing | Extracts `./scripts/*` references from docs and verifies files exist and are executable |
| **D. Settings Safety** | FAIL if unsafe | Checks for dangerous auto-allow rules (`Bash:git commit`, `Bash:git push`) and Git-tracked local settings |
| **E. Agent Frontmatter** | FAIL if deprecated | Detects `type: subagent` (deprecated) and missing required fields (`name:`, `description:`, `tools:`, `model:`) |

**Exit codes:**
- `0` — All checks passed (warnings allowed)
- `1` — Hard contradictions detected

---

## When to Run

Run `./scripts/source-truth-check.sh` in these situations:

| Situation | Why |
|-----------|-----|
| **After doc edits** | Catch wording drift before it compounds |
| **After script edits** | Verify docs still match implemented commands |
| **Before zip upload** | Ensure package docs are accurate |
| **Before commit** | Catch contradictions in staged changes |
| **Before adding agents** | Confirm agent frontmatter and naming consistency |
| **After agent renames** | Update docs that reference old agent names |

---

## Relationship to Other Agents and Workflows

### source-truth-librarian

**Agent role:** Deep audit of doc-to-doc consistency.

**When to invoke:**
```bash
# Ask Claude Code:
@source-truth-librarian "Check for contradictions between README.md, CLAUDE.md, and docs/*.md"
```

**Difference from script:**
- Script checks automated patterns (wording, script existence, frontmatter fields).
- Agent reads for semantic contradictions ("this paragraph contradicts that one").

### docs-to-code-syncer

**Agent role:** Deep audit of docs-vs-code consistency.

**When to invoke:**
```bash
# Ask Claude Code:
@docs-to-code-syncer "Verify all documented scripts exist and are executable"
```

**Difference from script:**
- Script checks script existence and executability.
- Agent extracts all command examples and validates them against actual implementations.

### ollamaclaw-doctor

**Script role:** Broader harness health check.

**Relationship:**
- Doctor checks project structure, agent integrity, settings safety, tooling, script executability, and docs presence.
- Source truth check focuses on **wording drift** and **docs-to-code sync**.
- Run doctor first, then source truth check if doctor reports doc/script drift.

### git-guardian

**Agent role:** Pre-commit git state review.

**Relationship:**
- Source truth check validates content accuracy.
- Git-guardian validates file state, staging risk, and commit safety.
- Run source truth check, then git-guardian before commit.

### zip-auditor

**Agent role:** Pre-package audit.

**Relationship:**
- Source truth check ensures docs are accurate.
- Zip-auditor ensures ZIP contents are safe and complete.
- Run source truth check before zipping, then zip-auditor on the archive.

---

## Known Rule: Ollama Cloud Routing

**Canonical truth:** Ollamaclaw uses **Ollama Cloud / selected Ollama model routing**, not direct Anthropic API routing.

**Correct wording:**
> "Claude Code speaks to a local Ollama endpoint using Anthropic-compatible routing. Ollama then routes requests through Ollama Cloud to the selected Ollama model, usually `qwen3.5:397b-cloud`."

**Incorrect wording (BLOCKER):**
> "Routes to Anthropic API with cloud-managed credentials."

**Why:** The distinction matters because:
1. Ollamaclaw does not manage Anthropic API credentials directly.
2. Ollama Cloud is the routing layer that handles Anthropic authentication.
3. Future provider changes happen at the Ollama Cloud layer, not in Ollamaclaw code.

---

## Example Output

```
=== A. Route Wording ===
[PASS] No incorrect 'direct Anthropic API' claims detected
[PASS] provider-routing.md correctly states 'does not call Anthropic API directly'

=== B. Local Fallback Claims ===
[PASS] No dangerous 'stable fallback' claims detected
[PASS] Docs correctly characterize local models as limited/experimental

=== C. Script References ===
[PASS] Referenced script exists and is executable: ./scripts/model-smoke-test.sh
[PASS] Referenced script exists and is executable: ./scripts/session-log.sh
[WARN] Referenced script does not exist: ./scripts/removed-script.sh

=== D. Settings Safety ===
[PASS] settings.json does not auto-allow 'Bash:git commit'
[PASS] settings.json does not auto-allow 'Bash:git push'
[PASS] .claude/settings.local.json is not tracked by Git

=== E. Agent Frontmatter ===
[PASS] All agent files have required frontmatter fields

============================================
SOURCE TRUTH CHECK SUMMARY
============================================
  PASS: 12
  WARN: 1
  FAIL: 0

RESULT: Warnings detected but no hard contradictions. Safe to proceed with caution.
```

---

## Recommended Workflow

```
1. Edit docs/scripts/agents
2. Run ./scripts/source-truth-check.sh
3. Fix any FAIL items
4. Review WARN items
5. Invoke source-truth-librarian or docs-to-code-syncer for deep audit (optional)
6. Run ./scripts/ollamaclaw-doctor.sh for broader health check
7. Invoke git-guardian before commit
```

---

## Related Docs

- [Doctor Workflow](./doctor-workflow.md) — Broader harness health check
- [Package Audit Checklist](./package-audit-checklist.md) — Pre-zip/release checks
- [Agent Team Playbook](./agent-team-playbook.md) — Agent orchestration patterns
