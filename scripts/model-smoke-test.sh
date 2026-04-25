#!/bin/bash
set -euo pipefail

# Ollamaclaw Model Smoke Test
# Runs a manual compatibility checklist for a local model with Claude Code.
# Does NOT launch Claude Code automatically — provides prompts for manual testing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Usage check
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <model-name>"
    echo ""
    echo "Example:"
    echo "  $0 qwen2.5-coder:14b"
    echo ""
    echo "Verifies prerequisites and prints smoke-test prompts for manual testing."
    echo "Does NOT launch Claude Code automatically."
    exit 1
fi

MODEL="$1"

# Verify ollama exists
if ! command -v ollama &>/dev/null; then
    echo "ERROR: ollama command not found"
    echo ""
    echo "Install Ollama first:"
    echo "  curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi

# Verify claude exists
if ! command -v claude &>/dev/null; then
    echo "ERROR: claude command not found"
    echo ""
    echo "Install Claude Code first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo "  # Or follow official installation docs"
    exit 1
fi

# Verify model is installed
echo "Checking if model '$MODEL' is installed..."
if ! ollama list 2>/dev/null | grep -q "^$MODEL\s"; then
    # Try with exact match including tags
    if ! ollama list 2>/dev/null | grep -qE "^$MODEL([[:space:]]|$)"; then
        echo ""
        echo "WARNING: Model '$MODEL' not found in installed models."
        echo ""
        echo "Installed models:"
        ollama list
        echo ""
        echo "To install this model (if available):"
        echo "  ollama pull $MODEL"
        echo ""
        echo "Note: This script does NOT auto-pull models."
        exit 1
    fi
fi

echo "✓ ollama: $(command -v ollama)"
echo "✓ claude: $(command -v claude)"
echo "✓ model '$MODEL' is installed"
echo ""
echo "=============================================="
echo "  Model Smoke Test: $MODEL"
echo "=============================================="
echo ""
echo "Launch command:"
echo "  ollama launch claude --model $MODEL"
echo ""
echo "=============================================="
echo "  Smoke Test Prompts (run manually)"
echo "=============================================="
echo ""
echo "Run each prompt below in order. If the model fails any test,"
echo "mark it as FAILED for Claude Code workflows."
echo ""
echo "----------------------------------------------"
echo "A. No-Tool Baseline"
echo "----------------------------------------------"
echo ""
echo "Prompt:"
echo '  Reply with exactly: READY'
echo ""
echo "Expected: Model replies with just "READY""
echo "Fail: Model tries to use tools or adds extra text"
echo ""
echo "----------------------------------------------"
echo "B. Read Tool Test"
echo "----------------------------------------------"
echo ""
echo "Prompt:"
echo '  Read README.md only. Summarize Ollamaclaw in 3 bullets. Do not edit files. Do not run commands.'
echo ""
echo "Expected: File is read, summary uses actual content, no raw JSON"
echo "Fail: Raw JSON like { \"name\": \"Read\", \"arguments\": ... } appears"
echo ""
echo "----------------------------------------------"
echo "C. No-Edit Repo Inspection"
echo "----------------------------------------------"
echo ""
echo "Prompt:"
echo '  Run git status only, then summarize whether the repo is clean. Do not edit files.'
echo ""
echo "Expected: git status runs, summary is accurate, no raw JSON"
echo "Fail: Raw JSON leakage or model refuses to use Bash tool"
echo ""
echo "----------------------------------------------"
echo "D. Agent Awareness"
echo "----------------------------------------------"
echo ""
echo "Prompt:"
echo '  List the project subagent categories from .claude/agents/README.md. Do not edit files.'
echo ""
echo "Expected: Model reads file and lists categories accurately"
echo "Fail: Hallucination or raw JSON leakage"
echo ""
echo "----------------------------------------------"
echo "E. Failure Condition (Critical)"
echo "----------------------------------------------"
echo ""
echo "If the model prints raw JSON like:"
echo '  { "name": "ReadFile", "arguments": { "path": "README.md" } }'
echo ""
echo "Instead of executing the tool and answering naturally,"
echo "mark it as FAILED for Claude Code workflows."
echo ""
echo "=============================================="
echo "  Recording Results"
echo "=============================================="
echo ""
echo "After testing, log the result:"
echo ""
echo "  ./scripts/session-log.sh \"Model smoke test: $MODEL = PASS/FAIL because <reason>\""
echo ""
echo "Example:"
echo '  ./scripts/session-log.sh "Model smoke test: qwen2.5-coder:14b = FAIL because leaked raw tool-call JSON on README read"'
echo ""
echo "=============================================="
