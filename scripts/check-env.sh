#!/usr/bin/env bash
set -euo pipefail

echo "---- location ----"
pwd

echo "---- git ----"
git status --short --branch || true

echo "---- ollama ----"
command -v ollama || true
ollama --version || true

echo "---- claude ----"
command -v claude || true
claude --version || true

echo "---- snap ollama check ----"
snap list ollama 2>/dev/null || echo "Snap Ollama is not installed."

echo "---- project files ----"
ls -la
