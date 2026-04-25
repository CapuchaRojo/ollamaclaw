#!/usr/bin/env bash
set -euo pipefail

# Release Readiness Check for Ollamaclaw
# Fast, non-destructive release/package readiness audit.
# Does not call network, launch Claude Code, modify files, or commit.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Counters
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

PASS_ITEMS=()
WARN_ITEMS=()
FAIL_ITEMS=()

record_pass() {
    PASS_ITEMS+=("$1")
    ((PASS_COUNT++)) || true
}

record_warn() {
    WARN_ITEMS+=("$1")
    ((WARN_COUNT++)) || true
}

record_fail() {
    FAIL_ITEMS+=("$1")
    ((FAIL_COUNT++)) || true
}

echo "=== A. Harness Health ==="

# A. Harness health
if ./scripts/ollamaclaw-doctor.sh >/dev/null 2>&1; then
    record_pass "ollamaclaw-doctor.sh passed"
else
    record_fail "ollamaclaw-doctor.sh failed"
fi

if ./scripts/source-truth-check.sh >/dev/null 2>&1; then
    record_pass "source-truth-check.sh passed"
else
    record_fail "source-truth-check.sh failed"
fi

if ./scripts/agent-inventory.sh >/dev/null 2>&1; then
    record_pass "agent-inventory.sh passed"
else
    record_fail "agent-inventory.sh failed"
fi

echo ""
echo "=== B. Git State ==="

# B. Git state
BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
echo "Current branch: $BRANCH"

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    record_warn "Working tree has uncommitted changes"
else
    record_pass "Working tree is clean"
fi

UPSTREAM=$(git rev-parse --abbrev-ref "@{u}" 2>/dev/null || true)
if [ -z "$UPSTREAM" ]; then
    record_warn "Branch '$BRANCH' is not tracking an upstream"
else
    record_pass "Branch '$BRANCH' tracks '$UPSTREAM'"
fi

echo ""
echo "=== C. Package Safety ==="

# C. Package safety - Fail on sensitive files
SENSITIVE_FILES=()
for pattern in ".claude/settings.local.json" ".env" ".env.*" "*.pem" "*.key"; do
    while IFS= read -r -d '' file; do
        SENSITIVE_FILES+=("$file")
    done < <(find "$PROJECT_ROOT" -type f -name "$pattern" -print0 2>/dev/null || true)
done

