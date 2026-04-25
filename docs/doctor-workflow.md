# Ollamaclaw Doctor Workflow

## Purpose

The `ollamaclaw-doctor.sh` script performs a fast, non-destructive health check for the Ollamaclaw harness before significant work begins.

## What the Doctor Checks

### A. Project Structure
- Confirms core files exist: `CLAUDE.md`, `README.md`
- Confirms core directories exist: `.claude/agents`, `.claude/commands`, `docs`, `scripts`

### B. Agent Integrity
- Counts actual agent files (excluding `README.md`)
- Fails if any agent uses deprecated `type: subagent`
- Warns if agents are missing required frontmatter fields: `name:`, `description:`, `tools:`, `model:`

### C. Settings Safety
- Fails if `.claude/settings.json` auto-allows `Bash:git commit`
- Fails if `.claude/settings.json` auto-allows `Bash:git push`
- Warns if `.claude/settings.local.json` is tracked by Git
- Confirms `.claude/settings.local.json` is ignored by `.gitignore`

### D. Tooling
- Confirms `ollama` exists and prints version
- Confirms `claude` exists and prints version
- Prints `ollama list` output
- Prints `ollama ps` output

### E. Script Executability
Confirms these scripts are executable:
- `scripts/check-env.sh`
- `scripts/launch-qwen-cloud.sh`
- `scripts/model-smoke-test.sh`
- `scripts/session-log.sh`
- `scripts/session-summary.sh`
- `scripts/ollamaclaw`

### F. Documentation
Confirms these docs exist:
- `docs/provider-routing.md`
- `docs/tool-abstraction.md`
- `docs/agent-protocol.md`
- `docs/session-design.md`
- `docs/launcher-patterns.md`
- `docs/model-smoke-tests.md`
- `docs/session-log-workflow.md`
- `docs/reference-synthesis.md`
- `docs/next-five-lanes.md`
- `docs/c-src-reference-map.md`

### G. Session Logs
- Confirms `.ollamaclaw/sessions` exists
- Prints the latest session log file if present
- Does NOT modify session logs

### H. JSON Leak Detection (Optional Diagnostic)
The doctor does NOT automatically run JSON leak detection. This is an optional diagnostic for model smoke testing:

```bash
./scripts/json-leak-detector.sh <path-to-output.txt>
```

**When to use:** After running Claude Code with a local model and saving output to a file.

**What it detects:** Raw tool-call JSON patterns like `"name": "Read"`, `"arguments": {` that indicate the model printed tool invocations as text instead of executing them.

**Results:** PASS (exit 0) means no leak patterns detected; FAIL (exit 1) means raw JSON detected.

See [JSON Leak Detection](./json-leak-detection.md) for full details and false positive limitations.

### I. Agent Inventory (Optional)
The doctor does NOT automatically run agent inventory. This is an optional diagnostic you can run manually when adding or auditing agents:

```bash
./scripts/agent-inventory.sh
```

See [Agent Governance](./agent-governance.md) for details on agent standards and workflows.

### J. Release Readiness (Higher-Level Wrapper)

The doctor is one component of the broader release readiness check. For a complete pre-release audit:

```bash
./scripts/release-readiness.sh
```

This wrapper runs:
- Doctor (harness health)
- Source truth check (docs/scripts/agents consistency)
- Agent inventory (frontmatter validation)
- Git state checks
- Package safety (sensitive files, ZIP artifacts)
- Reference-only rule verification
- Release docs confirmation

See [Release Readiness Workflow](./release-readiness-workflow.md) for details.

### K. Slice Queue (Optional Diagnostic)

The slice queue provides project-local planning for upcoming work:

```bash
./scripts/slice-queue.sh list
./scripts/slice-queue.sh add <slice-name> "<goal>"
./scripts/slice-queue.sh next
```

See [Slice Queue Workflow](./slice-queue-workflow.md) for details.

### L. Parallel Safety Check (Optional Diagnostic)

Before using multiple terminals or worktrees, run the parallel safety check:

```bash
./scripts/parallel-safety-check.sh
```

This script verifies git state, file-scope risk, and harness safety, then prints a SAFE / WARN / FAIL recommendation.

For worktree planning and creation:

