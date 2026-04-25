#!/bin/bash
set -euo pipefail

# Ollamaclaw Session Log
# Appends timestamped session notes to .ollamaclaw/sessions/YYYY-MM-DD.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SESSIONS_DIR="$PROJECT_ROOT/.ollamaclaw/sessions"
TODAY="$(date +%Y-%m-%d)"
TIMESTAMP="$(date +%Y-%m-%d\ %H:%M:%S)"
LOG_FILE="$SESSIONS_DIR/$TODAY.md"

# Usage check
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <log message>"
    echo ""
    echo "Example:"
    echo "  $0 \"Added provider routing docs\""
    echo ""
    echo "Appends a timestamped entry to .ollamaclaw/sessions/YYYY-MM-DD.md"
    exit 1
fi

# Create sessions directory if missing
mkdir -p "$SESSIONS_DIR"

# Get current git branch (if available)
BRANCH=""
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
    BRANCH="$(git branch --show-current 2>/dev/null || echo "")"
fi

# Get current working directory (relative to project root)
CWD="$(pwd)"
CWD_RELATIVE="${CWD#$PROJECT_ROOT/}"
if [[ "$CWD_RELATIVE" == "$CWD" ]]; then
    CWD_RELATIVE="."
fi

# Build the log entry
MESSAGE="$*"

# Create entry in Markdown format
cat >> "$LOG_FILE" <<EOF

## $TIMESTAMP

**Branch:** ${BRANCH:-"(not a git repo)"}
**Directory:** $CWD_RELATIVE

$MESSAGE

---
EOF

echo "Logged to: $LOG_FILE"
