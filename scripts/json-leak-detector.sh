#!/bin/bash
set -euo pipefail

# Ollamaclaw JSON Leak Detector
# Scans Claude Code output/transcripts for raw tool-call JSON leakage.
#
# Usage:
#   ./scripts/json-leak-detector.sh path/to/output.txt
#   cat output.txt | ./scripts/json-leak-detector.sh -
#
# Exit codes:
#   0 - No leak patterns detected (PASS)
#   1 - Likely raw tool-call JSON detected (FAIL)
#
# Note: This is a heuristic detector. False positives may occur.

# Determine input source
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <file>"
    echo "  or: cat <file> | $0 -"
    echo ""
    echo "Scans Claude Code output for raw tool-call JSON leakage."
    exit 1
fi

INPUT="$1"

# Read input into variable
if [[ "$INPUT" == "-" ]]; then
    CONTENT="$(cat)"
else
    if [[ ! -f "$INPUT" ]]; then
        echo "ERROR: File not found: $INPUT"
        exit 1
    fi
    CONTENT="$(cat "$INPUT")"
fi

# Check for empty input
if [[ -z "$CONTENT" ]]; then
    echo "[WARN] Empty input"
    exit 0
fi

# Detection patterns for raw tool-call JSON
# These patterns indicate the model output tool calls as text instead of structured invocations
LEAK_PATTERNS=(
    '"name":\s*"Read"'
    '"name":\s*"Bash"'
    '"name":\s*"Write"'
    '"name":\s*"Edit"'
    '"name":\s*"ReadFile"'
    '"name":\s*"WriteFile"'
    '"name":\s*"EditFile"'
    '"name":\s*"Glob"'
    '"name":\s*"Grep"'
    '"arguments":\s*\{'
)

# Count matches
LEAK_COUNT=0
MATCHED_PATTERNS=""

for pattern in "${LEAK_PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qE "$pattern"; then
        ((LEAK_COUNT++)) || true
        MATCHED_PATTERNS="${MATCHED_PATTERNS}  - Pattern: $pattern\n"
    fi
done

# Additional check: raw JSON object that looks like a tool call
# Pattern: {"name": "...", "arguments": {...}}
if echo "$CONTENT" | grep -qE '\{\s*"name"\s*:\s*"[^"]+"\s*,\s*"arguments"\s*:'; then
    ((LEAK_COUNT++)) || true
    MATCHED_PATTERNS="${MATCHED_PATTERNS}  - Raw JSON tool-call object detected\n"
fi

# Output results
echo "=============================================="
echo "  JSON Leak Detection Report"
echo "=============================================="
echo ""
echo "Input: ${INPUT:-stdin}"
echo "Patterns checked: ${#LEAK_PATTERNS[@]} + raw JSON structure"
echo ""

if [[ $LEAK_COUNT -gt 0 ]]; then
    echo -e "\033[0;31m[FAIL]\033[0m Likely raw tool-call JSON detected"
    echo ""
    echo "Matched patterns:"
    echo -e "$MATCHED_PATTERNS"
    echo ""
    echo "This output contains patterns consistent with raw tool-call JSON"
    echo "leakage, where the model printed tool invocations as text instead"
    echo "of executing them through Claude Code."
    echo ""
    echo "Recommendation: This model is NOT safe for Claude Code workflows."
    exit 1
else
    echo -e "\033[0;32m[PASS]\033[0m No leak patterns detected"
    echo ""
    echo "No suspicious tool-call JSON patterns found in this output."
    echo ""
    echo "Note: This is a heuristic check. Manual review is still recommended."
    exit 0
fi
