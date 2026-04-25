#!/usr/bin/env bash
#
# Ollamaclaw Doctor - Preflight health check for the Ollamaclaw harness
#
# Run this before cloud work, after applying patches, before commit,
# before uploading a zip, or after changing agents/settings/scripts.
#
# Exit codes:
#   0 - All checks passed (warnings allowed)
#   1 - Hard failure detected
#

set -euo pipefail

# Determine project root from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# Track hard failures
HARD_FAILURE=0

# Helper functions
pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++)) || true
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARN_COUNT++)) || true
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++)) || true
    HARD_FAILURE=1
}

section() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

# ============================================================================
# A. PROJECT STRUCTURE
# ============================================================================
section "A. Project Structure"

if [[ -f "${PROJECT_ROOT}/CLAUDE.md" ]]; then
    pass "CLAUDE.md exists"
else
    fail "CLAUDE.md missing"
fi

if [[ -f "${PROJECT_ROOT}/README.md" ]]; then
    pass "README.md exists"
else
    fail "README.md missing"
fi

if [[ -d "${PROJECT_ROOT}/.claude/agents" ]]; then
    pass ".claude/agents directory exists"
else
    fail ".claude/agents directory missing"
fi

if [[ -d "${PROJECT_ROOT}/.claude/commands" ]]; then
    pass ".claude/commands directory exists"
else
    fail ".claude/commands directory missing"
fi

if [[ -d "${PROJECT_ROOT}/docs" ]]; then
    pass "docs directory exists"
else
    fail "docs directory missing"
fi

if [[ -d "${PROJECT_ROOT}/scripts" ]]; then
    pass "scripts directory exists"
else
    fail "scripts directory missing"
fi

# ============================================================================
# B. AGENT INTEGRITY
# ============================================================================
section "B. Agent Integrity"

# Count actual agent files excluding README.md
AGENT_COUNT=0
INVALID_TYPE=0
MISSING_FIELDS=""