```bash
./scripts/worktree-slice.sh plan <slice-name>
./scripts/worktree-slice.sh create <slice-name>
```

See [Parallel Slice Workflow](./parallel-slice-workflow.md) and [Worktree Slice Workflow](./worktree-slice-workflow.md) for the full protocol.

---

```bash
./scripts/release-readiness.sh
```

This wrapper runs:
- Doctor (harness health)
- Source truth check (docs/scripts/agents consistency)
- Agent inventory (frontmatter validation)
- Git state checks
- Package safety (sensitive files, ZIP artifacts)
- Reference-only rule verification
- Release docs confirmation

See [Release Readiness Workflow](./release-readiness-workflow.md) for details.

---

## When to Run the Doctor

Run `./scripts/ollamaclaw-doctor.sh` in these situations:

| Situation | Why |
|-----------|-----|
| **Before cloud work** | Confirm Ollama + Claude Code are properly routed |
| **After applying patches** | Verify no structural damage from manual changes |
| **Before commit** | Catch settings leaks, missing docs, agent issues |
| **Before uploading a zip** | Ensure package contains required structure |
| **After changing agents** | Validate frontmatter and integrity |
| **After changing settings** | Confirm no dangerous auto-allow rules |
| **After changing scripts** | Verify executability and structure |
| **Starting a new session** | Quick sanity check before deep work |

---

## Understanding Results

### PASS
The check passed. The harness is healthy for this item.

### WARN
A non-critical issue was detected. Examples:
- A documentation file is missing
- An agent is missing a frontmatter field
- `.gitignore` does not explicitly ignore `settings.local.json`
- `claude` command not found (but `ollama` is)

**Action:** Review warnings. Safe to proceed with caution.

### FAIL
A hard failure was detected. Examples:
- Core files or directories missing
- `settings.json` auto-allows dangerous git commands
- `settings.local.json` is tracked by Git
- An agent uses deprecated `type: subagent`
- Required scripts are not executable

**Action:** Fix failures before proceeding. The script exits with code 1 if any FAIL items exist.

---

## What the Doctor Does NOT Do

The doctor intentionally **does NOT**:
- Launch Claude Code
- Pull or download models
- Delete models
- Commit or push changes
- Call cloud APIs beyond local `ollama` CLI inspection
- Modify any files (read-only audit)
- Run model smoke tests
- Validate model behavior (only checks tooling exists)

---

## Relationship to Other Agents

The doctor complements these Ollamaclaw agents:

| Agent | Relationship |
|-------|--------------|
| [`env-sentinel`](../.claude/agents/env-sentinel.md) | Doctor checks file structure; env-sentinel diagnoses WSL/Ollama/Claude/PATH issues in detail |
| [`settings-warden`](../.claude/agents/settings-warden.md) | Doctor does basic settings safety; settings-warden does deep permission/hook review |
| [`git-guardian`](../.claude/agents/git-guardian.md) | Doctor checks if settings.local.json is tracked; git-guardian reviews full git state before commit |
| [`zip-auditor`](../.claude/agents/zip-auditor.md) | Doctor confirms structure before zipping; zip-auditor inspects ZIP contents without extracting |
| [`model-route-advisor`](../.claude/agents/model-route-advisor.md) | Doctor confirms tooling exists; model-route-advisor recommends cloud vs local strategy |

---

## Recommended Workflow

```
1. Run ./scripts/ollamaclaw-doctor.sh
2. Fix any FAIL items
3. Review WARN items
4. Proceed with specialist agents (env-sentinel, scope-lock, etc.)
5. Run doctor again before commit/zip
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed (warnings allowed) |
| 1 | Hard failure detected |

---

## Example Output

```
=== A. Project Structure ===
[PASS] CLAUDE.md exists
[PASS] README.md exists
[PASS] .claude/agents directory exists
...

=== D. Tooling ===
[PASS] ollama found: Ollama (2.3.0)
[INFO] ollama list:
NAME                    ID              SIZE
qwen3.5:397b-cloud      abc123          45GB
...

=== SUMMARY ===
PASS: 42
WARN: 2
FAIL: 0

RESULT: Warnings detected but no hard failures. Safe to proceed with caution.
```
