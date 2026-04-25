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
- `./scripts/json-leak-detector.sh <file>` — Scan saved output for leaks

## Reference Roadmap

Strategic docs based on Claw Code reference analysis:

- [C.Src.Code Reference Map](./docs/c-src-reference-map.md) — Python source archive structure
- [Reference Synthesis](./docs/reference-synthesis.md) — Comparison of references vs. Ollamaclaw
- [Next Five Lanes](./docs/next-five-lanes.md) — Strategic build lanes for Ollamaclaw

