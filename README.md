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
