#!/bin/bash
set -euo pipefail

# Ollamaclaw Session Summary
# Prints recent session logs (default: today)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SESSIONS_DIR="$PROJECT_ROOT/.ollamaclaw/sessions"

# Default to today's date
DATE="${1:-$(date +%Y-%m-%d)}"
LOG_FILE="$SESSIONS_DIR/$DATE.md"

# Check if log exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "No session log found for $DATE"
    echo ""
    echo "Logs are stored in: $SESSIONS_DIR"
    echo "Use '$0 YYYY-MM-DD' to view a specific date."
    echo ""
    echo "To create a log entry, use:"
    echo "  ./scripts/session-log.sh \"Your message here\""
    exit 0
fi

# Print the log
echo "=== Session Log: $DATE ==="
echo ""
cat "$LOG_FILE"
