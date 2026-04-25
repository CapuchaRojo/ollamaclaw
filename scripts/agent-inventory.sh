#!/usr/bin/env bash
#
# agent-inventory.sh - Fast non-destructive inventory of .claude/agents/
#
# Usage: ./scripts/agent-inventory.sh
#
# Exit codes:
#   0 - All agents have required frontmatter, no deprecated fields
#   1 - Missing frontmatter or deprecated type: subagent found
#

set -euo pipefail

# Determine project root from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
AGENTS_DIR="${PROJECT_ROOT}/.claude/agents"

if [[ ! -d "${AGENTS_DIR}" ]]; then
    echo "FAIL: .claude/agents directory not found"
    exit 1
fi

echo "=== Agent Inventory ==="
echo ""

# Count actual agent files excluding README.md
agent_files=()
while IFS= read -r file; do
    basename_file="$(basename "${file}")"
    if [[ "${basename_file}" != "README.md" ]]; then
        agent_files+=("${file}")
    fi
done < <(find "${AGENTS_DIR}" -maxdepth 1 -type f | sort)

agent_count="${#agent_files[@]}"
echo "Agent count: ${agent_count} (excluding README.md)"
echo ""

# Track issues
missing_name=()
missing_description=()
missing_tools=()
missing_model=()
deprecated_type=()
pass_count=0

for agent_file in "${agent_files[@]}"; do
    filename="$(basename "${agent_file}")"
    has_issue=0

    # Read first 20 lines for frontmatter check
    frontmatter=""
    line_count=0
    while IFS= read -r line && [[ ${line_count} -lt 20 ]]; do
        frontmatter+="${line}"$'\n'
        line_count=$((line_count + 1))
    done < "${agent_file}"

    # Check for required fields
    if ! echo "${frontmatter}" | grep -q "^name:"; then
        missing_name+=("${filename}")
        has_issue=1
    fi

    if ! echo "${frontmatter}" | grep -q "^description:"; then
        missing_description+=("${filename}")
        has_issue=1
    fi

    if ! echo "${frontmatter}" | grep -q "^tools:"; then
        missing_tools+=("${filename}")
        has_issue=1
    fi

    if ! echo "${frontmatter}" | grep -q "^model:"; then
        missing_model+=("${filename}")
        has_issue=1
    fi

    # Check for deprecated type: subagent
    if echo "${frontmatter}" | grep -q "^type: subagent"; then
        deprecated_type+=("${filename}")
        has_issue=1
    fi

    if [[ ${has_issue} -eq 0 ]]; then
        pass_count=$((pass_count + 1))
    fi
done

# Report results
echo "=== Frontmatter Validation ==="
echo ""

if [[ ${pass_count} -eq ${agent_count} ]]; then
    echo "[PASS] All ${agent_count} agents have required frontmatter"
else
    echo "[WARN] ${pass_count}/${agent_count} agents pass validation"
fi
echo ""

# Report missing fields
if [[ ${#missing_name[@]} -gt 0 ]]; then
    echo "Missing 'name:' field:"
    for f in "${missing_name[@]}"; do
        echo "  - ${f}"
    done
    echo ""
fi

if [[ ${#missing_description[@]} -gt 0 ]]; then
    echo "Missing 'description:' field:"
    for f in "${missing_description[@]}"; do
        echo "  - ${f}"
    done
    echo ""
fi

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo "Missing 'tools:' field:"
    for f in "${missing_tools[@]}"; do
        echo "  - ${f}"
    done
    echo ""
fi

if [[ ${#missing_model[@]} -gt 0 ]]; then
    echo "Missing 'model:' field:"
    for f in "${missing_model[@]}"; do
        echo "  - ${f}"
    done
    echo ""
fi

# Report deprecated fields
if [[ ${#deprecated_type[@]} -gt 0 ]]; then
    echo "[BLOCKER] Deprecated 'type: subagent' found:"
    for f in "${deprecated_type[@]}"; do
        echo "  - ${f}"
    done
    echo ""
    echo "ACTION: Remove 'type: subagent' lines - no longer supported"
    exit 1
fi

# Final summary
echo "=== Summary ==="
echo ""
if [[ ${#missing_name[@]} -eq 0 && ${#missing_description[@]} -eq 0 && ${#missing_tools[@]} -eq 0 && ${#missing_model[@]} -eq 0 ]]; then
    echo "RESULT: All agents have valid frontmatter"
    exit 0
else
    echo "RESULT: Frontmatter issues detected"
    exit 1
fi
