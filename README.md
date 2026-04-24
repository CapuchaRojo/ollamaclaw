# Ollamaclaw

Ollamaclaw is a WSL + VS Code project for running Claude Code through Ollama cloud models.

## Primary Goal

Use Claude Code as the coding harness while routing model calls through Ollama Cloud, especially `qwen3.5:397b-cloud`.

## Current Launch Options

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
