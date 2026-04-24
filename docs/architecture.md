# Ollamaclaw Architecture

## Overview

Ollamaclaw routes Claude Code through Ollama Cloud, enabling cloud model access while using the Claude Code CLI interface.

## Request Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  VS Code    │────▶│  Ollama CLI  │────▶│  Ollama Cloud   │────▶│  Anthropic   │
│  (terminal) │     │  (local)     │     │  (model router) │     │  API         │
└─────────────┘     └──────────────┘     └─────────────────┘     └──────────────┘
       │                    │                      │                      │
       │                    │                      │                      │
       ▼                    ▼                      ▼                      ▼
  User types           Sets env vars          Auth + routes          Processes
  claude cmd           ANTHROPIC_*            to cloud model         request
```

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
3. Routes to Anthropic API with cloud-managed credentials
4. Returns response through the same chain

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
