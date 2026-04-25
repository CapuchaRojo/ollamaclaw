#!/bin/bash
set -euo pipefail

# Parallel Safety Check
# Fast non-destructive check before using multiple terminals or worktrees
# Exit codes: 0 = SAFE, 1 = HARD BLOCKERS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Track results
declare -a PASS_ITEMS=()
declare -a WARN_ITEMS=()
declare -a FAIL_ITEMS=()

# High-conflict files that require extra caution
HIGH_CONFLICT_FILES=(
    "README.md"
    "CLAUDE.md"
    ".claude/settings.json"
    ".claude/agents/README.md"
    "docs/agent-team-playbook.md"
    "docs/next-five-lanes.md"
    "scripts/ollamaclaw"
)

print_section() {
    echo ""
    echo -e "\033[0;34m=== $1 ===\033[0m"
}

print_pass() {
    echo -e "\033[0;32m[PASS]\033[0m $1"
    PASS_ITEMS+=("$1")
}

print_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
    WARN_ITEMS+=("$1")
}

print_fail() {
    echo -e "\033[0;31m[FAIL]\033[0m $1"
    FAIL_ITEMS+=("$1")
}

# A. Git State
print_section "A. Git State"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "UNKNOWN")
echo "Current branch: $CURRENT_BRANCH"

UPSTREAM=$(git rev-parse --abbrev-ref "@{u}" 2>/dev/null || echo "none")
echo "Upstream: $UPSTREAM"

UNCOMMITTED=$(git status --porcelain 2>/dev/null | grep -v "^??" || true)
if [[ -n "$UNCOMMITTED" ]]; then
    print_warn "Uncommitted changes in working tree"
    echo ""
    echo "Changed files:"
    git status --porcelain 2>/dev/null | sed 's/^/  /'
else
    print_pass "Working tree clean (no uncommitted changes)"
fi

WORKTREES=$(git worktree list 2>/dev/null || echo "No worktrees")
echo ""
echo "Worktrees:"
echo "$WORKTREES" | sed 's/^/  /'

# B. File-Scope Risk
print_section "B. File-Scope Risk"

if [[ -n "$UNCOMMITTED" ]]; then
    CHANGED_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}' || true)
    HIGH_RISK_FOUND=()

    for hf in "${HIGH_CONFLICT_FILES[@]}"; do
        if echo "$CHANGED_FILES" | grep -q "^${hf}$"; then
            HIGH_RISK_FOUND+=("$hf")
        fi
    done

    if [[ ${#HIGH_RISK_FOUND[@]} -gt 0 ]]; then
        print_warn "High-conflict files have uncommitted changes:"
        for hf in "${HIGH_RISK_FOUND[@]}"; do
            echo "  - $hf"
        done
        echo "  These files risk conflict in parallel sessions."
    else
        print_pass "No high-conflict files have uncommitted changes"
    fi
else
    print_pass "No uncommitted changes to check for file-scope risk"
fi

# C. Harness Safety
print_section "C. Harness Safety"

# Check doctor script
if [[ -x "$SCRIPT_DIR/ollamaclaw-doctor.sh" ]]; then
    print_pass "ollamaclaw-doctor.sh exists and is executable"
else
    print_warn "ollamaclaw-doctor.sh missing or not executable"
fi

# Check source-truth script
if [[ -x "$SCRIPT_DIR/source-truth-check.sh" ]]; then
    print_pass "source-truth-check.sh exists and is executable"
else
    print_warn "source-truth-check.sh missing or not executable"
fi

# Check agent-inventory script
if [[ -x "$SCRIPT_DIR/agent-inventory.sh" ]]; then
    print_pass "agent-inventory.sh exists and is executable"
else
    print_warn "agent-inventory.sh missing or not executable"
fi

# D. Recommendation
print_section "D. Recommendation"

# Determine recommendation
RECOMMENDATION=""

if [[ ${#FAIL_ITEMS[@]} -gt 0 ]]; then
    RECOMMENDATION="STOP: FIX HARD BLOCKERS"
elif [[ -n "$UNCOMMITTED" ]]; then
    # Check if high-conflict files are changed
    CHANGED_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}' || true)
    HIGH_RISK_COUNT=0
    for hf in "${HIGH_CONFLICT_FILES[@]}"; do
        if echo "$CHANGED_FILES" | grep -q "^${hf}$"; then
            HIGH_RISK_COUNT=$((HIGH_RISK_COUNT + 1))
        fi
    done

    if [[ $HIGH_RISK_COUNT -gt 0 ]]; then
        RECOMMENDATION="USE SEPARATE WORKTREE BEFORE PARALLEL EDITS"
    else
        RECOMMENDATION="SAFE FOR READ-ONLY PARALLEL AUDIT"
    fi
else
    RECOMMENDATION="SAFE FOR SINGLE WRITER"
fi

# Print recommendation with appropriate color
case "$RECOMMENDATION" in
    "STOP: FIX HARD BLOCKERS")
        echo -e "\033[0;31m$RECOMMENDATION\033[0m"
        ;;
    "USE SEPARATE WORKTREE BEFORE PARALLEL EDITS")
        echo -e "\033[1;33m$RECOMMENDATION\033[0m"
        ;;
    *)
        echo -e "\033[0;32m$RECOMMENDATION\033[0m"
        ;;
esac

# Summary
print_section "SUMMARY"
echo "  PASS: ${#PASS_ITEMS[@]}"
echo "  WARN: ${#WARN_ITEMS[@]}"
echo "  FAIL: ${#FAIL_ITEMS[@]}"
echo ""

# Exit with appropriate code
if [[ ${#FAIL_ITEMS[@]} -gt 0 ]]; then
    echo -e "\033[0;31mRESULT: Hard blockers detected. Fix before parallel work.\033[0m"
    exit 1
else
    echo -e "\033[0;32mRESULT: Safe to proceed. Follow the recommendation above.\033[0m"
    exit 0
fi
