#!/bin/bash
set -euo pipefail

# Worktree Slice Manager
# A safe helper for planning and optionally creating git worktrees for parallel Ollamaclaw slices.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORKTREE_BASE="$(dirname "$PROJECT_ROOT")"

usage() {
    cat <<EOF
Worktree Slice Manager

Usage:
  $0 plan <slice-name>     Plan a new worktree slice (non-destructive)
  $0 create <slice-name>   Create a new worktree slice
  $0 list                  List existing worktrees
  $0 help                  Show this help message

Examples:
  $0 plan docs-cleanup
  $0 create feature-x
  $0 list

Safety Rules:
  - Always run 'plan' before 'create'
  - Run ./scripts/parallel-safety-check.sh before creating worktrees
  - Run ./scripts/release-readiness.sh before merging back to main
  - One writer per branch/worktree only
  - Do not run multiple writers on the same branch

Slice Naming:
  - Lowercase letters, numbers, and hyphens only
  - Branch name: slice/<slice-name>
  - Worktree path: ../ollamaclaw-slice-<slice-name>
EOF
}

validate_slice_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "FAIL: Invalid slice name '$name'"
        echo "      Slice names must be lowercase, with letters, numbers, and hyphens only."
        return 1
    fi
    return 0
}

check_clean_tree() {
    if ! git -C "$PROJECT_ROOT" diff-index --quiet HEAD --; then
        echo "FAIL: Working tree has uncommitted changes."
        echo "      Commit or stash changes before creating a worktree."
        return 1
    fi
    return 0
}

cmd_plan() {
    local slice_name="$1"

    echo "=== Worktree Slice Plan ==="
    echo ""

    if ! validate_slice_name "$slice_name"; then
        return 1
    fi

    local branch_name="slice/${slice_name}"
    local worktree_path="${WORKTREE_BASE}/ollamaclaw-slice-${slice_name}"

    echo "Slice name:     ${slice_name}"
    echo "Branch:         ${branch_name}"
    echo "Worktree path:  ${worktree_path}"
    echo ""

    echo "Commands that would be run:"
    echo "  git -C ${PROJECT_ROOT} worktree add -b ${branch_name} ${worktree_path}"
    echo ""

    echo "Before creating this worktree, run:"
    echo "  ./scripts/parallel-safety-check.sh"
    echo "  ./scripts/release-readiness.sh"
    echo ""

    echo "After creation, switch to worktree with:"
    echo "  cd ${worktree_path}"
    echo "  ./scripts/ollamaclaw-doctor.sh"
    echo "  ./scripts/release-readiness.sh"
    echo ""

    echo "PASS: Plan generated. Run '$0 create ${slice_name}' to create."
}

cmd_create() {
    local slice_name="$1"

    echo "=== Creating Worktree Slice ==="
    echo ""

    if ! validate_slice_name "$slice_name"; then
        return 1
    fi

    if ! check_clean_tree; then
        return 1
    fi

    local branch_name="slice/${slice_name}"
    local worktree_path="${WORKTREE_BASE}/ollamaclaw-slice-${slice_name}"

    if [[ -d "$worktree_path" ]]; then
        echo "FAIL: Worktree path already exists: ${worktree_path}"
        echo "      Remove existing worktree first or choose a different slice name."
        return 1
    fi

    echo "Creating worktree..."
    git -C "$PROJECT_ROOT" worktree add -b "$branch_name" "$worktree_path"

    echo ""
    echo "PASS: Worktree created successfully."
    echo ""
    echo "Next steps:"
    echo "  cd ${worktree_path}"
    echo "  ./scripts/ollamaclaw-doctor.sh"
    echo "  ./scripts/release-readiness.sh"
}

cmd_list() {
    echo "=== Git Worktrees ==="
    echo ""
    git worktree list
    echo ""
    echo "Current branch: $(git -C "$PROJECT_ROOT" branch --show-current)"
}

# Main entry point
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

command="$1"
shift

case "$command" in
    plan)
        if [[ $# -lt 1 ]]; then
            echo "FAIL: Missing slice name."
            echo "Usage: $0 plan <slice-name>"
            exit 1
        fi
        cmd_plan "$1"
        ;;
    create)
        if [[ $# -lt 1 ]]; then
            echo "FAIL: Missing slice name."
            echo "Usage: $0 create <slice-name>"
            exit 1
        fi
        cmd_create "$1"
        ;;
    list)
        cmd_list
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "FAIL: Unknown command '$command'"
        echo ""
        usage
        exit 1
        ;;
esac
