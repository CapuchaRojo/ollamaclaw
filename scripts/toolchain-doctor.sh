#!/usr/bin/env bash
set -euo pipefail

# toolchain-doctor.sh
# Check required and recommended WSL tools for Ollamaclaw.
# Print safe install guidance without running sudo automatically.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# Arrays for missing tools
declare -a MISSING_REQUIRED=()
declare -a MISSING_RECOMMENDED=()

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_tool() {
    local tool="$1"
    local version_cmd="${2:-}"
    local category="${3:-required}"

    if command -v "$tool" >/dev/null 2>&1; then
        if [[ -n "$version_cmd" ]]; then
            local version_output
            version_output=$(timeout 5 bash -c "$version_cmd 2>&1 | head -n 1") || version_output="version unknown"
            print_pass "$tool found: $version_output"
        else
            print_pass "$tool found"
        fi
    else
        if [[ "$category" == "required" ]]; then
            MISSING_REQUIRED+=("$tool")
            print_fail "$tool missing (required)"
        else
            MISSING_RECOMMENDED+=("$tool")
            print_warn "$tool missing (recommended)"
        fi
    fi
}

# === A. Required Tools ===
print_header "A. Required Tools"

check_tool "bash" "bash --version" "required"
check_tool "git" "git --version" "required"
check_tool "curl" "curl --version" "required"
check_tool "unzip" "unzip -v" "required"
check_tool "zip" "zip -v" "required"
check_tool "zstd" "zstd --version" "required"
check_tool "ollama" "ollama --version" "required"
check_tool "claude" "claude --version" "required"

# === B. Recommended Tools ===
print_header "B. Recommended Tools"

check_tool "node" "node --version" "recommended"
check_tool "npm" "npm --version" "recommended"
check_tool "python3" "python3 --version" "recommended"
check_tool "jq" "jq --version" "recommended"
check_tool "gh" "gh --version" "recommended"
check_tool "code" "code --version" "recommended"

# === C. WSL Context ===
print_header "C. WSL Context"

echo "uname -a:"
uname -a

echo ""
echo "pwd: $PWD"

if [[ "$PWD" == /mnt/c/* ]]; then
    echo -e "${YELLOW}[INFO]${NC} Running under /mnt/c — Windows-mounted path is expected for this project."
fi

if command -v free >/dev/null 2>&1; then
    echo ""
    echo "Available memory:"
    free -h
fi

# === D. Manual Install Guidance ===
print_header "D. Manual Install Guidance"

if [[ ${#MISSING_REQUIRED[@]} -gt 0 || ${#MISSING_RECOMMENDED[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Missing tools detected. Run these commands manually (DO NOT auto-execute):${NC}"
    echo ""

    if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
        echo -e "${RED}Missing REQUIRED tools:${NC} ${MISSING_REQUIRED[*]}"
    fi

    if [[ ${#MISSING_RECOMMENDED[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing RECOMMENDED tools:${NC} ${MISSING_RECOMMENDED[*]}"
    fi

    echo ""
    echo "=== Ubuntu/WSL ==="
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y curl unzip zip zstd git jq python3 nodejs npm"

    echo ""
    echo "=== Ollama ==="
    echo "  curl -fsSL https://ollama.com/install.sh | sh"

    echo ""
    echo "=== Claude Code ==="
    echo "  curl -fsSL https://claude.ai/install.sh | bash"

    echo ""
    echo -e "${RED}IMPORTANT: Do NOT execute these commands automatically.${NC}"
    echo "Review each command, understand what it does, then run manually if needed."
else
    echo -e "${GREEN}All required and recommended tools are present.${NC}"
    echo "No install commands needed."
fi

# === Summary ===
echo ""
print_header "TOOLCHAIN DOCTOR SUMMARY"
echo -e "  ${GREEN}PASS:${NC} $PASS_COUNT"
echo -e "  ${YELLOW}WARN:${NC} $WARN_COUNT"
echo -e "  ${RED}FAIL:${NC} $FAIL_COUNT"

echo ""
if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}RESULT: Hard failures detected. Install missing required tools before proceeding.${NC}"
    exit 1
elif [[ $WARN_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}RESULT: Warnings detected. Safe to proceed but recommended tools are missing.${NC}"
    exit 0
else
    echo -e "${GREEN}RESULT: All toolchain checks passed.${NC}"
    exit 0
fi