if [ ${#SENSITIVE_FILES[@]} -gt 0 ]; then
    for f in "${SENSITIVE_FILES[@]}"; do
        record_fail "Sensitive file tracked: $f"
    done
else
    record_pass "No sensitive files tracked (.env, .key, .pem, settings.local.json)"
fi

# Warn on root zip files (excluding .ollamaclaw/artifacts/)
ZIP_FILES=()
while IFS= read -r -d '' file; do
    ZIP_FILES+=("$file")
done < <(find "$PROJECT_ROOT" -maxdepth 1 -type f -name "*.zip" -print0 2>/dev/null || true)

if [ ${#ZIP_FILES[@]} -gt 0 ]; then
    for f in "${ZIP_FILES[@]}"; do
        record_warn "Root ZIP file found: $f (use ./scripts/package-ollamaclaw.sh for upload packages)"
    done
else
    record_pass "No root ZIP files"
fi

# Check for packages in .ollamaclaw/artifacts/ (info only, not a warning)
ARTIFACT_ZIPS=()
while IFS= read -r -d '' file; do
    ARTIFACT_ZIPS+=("$file")
done < <(find "$PROJECT_ROOT/.ollamaclaw/artifacts" -type f -name "*.zip" -print0 2>/dev/null || true)

if [ ${#ARTIFACT_ZIPS[@]} -gt 0 ]; then
    echo "[INFO] Found ${#ARTIFACT_ZIPS[@]} package(s) in .ollamaclaw/artifacts/ (git-ignored, safe for upload)"
fi

# Warn on _bootstrap_junk
if [ -d "$PROJECT_ROOT/_bootstrap_junk" ]; then
    record_warn "_bootstrap_junk directory exists"
else
    record_pass "No _bootstrap_junk directory"
fi

echo ""
echo "=== D. Reference-Only Rule ==="

# D. Reference-only rule
if [ -f "$PROJECT_ROOT/docs/reference-synthesis.md" ]; then
    record_pass "docs/reference-synthesis.md exists"
else
    record_fail "docs/reference-synthesis.md missing"
fi

if [ -f "$PROJECT_ROOT/docs/c-src-reference-map.md" ]; then
    record_pass "docs/c-src-reference-map.md exists"
else
    record_fail "docs/c-src-reference-map.md missing"
fi

# Check if reference docs state copy-nothing / reference-only
REF_DOCS_CONTENT=""
if [ -f "$PROJECT_ROOT/docs/reference-synthesis.md" ]; then
    REF_DOCS_CONTENT+=$(cat "$PROJECT_ROOT/docs/reference-synthesis.md" 2>/dev/null || true)
fi
if [ -f "$PROJECT_ROOT/docs/c-src-reference-map.md" ]; then
    REF_DOCS_CONTENT+=$(cat "$PROJECT_ROOT/docs/c-src-reference-map.md" 2>/dev/null || true)
fi

if echo "$REF_DOCS_CONTENT" | grep -qiE "(reference-only|copy-nothing|no copying|emulation|concept-only)" >/dev/null 2>&1; then
    record_pass "Reference docs indicate reference-only / copy-nothing stance"
else
    record_warn "Reference docs do not clearly state reference-only / copy-nothing"
fi

# Check LICENSE in referenced source paths
if echo "$REF_DOCS_CONTENT" | grep -qiE "LICENSE|license" >/dev/null 2>&1; then
    record_pass "Reference docs mention LICENSE considerations"
else
    record_warn "Reference docs do not mention LICENSE verification for referenced sources"
fi

echo ""
echo "=== E. Release Docs ==="

# E. Release docs
REQUIRED_DOCS=(
    "docs/package-audit-checklist.md"
    "docs/source-truth-workflow.md"
    "docs/doctor-workflow.md"
    "docs/agent-governance.md"
    "README.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        record_pass "$doc exists"
    else
        record_fail "$doc missing"
    fi
done

echo ""
echo "=== F. Session Log ==="

# F. Session log
if [ -d "$PROJECT_ROOT/.ollamaclaw/sessions" ]; then
    record_pass ".ollamaclaw/sessions directory exists"

    LATEST_SESSION=$(ls -1t "$PROJECT_ROOT/.ollamaclaw/sessions/"*.md 2>/dev/null | head -1 || true)
    if [ -n "$LATEST_SESSION" ]; then
        echo "Latest session log: $LATEST_SESSION"
    else
        echo "No session logs found"
    fi
else
    record_warn ".ollamaclaw/sessions directory missing"
fi

echo ""
echo "============================================"
echo "RELEASE READINESS SUMMARY"
echo "============================================"
echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  FAIL: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo "RESULT: FAIL - Hard release blockers detected. Fix before proceeding."
    echo ""
    echo "--- FAIL Items ---"
    for item in "${FAIL_ITEMS[@]}"; do
        echo "  [FAIL] $item"
    done
    exit 1
elif [ $WARN_COUNT -gt 0 ]; then
    echo "RESULT: WARN - Warnings detected. Safe to proceed with caution."
    echo ""
    if [ ${#WARN_ITEMS[@]} -gt 0 ]; then
        echo "--- WARN Items ---"
        for item in "${WARN_ITEMS[@]}"; do
            echo "  [WARN] $item"
        done
    fi
    exit 0
else
    echo "RESULT: PASS - All release readiness checks passed."
    exit 0
fi
