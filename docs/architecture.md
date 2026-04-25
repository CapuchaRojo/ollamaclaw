# Ollamaclaw Architecture

## Overview

Ollamaclaw routes Claude Code through Ollama Cloud, enabling cloud model access while using the Claude Code CLI interface.

## Model Strategy

### Cloud Routing (Primary)

- **`qwen3.5:397b-cloud`**: Full-stack Claude Code workflows. This is the recommended path.

### Local Direct Helper

- **`ollama run qwen2.5-coder:14b`**: Use for direct coding questions and experimentation.
- Not intended for Claude Code agent tool workflows.

### Heavy Local Reserve

- **`qwen3-coder:30b`**: Can run locally with ~16GB WSL memory + 16GB swap.
- Too slow for practical Claude Code workflows on this machine.
- Reserved for local experimentation when cloud is unavailable.

### Usage-Limit Behavior

When cloud quota is exhausted:
1. Pause cloud agent work, OR
2. Use local models only for direct helper tasks (`ollama run ...`), not Claude Code agent workflows.

## Ollama Model Commands

- **`ollama list`**: Shows installed models on disk.
- **`ollama ps`**: Shows models currently loaded in memory.

## Request Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  VS Code    │────▶│  Ollama CLI  │────▶│  Ollama Cloud   │────▶│  Ollama      │
│  (terminal) │     │  (local)     │     │  (model router) │     │  Model       │
└─────────────┘     └──────────────┘     └─────────────────┘     └──────────────┘
       │                    │                      │                      │
       │                    │                      │                      │
       ▼                    ▼                      ▼                      ▼
  User types           Sets env vars          Auth + routes          Processes
  claude cmd           ANTHROPIC_*            to cloud model         request
```

**Note:** The request flows through Ollama Cloud to an Ollama model (e.g., `qwen3.5:397b-cloud`), not directly to Anthropic API. Ollamaclaw does not manage Anthropic credentials.

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_AUTH_TOKEN` | `ollama` | Signals Ollama routing mode |
| `ANTHROPIC_API_KEY` | (empty) | Bypasses direct API key auth |
| `ANTHROPIC_BASE_URL` | `http://127.0.0.1:11434` | Points to local Ollama endpoint |

## Launch Paths

### Primary (Official)
```bash
ollama launch claude --model qwen3.5:397b-cloud
```

### Fallback (Manual Env)
```bash
./scripts/launch-qwen-cloud.sh
```

### Wrapper Script
```bash
./scripts/ollamaclaw [--model MODEL] [args...]
```

## Model Routing

Ollama Cloud acts as a proxy:
1. Receives Claude Code requests at `localhost:11434`
2. Authenticates with Ollama Cloud using `ANTHROPIC_AUTH_TOKEN=ollama`
3. Routes through Ollama Cloud to the selected Ollama model (usually `qwen3.5:397b-cloud`)
4. Returns response through the same chain

**Important:** Claude Code speaks to a local Ollama endpoint using Anthropic-compatible routing. Ollama then routes requests through Ollama Cloud to the selected Ollama model. Ollamaclaw does not call Anthropic API directly.

## Benefits

- **No direct API key needed** — Ollama manages Anthropic auth
- **Cloud model access** — Use latest Claude variants via Ollama
- **Local CLI ergonomics** — Same `claude` command, different backend

## Files

| Path | Purpose |
|------|---------|
| `scripts/ollamaclaw` | Wrapper launcher with `--help` and model selection |
| `scripts/launch-qwen-cloud.sh` | Minimal fallback launcher |
| `scripts/check-env.sh` | Environment verification |
| `.claude/settings.json` | Project-local Claude Code config |
