#!/usr/bin/env bash
set -euo pipefail

# Artifact Hygiene Check for Ollamaclaw
# Non-destructive check for artifact clutter and packaging risk.
# Does not call network, launch Claude Code, modify files, or commit.
#
# Exit codes:
# - 0: PASS (no issues)
# - 0: WARN (warnings but safe to proceed)
# - 1: FAIL (hard safety risks detected)

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

echo "=== A. Root-Level ZIP Files ==="

# Check for root-level ZIP files (excluding .ollamaclaw/artifacts/)
ROOT_ZIPS=()
while IFS= read -r -d '' file; do
    ROOT_ZIPS+=("$file")
done < <(find "$PROJECT_ROOT" -maxdepth 1 -type f -name "*.zip" -print0 2>/dev/null || true)

if [ ${#ROOT_ZIPS[@]} -gt 0 ]; then
    for f in "${ROOT_ZIPS[@]}"; do
        record_warn "Root-level ZIP found: $f"
    done
    echo "Consider moving to .ollamaclaw/artifacts/ or using ./scripts/package-ollamaclaw.sh"
else
    record_pass "No root-level ZIP files"
fi

echo ""
echo "=== B. Bootstrap Junk ==="

# Check for _bootstrap_junk directory
if [ -d "$PROJECT_ROOT/_bootstrap_junk" ]; then
    record_warn "_bootstrap_junk directory exists (excluded from packages)"
    echo "This directory is excluded from packages by default"
else
    record_pass "No _bootstrap_junk directory"
fi

echo ""
echo "=== C. Artifacts Directory ==="

# Check for .ollamaclaw/artifacts/ directory
if [ -d "$PROJECT_ROOT/.ollamaclaw/artifacts" ]; then
    ARTIFACT_COUNT=$(find "$PROJECT_ROOT/.ollamaclaw/artifacts" -type f -name "*.zip" 2>/dev/null | wc -l)
    record_pass ".ollamaclaw/artifacts/ directory exists with $ARTIFACT_COUNT package(s)"
    echo "Packages stored in .ollamaclaw/artifacts/ are git-ignored"
else
    record_warn ".ollamaclaw/artifacts/ directory missing (will be created by package script)"
fi

echo ""
echo "=== D. Nested ZIP Files ==="

# Check for nested ZIP files outside artifacts directory
NESTED_ZIPS=()
while IFS= read -r -d '' file; do
    # Skip if in .ollamaclaw/artifacts/
    if [[ "$file" == *".ollamaclaw/artifacts/"* ]]; then
        continue
    fi
    NESTED_ZIPS+=("$file")
done < <(find "$PROJECT_ROOT" -type f -name "*.zip" -not -path "$PROJECT_ROOT/*" -print0 2>/dev/null || true)

# Also check root level separately (already reported above)
if [ ${#NESTED_ZIPS[@]} -gt 0 ]; then
    for f in "${NESTED_ZIPS[@]}"; do
        record_warn "Nested ZIP found outside artifacts/: $f"
    done
else
    record_pass "No unexpected nested ZIP files"
fi

echo ""
echo "=== E. Tracked Secrets / Local Settings ==="

# Check for tracked sensitive files (hard fail)
SENSITIVE_TRACKED=()
# Check settings.local.json
while IFS= read -r file; do
    if [ -n "$file" ]; then
        SENSITIVE_TRACKED+=("$file")
    fi
done < <(git ls-files "$PROJECT_ROOT/.claude/settings.local.json" 2>/dev/null || true)

# Check .env files
while IFS= read -r file; do
    if [ -n "$file" ]; then
        SENSITIVE_TRACKED+=("$file")
    fi
done < <(git ls-files "$PROJECT_ROOT" 2>/dev/null | grep -E '^\.env($|\.)' || true)

# Check PEM and KEY files
while IFS= read -r file; do
    if [ -n "$file" ]; then
        SENSITIVE_TRACKED+=("$file")
    fi
done < <(git ls-files "$PROJECT_ROOT" 2>/dev/null | grep -E '\.(pem|key)$' || true)

if [ ${#SENSITIVE_TRACKED[@]} -gt 0 ]; then
    for f in "${SENSITIVE_TRACKED[@]}"; do
        record_fail "Sensitive file tracked by git: $f"
    done
    echo "DO NOT COMMIT: Remove from git tracking before proceeding"
else
    record_pass "No sensitive files tracked by git"
fi

echo ""
echo "=== F. Package Script Availability ==="

# Check if package script exists
if [ -x "$PROJECT_ROOT/scripts/package-ollamaclaw.sh" ]; then
    record_pass "scripts/package-ollamaclaw.sh exists and is executable"
elif [ -f "$PROJECT_ROOT/scripts/package-ollamaclaw.sh" ]; then
    record_warn "scripts/package-ollamaclaw.sh exists but is not executable"
    echo "Run: chmod +x scripts/package-ollamaclaw.sh"
else
    record_warn "scripts/package-ollamaclaw.sh missing"
    echo "Create safe packaging script before creating ZIPs manually"
fi

echo ""
echo "=== G. ZIP Command Availability ==="

# Check if zip command is available
if command -v zip &>/dev/null; then
    record_pass "zip command available"
else
    record_fail "zip command not found"
    echo "Install zip to create packages: sudo apt-get install zip"
fi

echo ""
echo "============================================"
echo "ARTIFACT HYGIENE CHECK SUMMARY"
echo "============================================"
echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  FAIL: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo "RESULT: FAIL - Hard safety risks detected. Fix before packaging."
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
    echo "RESULT: PASS - All artifact hygiene checks passed."
    exit 0
fi
