# Launcher Patterns

## Overview

Ollamaclaw provides multiple launch paths for Claude Code through Ollama. This document explains each launcher, when to use it, and how to validate correct operation.

## Launch Commands

### Primary: ollama launch claude

**Command:**
```bash
ollama launch claude --model qwen3.5:397b-cloud
```

**What it does:**
1. Sets up environment variables for Ollama routing
2. Launches Claude Code CLI with the specified cloud model
3. Handles authentication through Ollama Cloud

**When to use:**
- Default choice for all Claude Code work
- Cloud mode is available and quota is not exhausted
- You want the simplest, most reliable path

**Validation:**
```bash
ollama launch claude --model qwen3.5:397b-cloud --help
```

---

### Fallback: launch-qwen-cloud.sh

**Command:**
```bash
./scripts/launch-qwen-cloud.sh
```

**What it does:**
1. Manually sets environment variables:
   - `ANTHROPIC_AUTH_TOKEN=ollama`
   - `ANTHROPIC_API_KEY=` (empty)
   - `ANTHROPIC_BASE_URL=http://127.0.0.1:11434`
2. Invokes `claude` command with env configured

**When to use:**
- `ollama launch claude` fails or behaves unexpectedly
- You need to debug environment setup
- You want to see exactly which env vars are set

**Contents:**
```bash
#!/bin/bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://127.0.0.1:11434
exec claude "$@"
```

---

### Wrapper: ollamaclaw

**Command:**
```bash
./scripts/ollamaclaw [--model MODEL] [args...]
```

**What it does:**
1. Parses `--model` flag (defaults to `qwen3.5:397b-cloud`)
2. Sets up environment for Ollama routing
3. Provides `--help` output
4. Invokes Claude Code with passed arguments

**When to use:**
- You want model selection in one command
- You prefer a project-specific launcher name
- Building automation that needs model flexibility

**Example:**
```bash
./scripts/ollamaclaw --model qwen3.5:397b-cloud "Review the changes in git diff"
```

---

### Existing Shortcut: ollamaclaw-claude

**Command:**
```bash
ollamaclaw-claude
```

**What it is:**
- System-wide symlink or alias (if installed by user)
- Points to one of the above launchers

**When to use:**
- You've previously set up this shortcut
- You want muscle-memory launcher

**Note:** Not installed by default — user must create it.

---

## Local Launchers (Experimental)

### Direct Model Run

**Command:**
```bash
ollama run qwen2.5-coder:14b
```

**What it does:**
- Starts an interactive chat with the local model
- No Claude Code CLI involvement
- Direct model interaction only

**When to use:**
- Direct coding questions
- Code explanation
- Not for Claude Code agent workflows

**Warning:** Local models leak raw tool-call JSON in Claude Code workflows. Use only for direct chat.

---

### Memory-Heavy Local Model

**Command:**
```bash
ollama run qwen3-coder:30b
```

**Requirements:**
- ~16GB WSL memory
- ~16GB swap configured
- Slow inference time

**When to use:**
- Cloud is unavailable
- You need local fallback for experimentation
- Not for practical Claude Code workflows (too slow)

---

## Why Local Launchers Are Experimental

### The JSON Leakage Problem

Local models tested so far exhibit this behavior in Claude Code:

```
Model output: {"name": "ReadFile", "arguments": {"path": "README.md"}}
Expected: [TOOL EXECUTION: ReadFile README.md]
```

**Consequence:** Tool calls are printed as text instead of executed.

### Tested Models

| Model | JSON Leakage? | Claude Code Safe? |
|-------|---------------|-------------------|
| `qwen3.5:397b-cloud` | No | Yes — trusted |
| `qwen2.5-coder:14b` | Yes | No |
| `qwen2.5-coder:7b` | Yes | No |
| `qwen3-coder:30b` | Unknown | Too slow to evaluate |

See [Tool Abstraction](./tool-abstraction.md) for smoke-test requirements.

---

## Safe Launcher Validation Commands

### Before Launch

```bash
# Check Ollama is running
ollama ps

# Check Claude Code is installed
claude --version

# Check environment
./scripts/check-env.sh
```

### After Launch

```bash
# Verify model loaded
ollama ps | grep qwen

# Test basic command
claude "What is 2+2?" --output-format json

# Check session is responsive
claude "List files in current directory"
```

### Troubleshooting

```bash
# If ollama launch fails, try manual env
./scripts/launch-qwen-cloud.sh

# If cloud quota exhausted, check status
ollama list

# Reset environment
unset ANTHROPIC_AUTH_TOKEN ANTHROPIC_API_KEY ANTHROPIC_BASE_URL
```

---

## Launcher Decision Tree

```
Need Claude Code?
├─ Yes, cloud available → ollama launch claude --model qwen3.5:397b-cloud
├─ Yes, but ollama launch broken → ./scripts/launch-qwen-cloud.sh
├─ Yes, want custom model → ./scripts/ollamaclaw --model MODEL
└─ No, just coding help → ollama run qwen2.5-coder:14b
```

---

## Related Docs

- [Provider Routing](./provider-routing.md) — Cloud vs local strategy
- [Tool Abstraction](./tool-abstraction.md) — Why cloud models are trusted
- [Setup Notes](./setup-notes.md) — Installation and configuration
