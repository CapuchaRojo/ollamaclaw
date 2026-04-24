#!/usr/bin/env bash
set -euo pipefail

export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://127.0.0.1:11434

exec claude --model qwen3.5:397b-cloud "$@"