if [[ -d "${PROJECT_ROOT}/.claude/agents" ]]; then
    for agent_file in "${PROJECT_ROOT}"/.claude/agents/*.md; do
        [[ -f "$agent_file" ]] || continue
        filename=$(basename "$agent_file")

        # Skip README.md
        if [[ "$filename" == "README.md" ]]; then
            continue
        fi

        ((AGENT_COUNT++)) || true

        # Check for type: subagent (should not exist)
        if grep -q "^type: subagent" "$agent_file" 2>/dev/null; then
            fail "$filename has 'type: subagent' (deprecated)"
            ((INVALID_TYPE++)) || true
        fi

        # Check required frontmatter fields
        if ! grep -q "^name:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}${filename} missing 'name:'\n"
        fi
        if ! grep -q "^description:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}${filename} missing 'description:'\n"
        fi
        if ! grep -q "^tools:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}${filename} missing 'tools:'\n"
        fi
        if ! grep -q "^model:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}${filename} missing 'model:'\n"
        fi
    done

    if [[ $AGENT_COUNT -gt 0 ]]; then
        pass "Found $AGENT_COUNT agent file(s) (excluding README.md)"
    else
        warn "No agent files found in .claude/agents/"
    fi

    if [[ $INVALID_TYPE -gt 0 ]]; then
        fail "$INVALID_TYPE agent(s) use deprecated 'type: subagent'"
    fi

    if [[ -n "$MISSING_FIELDS" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Agent(s) missing required fields:"
        echo -e "$MISSING_FIELDS"
        ((WARN_COUNT++)) || true
    fi
else
    fail ".claude/agents directory missing - cannot check agent integrity"
fi

# ============================================================================
# C. SETTINGS SAFETY
# ============================================================================
section "C. Settings Safety"

SETTINGS_FILE="${PROJECT_ROOT}/.claude/settings.json"
SETTINGS_LOCAL="${PROJECT_ROOT}/.claude/settings.local.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    # Check for dangerous auto-allow rules
    if grep -q "Bash:git commit" "$SETTINGS_FILE" 2>/dev/null; then
        fail "settings.json auto-allows 'Bash:git commit' (unsafe)"
    else
        pass "settings.json does not auto-allow 'Bash:git commit'"
    fi

    if grep -q "Bash:git push" "$SETTINGS_FILE" 2>/dev/null; then
        fail "settings.json auto-allows 'Bash:git push' (unsafe)"
    else
        pass "settings.json does not auto-allow 'Bash:git push'"
    fi
else
    warn "settings.json not found"
fi

# Check if settings.local.json is tracked by git
if git -C "$PROJECT_ROOT" ls-files --error-unmatch ".claude/settings.local.json" &>/dev/null; then
    fail ".claude/settings.local.json is tracked by Git (should be ignored)"
else
    pass ".claude/settings.local.json is not tracked by Git"
fi

# Check if settings.local.json is in .gitignore
GITIGNORE="${PROJECT_ROOT}/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if grep -q "settings.local.json" "$GITIGNORE" 2>/dev/null; then
        pass ".claude/settings.local.json is ignored by .gitignore"
    else
        warn ".claude/settings.local.json is NOT in .gitignore"
    fi
else
    warn ".gitignore not found"
fi

# ============================================================================
# D. TOOLING
# ============================================================================
section "D. Tooling"

# Check ollama
if command -v ollama &>/dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>&1 || echo "unknown")
    pass "ollama found: $OLLAMA_VERSION"

    echo -e "${BLUE}[INFO]${NC} ollama list:"
    ollama list 2>/dev/null || echo "  (no models pulled)"
    echo ""

    echo -e "${BLUE}[INFO]${NC} ollama ps:"
    ollama ps 2>/dev/null || echo "  (no models running)"
else
    fail "ollama not found in PATH"
fi

# Check claude
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 || echo "unknown")
    pass "claude found: $CLAUDE_VERSION"
else
    warn "claude not found in PATH"
fi

# ============================================================================
# E. SCRIPT EXECUTABILITY
# ============================================================================
section "E. Script Executability"

EXECUTABLE_SCRIPTS=(
    "scripts/check-env.sh"
    "scripts/launch-qwen-cloud.sh"
    "scripts/model-smoke-test.sh"
    "scripts/session-log.sh"
    "scripts/session-summary.sh"
    "scripts/ollamaclaw"
)

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    full_path="${PROJECT_ROOT}/${script}"
    if [[ -x "$full_path" ]]; then
        pass "$script is executable"
    elif [[ -f "$full_path" ]]; then
        fail "$script exists but is NOT executable"
    else
        warn "$script not found"
    fi
done

# ============================================================================
# F. DOCUMENTATION
# ============================================================================
section "F. Documentation"

REQUIRED_DOCS=(
    "docs/provider-routing.md"
    "docs/tool-abstraction.md"
    "docs/agent-protocol.md"
    "docs/session-design.md"
    "docs/launcher-patterns.md"
    "docs/model-smoke-tests.md"
    "docs/session-log-workflow.md"
    "docs/reference-synthesis.md"
    "docs/next-five-lanes.md"
    "docs/c-src-reference-map.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
    full_path="${PROJECT_ROOT}/${doc}"
    if [[ -f "$full_path" ]]; then
        pass "$doc exists"
    else
        warn "$doc not found"
    fi
done

# ============================================================================
# G. SESSION LOGS
# ============================================================================
section "G. Session Logs"

SESSIONS_DIR="${PROJECT_ROOT}/.ollamaclaw/sessions"

if [[ -d "$SESSIONS_DIR" ]]; then
    pass ".ollamaclaw/sessions directory exists"

    # Find latest session log
    LATEST_SESSION=$(find "$SESSIONS_DIR" -name "*.md" -type f 2>/dev/null | sort -r | head -1)

    if [[ -n "$LATEST_SESSION" ]]; then
        echo -e "${BLUE}[INFO]${NC} Latest session log: $(basename "$LATEST_SESSION")"
        # Show first few lines if file is readable
        if [[ -r "$LATEST_SESSION" ]]; then
            head -5 "$LATEST_SESSION" 2>/dev/null | sed 's/^/  /' || true
        fi
    else
        echo -e "${BLUE}[INFO]${NC} No session logs found yet"
    fi
else
    warn ".ollamaclaw/sessions directory not found"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "============================================"
echo -e "${BLUE}DOCTOR SUMMARY${NC}"
echo "============================================"
echo -e "  ${GREEN}PASS:${NC} $PASS_COUNT"
echo -e "  ${YELLOW}WARN:${NC} $WARN_COUNT"
echo -e "  ${RED}FAIL:${NC} $FAIL_COUNT"
echo ""

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}RESULT: Hard failures detected. Review FAIL items before proceeding.${NC}"
    exit 1
elif [[ $WARN_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}RESULT: Warnings detected but no hard failures. Safe to proceed with caution.${NC}"
    exit 0
else
    echo -e "${GREEN}RESULT: All checks passed.${NC}"
    exit 0
fi
