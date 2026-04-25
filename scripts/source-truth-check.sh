#!/bin/bash
set -euo pipefail

# Ollamaclaw Source Truth Check
# Fast non-destructive consistency check for common truth drift.
#
# Exit codes:
#   0 - All checks passed (warnings allowed)
#   1 - Hard contradictions detected

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
HARD_FAILURE=0

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
# A. ROUTE WORDING
# ============================================================================
section "A. Route Wording"

PROVIDER_ROUTING="${PROJECT_ROOT}/docs/provider-routing.md"
ARCHITECTURE="${PROJECT_ROOT}/docs/architecture.md"

# Check for incorrect "direct Anthropic API" claims
if grep -q "calls Anthropic API directly" "$PROVIDER_ROUTING" 2>/dev/null; then
    fail "provider-routing.md claims Ollamaclaw 'calls Anthropic API directly'"
elif grep -q "routes to Anthropic API" "$ARCHITECTURE" 2>/dev/null && ! grep -q "Ollama Cloud" "$ARCHITECTURE" 2>/dev/null; then
    fail "architecture.md claims 'routes to Anthropic API' without Ollama Cloud clarification"
else
    pass "No incorrect 'direct Anthropic API' claims detected"
fi

# Check for correct "does not call Anthropic API directly" statement
if grep -q "does not call Anthropic API directly" "$PROVIDER_ROUTING" 2>/dev/null; then
    pass "provider-routing.md correctly states 'does not call Anthropic API directly'"
else
    warn "provider-routing.md missing explicit 'does not call Anthropic API directly' statement"
fi

# ============================================================================
# B. LOCAL FALLBACK CLAIMS
# ============================================================================
section "B. Local Fallback Claims"

# Check for dangerous "stable fallback" claims
if grep -qE "stable.*fallback|fallback.*stable" "$PROJECT_ROOT"/docs/*.md 2>/dev/null; then
    warn "Docs may claim local models are 'stable fallbacks' — should be 'experimental' or 'direct-helper-only'"
else
    pass "No dangerous 'stable fallback' claims detected"
fi

# Check for correct "experimental" or "direct-helper-only" language
if grep -qE "experimental|direct-helper-only|direct helper only|not.*stable.*Claude Code" "$PROJECT_ROOT"/docs/*.md 2>/dev/null; then
    pass "Docs correctly characterize local models as limited/experimental"
else
    warn "Docs may be missing 'experimental' or 'direct-helper-only' characterization for local models"
fi

# ============================================================================
# C. SCRIPT REFERENCES
# ============================================================================
section "C. Script References"

# Extract script references from README and docs
SCRIPT_REFS=$(grep -rhoE '\./scripts/[a-zA-Z0-9_.-]+' "$PROJECT_ROOT"/README.md "$PROJECT_ROOT"/docs/ 2>/dev/null | sort -u || true)

for ref in $SCRIPT_REFS; do
    script_name="${ref#./scripts/}"
    full_path="${PROJECT_ROOT}/scripts/${script_name}"

    if [[ -f "$full_path" ]]; then
        if [[ -x "$full_path" ]]; then
            pass "Referenced script exists and is executable: $ref"
        else
            warn "Referenced script exists but is NOT executable: $ref"
        fi
    else
        warn "Referenced script does not exist: $ref"
    fi
done

# Check for ollamaclaw wrapper script
if [[ -f "${PROJECT_ROOT}/scripts/ollamaclaw" ]]; then
    if [[ -x "${PROJECT_ROOT}/scripts/ollamaclaw" ]]; then
        pass "scripts/ollamaclaw exists and is executable"
    else
        warn "scripts/ollamaclaw exists but is NOT executable"
    fi
else
    warn "scripts/ollamaclaw wrapper script not found"
fi

# ============================================================================
# D. SETTINGS SAFETY
# ============================================================================
section "D. Settings Safety"

SETTINGS_FILE="${PROJECT_ROOT}/.claude/settings.json"
SETTINGS_LOCAL="${PROJECT_ROOT}/.claude/settings.local.json"

if [[ -f "$SETTINGS_FILE" ]]; then
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

# ============================================================================
# E. AGENT FRONTMATTER
# ============================================================================
section "E. Agent Frontmatter"

AGENTS_DIR="${PROJECT_ROOT}/.claude/agents"

if [[ -d "$AGENTS_DIR" ]]; then
    # Check for deprecated type: subagent
    for agent_file in "${AGENTS_DIR}"/*.md; do
        [[ -f "$agent_file" ]] || continue
        filename=$(basename "$agent_file")

        # Skip README.md
        if [[ "$filename" == "README.md" ]]; then
            continue
        fi

        if grep -q "^type: subagent" "$agent_file" 2>/dev/null; then
            fail "$filename uses deprecated 'type: subagent'"
        fi
    done

    # Check for required fields in agent files
    MISSING_FIELDS=""
    for agent_file in "${AGENTS_DIR}"/*.md; do
        [[ -f "$agent_file" ]] || continue
        filename=$(basename "$agent_file")

        if [[ "$filename" == "README.md" ]]; then
            continue
        fi

        if ! grep -q "^name:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}  - $filename missing 'name:'\n"
        fi
        if ! grep -q "^description:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}  - $filename missing 'description:'\n"
        fi
        if ! grep -q "^tools:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}  - $filename missing 'tools:'\n"
        fi
        if ! grep -q "^model:" "$agent_file" 2>/dev/null; then
            MISSING_FIELDS="${MISSING_FIELDS}  - $filename missing 'model:'\n"
        fi
    done

    if [[ -n "$MISSING_FIELDS" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Agent(s) missing required frontmatter fields:"
        echo -e "$MISSING_FIELDS"
        ((WARN_COUNT++)) || true
    else
        pass "All agent files have required frontmatter fields"
    fi
else
    fail ".claude/agents directory missing"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "============================================"
echo -e "${BLUE}SOURCE TRUTH CHECK SUMMARY${NC}"
echo "============================================"
echo -e "  ${GREEN}PASS:${NC} $PASS_COUNT"
echo -e "  ${YELLOW}WARN:${NC} $WARN_COUNT"
echo -e "  ${RED}FAIL:${NC} $FAIL_COUNT"
echo ""

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}RESULT: Hard contradictions detected. Fix FAIL items before proceeding.${NC}"
    exit 1
elif [[ $WARN_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}RESULT: Warnings detected but no hard contradictions. Safe to proceed with caution.${NC}"
    exit 0
else
    echo -e "${GREEN}RESULT: All source truth checks passed.${NC}"
    exit 0
fi
