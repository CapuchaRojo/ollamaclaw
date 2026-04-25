# Provider Routing

## Overview

Ollamaclaw uses a **cloud-first** model routing strategy through Ollama Cloud, with local models reserved for direct coding help only.

## Current Routing Architecture

### Primary Path: Cloud Mode

```
VS Code Terminal → Ollama CLI → Ollama Cloud → Ollama Model
```

**Important:** Claude Code speaks to a local Ollama endpoint using Anthropic-compatible routing. Ollama then routes requests through Ollama Cloud to the selected Ollama model, usually `qwen3.5:397b-cloud`. Ollamaclaw does not call Anthropic API directly.

**Environment configuration:**

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_AUTH_TOKEN` | `ollama` | Signals Ollama routing mode |
| `ANTHROPIC_API_KEY` | (empty) | Bypasses direct API key auth |
| `ANTHROPIC_BASE_URL` | `http://127.0.0.1:11434` | Points to local Ollama endpoint |

**Recommended model:** `qwen3.5:397b-cloud`

**Launch command:**
```bash
ollama launch claude --model qwen3.5:397b-cloud
```

### Fallback Paths

| Fallback | Command | Use Case |
|----------|---------|----------|
| Script launcher | `./scripts/launch-qwen-cloud.sh` | Manual env setup if `ollama launch` fails |
| Wrapper script | `./scripts/ollamaclaw [--model MODEL]` | Model selection helper |

### Local Model Behavior

Local models are **not** stable Claude Code fallbacks:

| Model | Status | Recommendation |
|-------|--------|----------------|
| `qwen2.5-coder:14b` | Direct helper only | Use via `ollama run` for coding questions, not Claude Code workflows |
| `qwen3-coder:30b` | Heavy reserve | Requires ~16GB WSL + 16GB swap; too slow for practical agent work |
| `qwen2.5-coder:7b` | Not recommended | Leaked raw tool-call JSON in testing |

## Comparison: Claw Code Multi-Provider Sniffing

The Claw Code reference implements a **multi-provider abstraction layer** that:

- Auto-routes by model-name prefix (`claude*`, `grok*`, `qwen*`, `openai/`)
- Sniffs credentials from multiple env vars (`ANTHROPIC_API_KEY`, `XAI_API_KEY`, `OPENAI_API_KEY`)
- Supports HTTP proxy configuration
- Implements OAuth flow with PKCE + local token persistence

**Ollamaclaw does not replicate this complexity.** Instead:

1. Ollama Cloud acts as a **single routing layer** that manages provider auth
2. No credential sniffing — Ollama handles Anthropic authentication
3. No multi-provider fallback — cloud routing is the single source of truth
4. Simpler mental model: one launcher, one model, one backend

## Future Roadmap

### Potential Enhancements (Not Yet Implemented)

| Feature | Status | Notes |
|---------|--------|-------|
| Multi-provider sniffing | Not planned | Ollama Cloud abstraction removes the need |
| OAuth PKCE flow | Not planned | Handled by Ollama Cloud |
| HTTP proxy config | Not implemented | Could add via Ollama env vars if needed |
| Model prefix routing | Not implemented | Current approach: explicit `--model` flag |

### Decision Rationale

Ollamaclaw prioritizes **simplicity over flexibility**:

- One cloud provider (Ollama) manages upstream complexity
- Local models are helpers, not fallbacks
- Explicit model selection prevents accidental routing errors
- Fewer moving parts = easier debugging and maintenance

## Validation Commands

```bash
# Check current model route
ollama ps

# Verify environment
./scripts/check-env.sh

# Test cloud connectivity
ollama launch claude --model qwen3.5:397b-cloud --help
```

## Related Docs

- [Launcher Patterns](./launcher-patterns.md) — Launch commands and validation
- [Tool Abstraction](./tool-abstraction.md) — Why cloud models are trusted for tool calls
- [Architecture](./architecture.md) — Full request flow diagram
