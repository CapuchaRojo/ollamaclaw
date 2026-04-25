# Ollamaclaw

Ollamaclaw is a WSL + VS Code project for running Claude Code through Ollama cloud models.

## Primary Goal

Use Claude Code as the coding harness while routing model calls through Ollama Cloud, especially `qwen3.5:397b-cloud`.

## Launch Options

### Cloud Mode (Recommended)

Preferred official launch path:

```bash
ollama launch claude --model qwen3.5:397b-cloud
```

Fallback launcher:

```bash
./scripts/launch-qwen-cloud.sh
```

Existing local shortcut, if installed:

```bash
ollamaclaw-claude
```

Cloud mode is the recommended full-stack Claude Code path.

### Local Model Reality

Local models can help with direct coding questions, but are not stable Claude Code fallbacks:

- **`qwen2.5-coder:14b`**: May be used with `ollama run qwen2.5-coder:14b` for direct coding help.
- **`qwen3-coder:30b`**: Can run locally with increased WSL memory (~16GB RAM + 16GB swap) but is too slow for practical Claude Code workflows on this machine.
- **`qwen2.5-coder:7b` and `qwen2.5-coder:14b`**: Should not be recommended for Claude Code agent workflows—both leaked raw tool-call JSON during testing.

Do not present local models as stable Claude Code fallbacks unless they pass smoke tests without raw tool-call JSON leakage.

## Stack

- WSL / Ubuntu
- VS Code
- Ollama Cloud
- Claude Code
- GitHub

## Quick Verification

```bash
./scripts/check-env.sh
```

## Doctor / Preflight

Run the Ollamaclaw health check before cloud work, after patches, before commit, or before uploading a zip:

```bash
./scripts/ollamaclaw-doctor.sh
```

See [docs/doctor-workflow.md](./docs/doctor-workflow.md) for details.

## Toolchain / Prerequisites

Check for missing WSL tools and print safe manual install guidance:

```bash
./scripts/toolchain-doctor.sh
```

See [docs/toolchain-bootstrap-workflow.md](./docs/toolchain-bootstrap-workflow.md) for details.

## Source Truth Checks

Verify docs, scripts, and agents are consistent:

```bash
./scripts/source-truth-check.sh
```

See [docs/source-truth-workflow.md](./docs/source-truth-workflow.md) for details.

## Architecture Docs

For deeper understanding of Ollamaclaw's design:

| Doc | Purpose |
|-----|---------|
| [Provider Routing](./docs/provider-routing.md) | Cloud-first model routing strategy |
| [Tool Abstraction](./docs/tool-abstraction.md) | Tool-call behavior and JSON leakage issue |
| [Agent Protocol](./docs/agent-protocol.md) | Subagent orchestration system |
| [Session Design](./docs/session-design.md) | Session logging approach |
| [Launcher Patterns](./docs/launcher-patterns.md) | Launch commands and validation |

See [docs/](./docs/) for additional documentation.

## Session Logs

Track work progress with session logging:

- [Session Log Workflow](./docs/session-log-workflow.md) — How to use `./scripts/session-log.sh` and `./scripts/session-summary.sh`

## Model Smoke Tests

Evaluate local models before using with Claude Code:

- [Model Smoke Tests](./docs/model-smoke-tests.md) — Test procedure and recorded results
- `./scripts/model-smoke-test.sh <model>` — Run smoke-test checklist
- [JSON Leak Detection](./docs/json-leak-detection.md) — Detect raw tool-call JSON leakage
- `./scripts/json-leak-detector.sh <file>` — Scan saved output for raw tool-call JSON (exit 0=PASS, 1=FAIL)

## Agent Governance

Ollamaclaw includes a governance layer to safely scale its subagent library without README drift, playbook drift, or vague agent boundaries.

- [Agent Governance](./docs/agent-governance.md) — Rules, standards, and workflows for agent management
- `./scripts/agent-inventory.sh` — Fast frontmatter validation

**Repo Hygiene Agents:** Ollamaclaw includes Batch 2 repo hygiene agents (`script-hardener`, `dependency-scout`, `security-sweeper`, `license-warden`, `rollback-planner`, `patch-planner`) to keep scripts, docs, dependencies, security, license, rollback, and patch plans aligned.

## Reference Roadmap

Strategic docs based on Claw Code reference analysis:

- [C.Src.Code Reference Map](./docs/c-src-reference-map.md) — Python source archive structure
- [Reference Synthesis](./docs/reference-synthesis.md) — Comparison of references vs. Ollamaclaw
- [Next Five Lanes](./docs/next-five-lanes.md) — Strategic build lanes for Ollamaclaw

## Release Readiness

Before commit, push, zip, or handoff, run the release readiness check:

```bash
./scripts/release-readiness.sh
```

See [docs/release-readiness-workflow.md](./docs/release-readiness-workflow.md) for details.

## Packaging / Upload ZIP

Create safe source packages for upload or sharing:

```bash
# Check artifact hygiene first
./scripts/artifact-hygiene-check.sh

# Create package (output: .ollamaclaw/artifacts/ollamaclaw-YYYYMMDD-HHMMSS.zip)
./scripts/package-ollamaclaw.sh

# Or with custom filename
./scripts/package-ollamaclaw.sh my-package.zip
```

Packages exclude secrets, local settings, git internals, bootstrap junk, and nested archives.

See [docs/artifact-hygiene-workflow.md](./docs/artifact-hygiene-workflow.md) for details.

## Parallel Work

For guidance on using multiple Claude Code terminals safely:

```bash
./scripts/parallel-safety-check.sh
```

See [docs/parallel-slice-workflow.md](./docs/parallel-slice-workflow.md) for the full protocol.

## Worktree Slices

For true parallel implementation with isolated worktrees:

```bash
./scripts/worktree-slice.sh plan <slice-name>
```

See [docs/worktree-slice-workflow.md](./docs/worktree-slice-workflow.md) for the full protocol.

## Slice Queue

Track planned work slices before starting implementation:

```bash
./scripts/slice-queue.sh list
./scripts/slice-queue.sh add <slice-name> "Goal"
```

See [docs/slice-queue-workflow.md](./docs/slice-queue-workflow.md) for details.

## Slice Closeout

Finalize a completed slice after review/commit:

```bash
./scripts/slice-closeout.sh dry-run <slice-name>
./scripts/slice-closeout.sh done <slice-name> "Summary"
```

See [docs/slice-closeout-workflow.md](./docs/slice-closeout-workflow.md) for details.

